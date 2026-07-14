package storage

import (
	"fmt"
	"sync"
)

// TickCount represents a population count for a specific tick.
type TickCount struct {
	Tick        int
	StageID     *int64
	PrototypeID *int64
	Count       int
}

// SimEvent represents a simulation event to be recorded.
type SimEvent struct {
	Tick      int
	EventType string
	AgentName string
	Details   string
}

// WriteBuffer accumulates simulation results in memory and flushes them
// to the database in batch transactions. This avoids per-tick I/O overhead
// in the hot simulation loop.
type WriteBuffer struct {
	mu         sync.Mutex
	db         *DB
	runID      int64
	tickCounts []TickCount
	events     []SimEvent
	// Flush thresholds
	maxRecords   int
	tickInterval int
	lastFlushTick int
}

// WriteBufferConfig configures the flush behavior of the write buffer.
type WriteBufferConfig struct {
	// MaxRecords triggers a flush when the buffer accumulates this many records.
	// Default: 10000.
	MaxRecords int
	// TickInterval triggers a flush every N ticks. Default: 100.
	TickInterval int
}

// DefaultWriteBufferConfig returns sensible defaults for the write buffer.
func DefaultWriteBufferConfig() WriteBufferConfig {
	return WriteBufferConfig{
		MaxRecords:   10000,
		TickInterval: 100,
	}
}

// NewWriteBuffer creates a new write buffer for the given simulation run.
func NewWriteBuffer(db *DB, runID int64, cfg WriteBufferConfig) *WriteBuffer {
	if cfg.MaxRecords <= 0 {
		cfg.MaxRecords = 10000
	}
	if cfg.TickInterval <= 0 {
		cfg.TickInterval = 100
	}
	return &WriteBuffer{
		db:           db,
		runID:        runID,
		maxRecords:   cfg.MaxRecords,
		tickInterval: cfg.TickInterval,
	}
}

// AddTickCounts appends population counts for a tick to the buffer.
// It automatically flushes if thresholds are exceeded.
func (wb *WriteBuffer) AddTickCounts(tick int, counts []TickCount) error {
	wb.mu.Lock()
	defer wb.mu.Unlock()

	wb.tickCounts = append(wb.tickCounts, counts...)

	if wb.shouldFlush(tick) {
		return wb.flushLocked()
	}
	return nil
}

// AddEvent appends a simulation event to the buffer.
func (wb *WriteBuffer) AddEvent(event SimEvent) error {
	wb.mu.Lock()
	defer wb.mu.Unlock()

	wb.events = append(wb.events, event)

	if wb.totalRecords() >= wb.maxRecords {
		return wb.flushLocked()
	}
	return nil
}

// AddEvents appends multiple simulation events to the buffer.
func (wb *WriteBuffer) AddEvents(events []SimEvent) error {
	wb.mu.Lock()
	defer wb.mu.Unlock()

	wb.events = append(wb.events, events...)

	if wb.totalRecords() >= wb.maxRecords {
		return wb.flushLocked()
	}
	return nil
}

// Flush forces all buffered data to be written to the database.
// Call this at the end of a simulation run to ensure no data is lost.
func (wb *WriteBuffer) Flush() error {
	wb.mu.Lock()
	defer wb.mu.Unlock()
	return wb.flushLocked()
}

// Pending returns the number of records currently buffered.
func (wb *WriteBuffer) Pending() int {
	wb.mu.Lock()
	defer wb.mu.Unlock()
	return wb.totalRecords()
}

func (wb *WriteBuffer) shouldFlush(currentTick int) bool {
	if wb.totalRecords() >= wb.maxRecords {
		return true
	}
	if currentTick-wb.lastFlushTick >= wb.tickInterval {
		return true
	}
	return false
}

func (wb *WriteBuffer) totalRecords() int {
	return len(wb.tickCounts) + len(wb.events)
}

func (wb *WriteBuffer) flushLocked() error {
	if wb.totalRecords() == 0 {
		return nil
	}

	tx, err := wb.db.Conn.Begin()
	if err != nil {
		return fmt.Errorf("write_buffer: begin tx: %w", err)
	}

	// Flush tick counts.
	if len(wb.tickCounts) > 0 {
		stmt, err := tx.Prepare(
			"INSERT INTO sim_tick_counts (run_id, tick, stage_id, prototype_id, count) VALUES (?, ?, ?, ?, ?)",
		)
		if err != nil {
			tx.Rollback()
			return fmt.Errorf("write_buffer: prepare tick_counts: %w", err)
		}

		for _, tc := range wb.tickCounts {
			if _, err := stmt.Exec(wb.runID, tc.Tick, tc.StageID, tc.PrototypeID, tc.Count); err != nil {
				stmt.Close()
				tx.Rollback()
				return fmt.Errorf("write_buffer: insert tick_count: %w", err)
			}
		}
		stmt.Close()
	}

	// Flush events.
	if len(wb.events) > 0 {
		stmt, err := tx.Prepare(
			"INSERT INTO sim_events (run_id, tick, event_type, agent_name, details) VALUES (?, ?, ?, ?, ?)",
		)
		if err != nil {
			tx.Rollback()
			return fmt.Errorf("write_buffer: prepare events: %w", err)
		}

		for _, ev := range wb.events {
			if _, err := stmt.Exec(wb.runID, ev.Tick, ev.EventType, ev.AgentName, ev.Details); err != nil {
				stmt.Close()
				tx.Rollback()
				return fmt.Errorf("write_buffer: insert event: %w", err)
			}
		}
		stmt.Close()
	}

	if err := tx.Commit(); err != nil {
		return fmt.Errorf("write_buffer: commit: %w", err)
	}

	// Track the highest tick flushed for interval calculation.
	if len(wb.tickCounts) > 0 {
		lastTick := wb.tickCounts[len(wb.tickCounts)-1].Tick
		if lastTick > wb.lastFlushTick {
			wb.lastFlushTick = lastTick
		}
	}

	// Reset buffers, keep allocated capacity.
	wb.tickCounts = wb.tickCounts[:0]
	wb.events = wb.events[:0]

	return nil
}
