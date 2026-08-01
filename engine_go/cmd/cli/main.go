// Command galateac is the headless simulation engine for the Galatea suite.
// It loads a project from a SQLite database, runs the simulation for a
// specified number of cycles, and periodically reports population statistics.
//
// Usage:
//
//	galateac --file project.db [--env NAME] [--cycles N] [--report-interval N] [--quiet]
//	galateac --help
//	galateac --version
package main

import (
	"flag"
	"fmt"
	"os"
	"runtime"
	"time"

	"galatea/engine/internal/adapters/storage"
	"galatea/engine/internal/kernel"
)

const version = "2.0.0"

func main() {
	if err := run(); err != nil {
		fmt.Fprintf(os.Stderr, "error: %v\n", err)
		os.Exit(1)
	}
}

func run() error {
	// --- Flag definitions ---
	filePath := flag.String("file", "", "Path to the project database (.db file) [required]")
	envName := flag.String("env", "", "Environment name to simulate (auto-selected if only one)")
	envID := flag.Int64("env-id", 0, "Environment ID to simulate (alternative to --env)")
	cycles := flag.Int("cycles", 1000, "Number of simulation cycles to run")
	reportInterval := flag.Int("report-interval", 100, "Report status every N cycles (0 = disable)")
	quiet := flag.Bool("quiet", false, "Suppress periodic reports (only show start/end)")
	showVersion := flag.Bool("version", false, "Show version and exit")

	flag.Usage = func() {
		fmt.Fprintf(os.Stderr, "Galatea Simulation Engine (headless) v%s\n\n", version)
		fmt.Fprintf(os.Stderr, "Usage:\n")
		fmt.Fprintf(os.Stderr, "  galateac --file project.db [options]\n\n")
		fmt.Fprintf(os.Stderr, "Options:\n")
		flag.PrintDefaults()
		fmt.Fprintf(os.Stderr, "\nExamples:\n")
		fmt.Fprintf(os.Stderr, "  galateac --file sim.db --cycles 5000 --report-interval 500\n")
		fmt.Fprintf(os.Stderr, "  galateac --file sim.db --env \"Main\" --cycles 10000 --quiet\n")
	}

	flag.Parse()

	if *showVersion {
		fmt.Printf("galateac v%s (%s/%s)\n", version, runtime.GOOS, runtime.GOARCH)
		return nil
	}

	if *filePath == "" {
		flag.Usage()
		return fmt.Errorf("--file is required")
	}

	// --- Open database ---
	if _, err := os.Stat(*filePath); os.IsNotExist(err) {
		return fmt.Errorf("file not found: %s", *filePath)
	}

	db, err := storage.Open(*filePath)
	if err != nil {
		return fmt.Errorf("open database: %w", err)
	}
	defer db.Close()

	// --- Resolve environment ---
	resolvedID, resolvedName, err := storage.ResolveEnvironment(db, *envName, *envID)
	if err != nil {
		return err
	}

	// --- Print header ---
	fmt.Println("╔══════════════════════════════════════════════════════════════════╗")
	fmt.Println("║              GALATEA SIMULATION ENGINE (headless)               ║")
	fmt.Printf("║  v%-62s║\n", version)
	fmt.Println("╚══════════════════════════════════════════════════════════════════╝")
	fmt.Printf("Project:     %s\n", *filePath)
	fmt.Printf("Environment: %s (id=%d)\n", resolvedName, resolvedID)
	fmt.Printf("Cycles:      %d\n", *cycles)
	fmt.Printf("Platform:    %s/%s, CPUs: %d\n\n", runtime.GOOS, runtime.GOARCH, runtime.NumCPU())

	// --- Build engine ---
	engineCfg := kernel.DefaultEngineConfig(resolvedID)
	engineCfg.WriteBufferCfg = storage.WriteBufferConfig{
		MaxRecords:   50000,
		TickInterval: 500,
	}

	engine, err := kernel.Build(db, engineCfg)
	if err != nil {
		return fmt.Errorf("build engine: %w", err)
	}

	fmt.Printf("Engine built. Agents: %d, Resources: %d, Grid: %dx%d\n",
		engine.World.Agents.Count, engine.World.Resources.Count,
		engine.World.Config.GridWidth, engine.World.Config.GridHeight)
	fmt.Println("Starting simulation...")
	fmt.Println()

	// --- Run simulation ---
	startTime := time.Now()
	lastReportTime := startTime
	lastReportTick := 0

	for tick := 1; tick <= *cycles; tick++ {
		engine.Tick()

		// Periodic report.
		if !*quiet && *reportInterval > 0 && tick%(*reportInterval) == 0 {
			now := time.Now()
			elapsed := now.Sub(startTime)
			intervalElapsed := now.Sub(lastReportTime)
			intervalTicks := tick - lastReportTick
			tps := float64(intervalTicks) / intervalElapsed.Seconds()

			var memStats runtime.MemStats
			runtime.ReadMemStats(&memStats)

			fmt.Printf("── Tick %d / %d ─────────────────────────────────────────\n", tick, *cycles)
			printPopulationCounts(engine)
			fmt.Printf("  TPS:      %.0f ticks/sec\n", tps)
			fmt.Printf("  Elapsed:  %s\n", formatDuration(elapsed))
			fmt.Printf("  Memory:   %.1f MB (alloc) / %.1f MB (sys)\n",
				float64(memStats.Alloc)/1024/1024,
				float64(memStats.Sys)/1024/1024)
			fmt.Println()

			lastReportTime = now
			lastReportTick = tick
		}
	}

	// --- Finish ---
	totalTime := time.Since(startTime)
	avgTPS := float64(*cycles) / totalTime.Seconds()

	engine.Finish("finished")

	fmt.Println("══════════════════════════════════════════════════════════════════")
	fmt.Println("  SIMULATION COMPLETE")
	fmt.Println("══════════════════════════════════════════════════════════════════")
	printPopulationCounts(engine)
	fmt.Printf("  Total cycles: %d\n", *cycles)
	fmt.Printf("  Total time:   %s\n", formatDuration(totalTime))
	fmt.Printf("  Average TPS:  %.0f ticks/sec\n", avgTPS)

	var memStats runtime.MemStats
	runtime.ReadMemStats(&memStats)
	fmt.Printf("  Peak memory:  %.1f MB\n", float64(memStats.TotalAlloc)/1024/1024)
	fmt.Println()

	return nil
}

// printPopulationCounts prints current agent counts by stage/prototype.
func printPopulationCounts(engine *kernel.Engine) {
	w := engine.World
	cfg := w.Config
	a := w.Agents

	// Count by stage and prototype.
	stageCounts := make([]int, cfg.NumStages)
	maleCounts := make([]int, cfg.NumPrototypesM)
	femaleCounts := make([]int, cfg.NumPrototypesF)
	eggs := w.Eggs.Count

	for i := 0; i < a.Count; i++ {
		stageID := a.StageID[i]
		if stageID >= 0 && int(stageID) < cfg.NumStages {
			stageCounts[stageID]++
		} else if stageID == -1 {
			// Adult — count by prototype and sex.
			protoID := a.PrototypeID[i]
			switch a.Sex[i] {
			case 1: // Male
				if int(protoID) < cfg.NumPrototypesM {
					maleCounts[protoID]++
				}
			case 2: // Female
				if int(protoID) < cfg.NumPrototypesF {
					femaleCounts[protoID]++
				}
			}
		}
	}

	fmt.Printf("  Eggs:     %d\n", eggs)
	for i, count := range stageCounts {
		name := fmt.Sprintf("Stage%d", i+1)
		if i < len(cfg.Names.StageNames) && cfg.Names.StageNames[i] != "" {
			name = cfg.Names.StageNames[i]
		}
		fmt.Printf("  %-10s %d\n", name+":", count)
	}
	for i, count := range maleCounts {
		name := fmt.Sprintf("Male%d", i+1)
		if i < len(cfg.Names.PrototypeMNames) && cfg.Names.PrototypeMNames[i] != "" {
			name = cfg.Names.PrototypeMNames[i]
		}
		fmt.Printf("  %-10s %d\n", name+":", count)
	}
	for i, count := range femaleCounts {
		name := fmt.Sprintf("Female%d", i+1)
		if i < len(cfg.Names.PrototypeFNames) && cfg.Names.PrototypeFNames[i] != "" {
			name = cfg.Names.PrototypeFNames[i]
		}
		fmt.Printf("  %-10s %d\n", name+":", count)
	}
	total := eggs + a.Count
	fmt.Printf("  Total:    %d\n", total)
}

// formatDuration formats a duration as HH:MM:SS.
func formatDuration(d time.Duration) string {
	h := int(d.Hours())
	m := int(d.Minutes()) % 60
	s := int(d.Seconds()) % 60
	return fmt.Sprintf("%02d:%02d:%02d", h, m, s)
}
