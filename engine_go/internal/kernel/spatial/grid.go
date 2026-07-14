// Package spatial provides a spatial hash grid for efficient proximity queries.
// It reduces agent perception searches from O(N²) to O(N) by partitioning
// the 2D world into uniform cells and only searching nearby cells.
package spatial

import "math"

// Grid is a spatial hash that maps 2D positions to buckets of agent indices.
// Cell coordinates are computed by dividing world positions by CellSize.
type Grid struct {
	CellSize float64 // Width/height of each cell.
	invCell  float64 // 1.0 / CellSize (precomputed for fast division).

	// cells maps a cell key to a slice of agent indices in that cell.
	cells map[cellKey][]int32

	// agentCell tracks which cell each agent is currently in (indexed by agent idx).
	// This allows O(1) removal without scanning.
	agentCell []cellKey
	agentCap  int

	// Reusable result buffer to avoid allocations during queries.
	resultBuf []int32
}

// cellKey is a compact representation of a 2D cell coordinate.
type cellKey struct {
	X, Y int32
}

// NewGrid creates a spatial hash grid with the given cell size.
// cellSize should typically be set to the maximum perception radius in the simulation.
func NewGrid(cellSize float64, agentCapacity int) *Grid {
	if cellSize <= 0 {
		cellSize = 10
	}
	if agentCapacity < 64 {
		agentCapacity = 64
	}

	g := &Grid{
		CellSize:  cellSize,
		invCell:   1.0 / cellSize,
		cells:     make(map[cellKey][]int32, agentCapacity/4),
		agentCell: make([]cellKey, agentCapacity),
		agentCap:  agentCapacity,
		resultBuf: make([]int32, 0, 128),
	}

	// Initialize agentCell with an invalid sentinel.
	for i := range g.agentCell {
		g.agentCell[i] = cellKey{math.MinInt32, math.MinInt32}
	}

	return g
}

// Insert adds an agent at the given position.
func (g *Grid) Insert(agentIdx int32, x, y float64) {
	g.ensureCapacity(int(agentIdx))
	key := g.cellFor(x, y)
	g.cells[key] = append(g.cells[key], agentIdx)
	g.agentCell[agentIdx] = key
}

// Remove removes an agent from the grid.
func (g *Grid) Remove(agentIdx int32) {
	if int(agentIdx) >= g.agentCap {
		return
	}
	key := g.agentCell[agentIdx]
	if key.X == math.MinInt32 {
		return // Not inserted.
	}

	bucket := g.cells[key]
	for i, idx := range bucket {
		if idx == agentIdx {
			// Swap with last and shrink.
			bucket[i] = bucket[len(bucket)-1]
			g.cells[key] = bucket[:len(bucket)-1]
			break
		}
	}

	// Clean up empty buckets to avoid memory leaks over time.
	if len(g.cells[key]) == 0 {
		delete(g.cells, key)
	}

	g.agentCell[agentIdx] = cellKey{math.MinInt32, math.MinInt32}
}

// Move updates an agent's position in the grid.
// Only performs a bucket transfer if the cell changed.
func (g *Grid) Move(agentIdx int32, newX, newY float64) {
	g.ensureCapacity(int(agentIdx))
	newKey := g.cellFor(newX, newY)
	oldKey := g.agentCell[agentIdx]

	if oldKey == newKey {
		return // Same cell, no work needed.
	}

	// Remove from old cell.
	if oldKey.X != math.MinInt32 {
		bucket := g.cells[oldKey]
		for i, idx := range bucket {
			if idx == agentIdx {
				bucket[i] = bucket[len(bucket)-1]
				g.cells[oldKey] = bucket[:len(bucket)-1]
				break
			}
		}
		if len(g.cells[oldKey]) == 0 {
			delete(g.cells, oldKey)
		}
	}

	// Insert into new cell.
	g.cells[newKey] = append(g.cells[newKey], agentIdx)
	g.agentCell[agentIdx] = newKey
}

// QueryRadius returns all agent indices within the given radius of point (cx, cy).
// The returned slice is internal and must be consumed before the next query call.
func (g *Grid) QueryRadius(cx, cy, radius float64) []int32 {
	g.resultBuf = g.resultBuf[:0]
	radiusSq := radius * radius

	// Determine the range of cells that could contain agents within radius.
	minCX := int32(math.Floor((cx - radius) * g.invCell))
	maxCX := int32(math.Floor((cx + radius) * g.invCell))
	minCY := int32(math.Floor((cy - radius) * g.invCell))
	maxCY := int32(math.Floor((cy + radius) * g.invCell))

	for cellX := minCX; cellX <= maxCX; cellX++ {
		for cellY := minCY; cellY <= maxCY; cellY++ {
			bucket := g.cells[cellKey{cellX, cellY}]
			for _, idx := range bucket {
				_ = radiusSq // Caller must filter by actual distance using positions.
				g.resultBuf = append(g.resultBuf, idx)
			}
		}
	}

	return g.resultBuf
}

// QueryRadiusExact returns agent indices within radius, filtering by actual Euclidean distance.
// Requires position slices to compute distances.
func (g *Grid) QueryRadiusExact(cx, cy, radius float64, posX, posY []float64) []int32 {
	g.resultBuf = g.resultBuf[:0]
	radiusSq := radius * radius

	minCX := int32(math.Floor((cx - radius) * g.invCell))
	maxCX := int32(math.Floor((cx + radius) * g.invCell))
	minCY := int32(math.Floor((cy - radius) * g.invCell))
	maxCY := int32(math.Floor((cy + radius) * g.invCell))

	for cellX := minCX; cellX <= maxCX; cellX++ {
		for cellY := minCY; cellY <= maxCY; cellY++ {
			bucket := g.cells[cellKey{cellX, cellY}]
			for _, idx := range bucket {
				dx := posX[idx] - cx
				dy := posY[idx] - cy
				if dx*dx+dy*dy <= radiusSq {
					g.resultBuf = append(g.resultBuf, idx)
				}
			}
		}
	}

	return g.resultBuf
}

// QueryNeighbors returns all agent indices in the same cell and the 8 adjacent cells
// around the given position (Moore neighborhood). This corresponds to distance <= 1 cell.
func (g *Grid) QueryNeighbors(x, y float64) []int32 {
	g.resultBuf = g.resultBuf[:0]
	cx := int32(math.Floor(x * g.invCell))
	cy := int32(math.Floor(y * g.invCell))

	for dx := int32(-1); dx <= 1; dx++ {
		for dy := int32(-1); dy <= 1; dy++ {
			bucket := g.cells[cellKey{cx + dx, cy + dy}]
			g.resultBuf = append(g.resultBuf, bucket...)
		}
	}

	return g.resultBuf
}

// Clear removes all agents from the grid without deallocating.
func (g *Grid) Clear() {
	for k := range g.cells {
		delete(g.cells, k)
	}
	for i := range g.agentCell {
		g.agentCell[i] = cellKey{math.MinInt32, math.MinInt32}
	}
}

// Rebuild re-inserts all active agents from position slices.
// Call after swap-and-pop operations that invalidate the grid.
func (g *Grid) Rebuild(count int, posX, posY []float64) {
	g.Clear()
	for i := 0; i < count; i++ {
		g.Insert(int32(i), posX[i], posY[i])
	}
}

// cellFor computes the cell key for a world position.
func (g *Grid) cellFor(x, y float64) cellKey {
	return cellKey{
		X: int32(math.Floor(x * g.invCell)),
		Y: int32(math.Floor(y * g.invCell)),
	}
}

// ensureCapacity grows the agentCell tracking slice if needed.
func (g *Grid) ensureCapacity(idx int) {
	if idx < g.agentCap {
		return
	}
	newCap := g.agentCap * 2
	for newCap <= idx {
		newCap *= 2
	}
	newSlice := make([]cellKey, newCap)
	copy(newSlice, g.agentCell)
	for i := g.agentCap; i < newCap; i++ {
		newSlice[i] = cellKey{math.MinInt32, math.MinInt32}
	}
	g.agentCell = newSlice
	g.agentCap = newCap
}
