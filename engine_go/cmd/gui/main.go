// Command galatea is the 2D visualizer for the Galatea simulation suite.
// It renders the simulation state in real-time using Ebitengine and provides
// basic controls: Space=start/pause, Escape=quit.
package main

import (
	"flag"
	"fmt"
	"image/color"
	"log"
	"math"
	"os"
	"time"

	"github.com/hajimehoshi/ebiten/v2"
	"github.com/hajimehoshi/ebiten/v2/ebitenutil"
	"github.com/hajimehoshi/ebiten/v2/vector"

	"galatea/engine/internal/adapters/storage"
	"galatea/engine/internal/kernel"
	"galatea/engine/internal/kernel/world"
)

const (
	windowWidth  = 1024
	windowHeight = 768
	maxCellSize  = 12
	minCellSize  = 2
)

// Simulation states.
const (
	statePaused  = 0
	stateRunning = 1
	stateStopped = 2
)

// Game implements the ebiten.Game interface for the Galatea visualizer.
type Game struct {
	engine *kernel.Engine
	state  int

	// Rendering parameters.
	cellSize   float64 // Pixels per grid cell.
	offsetX    float64 // Viewport offset in pixels.
	offsetY    float64
	gridWidth  int
	gridHeight int

	// Substrate color cache.
	substrateColors []color.RGBA

	// Viewport dirty flag for potential future substrate pre-rendering.
	substrateDirty bool

	// Input state for drag.
	dragging   bool
	dragStartX int
	dragStartY int
	dragOffX   float64
	dragOffY   float64

	// Stats.
	ticksPerFrame int
	maxSpeed      bool    // When true, runs as many ticks as fit in the frame budget.
	frameBudgetMs float64 // Max milliseconds to spend on simulation per frame.
}

// NewGame creates a new visualizer game from an engine.
func NewGame(engine *kernel.Engine) *Game {
	cfg := engine.World.Config

	// Calculate cell size to fit the grid in the window.
	cellW := float64(windowWidth) / float64(cfg.GridWidth)
	cellH := float64(windowHeight) / float64(cfg.GridHeight)
	cellSize := math.Min(cellW, cellH)
	if cellSize > maxCellSize {
		cellSize = maxCellSize
	}
	if cellSize < minCellSize {
		cellSize = minCellSize
	}

	// Generate substrate colors (distinct, earthy palette).
	numSub := cfg.NumSubstrates
	if numSub == 0 {
		numSub = 1
	}
	subColors := make([]color.RGBA, numSub+1)
	subColors[0] = color.RGBA{20, 20, 25, 255} // Default/unset = background.
	// Predefined visually distinct palette for common substrates.
	palette := []color.RGBA{
		{80, 160, 60, 255},   // 1: Grass (green)
		{210, 190, 130, 255}, // 2: Sand (beige)
		{50, 120, 200, 255},  // 3: Water (blue)
		{110, 110, 110, 255}, // 4: Rock (gray)
		{30, 90, 30, 255},    // 5: Forest (dark green)
		{180, 120, 60, 255},  // 6: Dirt (brown)
		{240, 240, 240, 255}, // 7: Snow (white)
		{160, 80, 160, 255},  // 8: Flowers (purple)
	}
	for i := 1; i <= numSub; i++ {
		if i-1 < len(palette) {
			subColors[i] = palette[i-1]
		} else {
			subColors[i] = hueToRGBA(float64(i-1)/float64(numSub), 0.5, 0.7)
		}
	}

	return &Game{
		engine:          engine,
		state:           statePaused,
		cellSize:        cellSize,
		gridWidth:       cfg.GridWidth,
		gridHeight:      cfg.GridHeight,
		substrateColors: subColors,
		substrateDirty:  true,
		ticksPerFrame:   1,
		maxSpeed:        false,
		frameBudgetMs:   14.0, // Leave ~2ms for rendering at 60 FPS.
	}
}

// Update handles input and advances the simulation.
func (g *Game) Update() error {
	// Controls.
	if ebiten.IsKeyPressed(ebiten.KeyEscape) {
		g.state = stateStopped
		return ebiten.Termination
	}

	if inputJustPressed(ebiten.KeySpace) {
		if g.state == statePaused {
			g.state = stateRunning
		} else if g.state == stateRunning {
			g.state = statePaused
		}
	}

	// Speed controls.
	if inputJustPressed(ebiten.KeyUp) && g.ticksPerFrame < 1000 {
		g.ticksPerFrame *= 2
		g.maxSpeed = false
	}
	if inputJustPressed(ebiten.KeyDown) && g.ticksPerFrame > 1 {
		g.ticksPerFrame /= 2
		if g.ticksPerFrame < 1 {
			g.ticksPerFrame = 1
		}
		g.maxSpeed = false
	}

	// M = max speed mode (fill frame budget with ticks).
	if inputJustPressed(ebiten.KeyM) {
		g.maxSpeed = !g.maxSpeed
	}

	// Scroll zoom.
	_, scrollY := ebiten.Wheel()
	if scrollY != 0 {
		g.cellSize += scrollY
		if g.cellSize < minCellSize {
			g.cellSize = minCellSize
		}
		if g.cellSize > 30 {
			g.cellSize = 30
		}
		g.substrateDirty = true
	}

	// Drag to pan.
	if ebiten.IsMouseButtonPressed(ebiten.MouseButtonLeft) {
		mx, my := ebiten.CursorPosition()
		if !g.dragging {
			g.dragging = true
			g.dragStartX = mx
			g.dragStartY = my
			g.dragOffX = g.offsetX
			g.dragOffY = g.offsetY
		} else {
			g.offsetX = g.dragOffX + float64(mx-g.dragStartX)
			g.offsetY = g.dragOffY + float64(my-g.dragStartY)
			g.substrateDirty = true
		}
	} else {
		g.dragging = false
	}

	// Advance simulation if running.
	if g.state == stateRunning && g.engine.World.Agents.Count > 0 {
		if g.maxSpeed {
			// Max speed: run as many ticks as fit within the frame budget.
			deadline := time.Now().Add(time.Duration(g.frameBudgetMs * float64(time.Millisecond)))
			for time.Now().Before(deadline) {
				g.engine.Tick()
				if g.engine.World.Agents.Count == 0 {
					g.state = statePaused
					break
				}
			}
		} else {
			for i := 0; i < g.ticksPerFrame; i++ {
				g.engine.Tick()
				if g.engine.World.Agents.Count == 0 {
					g.state = statePaused
					break
				}
			}
		}
	}

	return nil
}

// Draw renders the simulation state.
func (g *Game) Draw(screen *ebiten.Image) {
	screen.Fill(color.RGBA{20, 20, 25, 255})

	g.drawSubstrates(screen)
	g.drawResources(screen)
	g.drawAgents(screen)
	g.drawHUD(screen)
}

// Layout returns the logical screen dimensions.
func (g *Game) Layout(outsideWidth, outsideHeight int) (int, int) {
	return windowWidth, windowHeight
}

// drawSubstrates renders the substrate grid.
func (g *Game) drawSubstrates(screen *ebiten.Image) {
	w := g.engine.World
	cs := float32(g.cellSize)
	ox := float32(g.offsetX)
	oy := float32(g.offsetY)

	for y := 0; y < g.gridHeight; y++ {
		for x := 0; x < g.gridWidth; x++ {
			subID := w.Substrates.Get(x, y)
			clr := g.substrateColors[0]
			if int(subID) < len(g.substrateColors) {
				clr = g.substrateColors[subID]
			}

			px := ox + float32(x)*cs
			py := oy + float32(y)*cs

			// Skip off-screen cells.
			if px+cs < 0 || px > windowWidth || py+cs < 0 || py > windowHeight {
				continue
			}

			vector.FillRect(screen, px, py, cs-1, cs-1, clr, false)
		}
	}
}

// drawResources renders resource instances as colored squares.
func (g *Game) drawResources(screen *ebiten.Image) {
	w := g.engine.World
	r := w.Resources
	cs := g.cellSize
	ox := g.offsetX
	oy := g.offsetY

	resourceColors := []color.RGBA{
		{0, 200, 255, 200},   // Type 0: cyan (water).
		{255, 255, 100, 200}, // Type 1: yellow (sugar).
		{255, 180, 50, 200},  // Type 2: orange (fat).
		{255, 80, 80, 200},   // Type 3: red (protein).
		{100, 255, 100, 200}, // Type 4: green (oviposition).
	}

	for i := 0; i < r.Count; i++ {
		px := float32(ox + r.PosX[i]*cs)
		py := float32(oy + r.PosY[i]*cs)

		if px < -10 || px > windowWidth+10 || py < -10 || py > windowHeight+10 {
			continue
		}

		typeIdx := int(r.TypeID[i])
		clr := color.RGBA{200, 200, 200, 200}
		if typeIdx < len(resourceColors) {
			clr = resourceColors[typeIdx]
		}

		size := float32(cs * 0.8)
		if size < 4 {
			size = 4
		}
		vector.FillRect(screen, px-size/2, py-size/2, size, size, clr, false)
	}
}

// drawAgents renders agents as colored circles with direction indicators.
func (g *Game) drawAgents(screen *ebiten.Image) {
	w := g.engine.World
	a := w.Agents
	cs := g.cellSize
	ox := g.offsetX
	oy := g.offsetY

	radius := float32(cs * 0.4)
	if radius < 2 {
		radius = 2
	}

	for i := 0; i < a.Count; i++ {
		px := float32(ox + a.PosX[i]*cs)
		py := float32(oy + a.PosY[i]*cs)

		if px < -10 || px > windowWidth+10 || py < -10 || py > windowHeight+10 {
			continue
		}

		// Color by sex.
		var clr color.RGBA
		switch a.Sex[i] {
		case world.SexMale:
			clr = color.RGBA{80, 130, 255, 230}
		case world.SexFemale:
			clr = color.RGBA{255, 100, 180, 230}
		default:
			clr = color.RGBA{200, 200, 200, 200} // Immature.
		}

		// Dead agents flash red (shouldn't normally appear, but just in case).
		if a.Situation[i] == world.SituationDead {
			clr = color.RGBA{255, 0, 0, 150}
		}

		// Draw body.
		vector.FillCircle(screen, px, py, radius, clr, false)

		// Draw direction indicator (small line pointing forward).
		if a.Direction[i] >= 1 && a.Direction[i] <= 8 {
			dirX, dirY := directionVector(a.Direction[i])
			lineLen := float32(cs * 0.5)
			ex := px + float32(dirX)*lineLen
			ey := py + float32(dirY)*lineLen
			vector.StrokeLine(screen, px, py, ex, ey, 1.5, color.RGBA{255, 255, 255, 150}, false)
		}
	}
}

// drawHUD renders the heads-up display with stats and controls.
func (g *Game) drawHUD(screen *ebiten.Image) {
	w := g.engine.World
	stateStr := "PAUSED"
	if g.state == stateRunning {
		stateStr = "RUNNING"
	}

	speedStr := fmt.Sprintf("%dx", g.ticksPerFrame)
	if g.maxSpeed {
		speedStr = "MAX"
	}

	info := fmt.Sprintf(
		"Tick: %d | Agents: %d | Eggs: %d | %s | Speed: %s\nFPS: %.0f | [Space]=Play/Pause [Esc]=Quit [Up/Down]=Speed [M]=MaxSpeed [Scroll]=Zoom [Drag]=Pan",
		w.Tick, w.Agents.Count, w.Eggs.Count, stateStr, speedStr,
		ebiten.ActualFPS(),
	)

	ebitenutil.DebugPrint(screen, info)
}

// --- Helpers ---

// directionVector returns a normalized (dx, dy) for a direction code (1-8).
func directionVector(dir uint8) (float64, float64) {
	switch dir {
	case 1:
		return -0.707, -0.707 // NW
	case 2:
		return 0, -1 // N
	case 3:
		return 0.707, -0.707 // NE
	case 4:
		return -1, 0 // W
	case 5:
		return 1, 0 // E
	case 6:
		return -0.707, 0.707 // SW
	case 7:
		return 0, 1 // S
	case 8:
		return 0.707, 0.707 // SE
	default:
		return 0, 0
	}
}

// hueToRGBA converts HSV (hue in [0,1], sat, val) to RGBA.
func hueToRGBA(h, s, v float64) color.RGBA {
	h6 := h * 6
	i := int(h6)
	f := h6 - float64(i)
	p := v * (1 - s)
	q := v * (1 - s*f)
	t := v * (1 - s*(1-f))

	var r, g, b float64
	switch i % 6 {
	case 0:
		r, g, b = v, t, p
	case 1:
		r, g, b = q, v, p
	case 2:
		r, g, b = p, v, t
	case 3:
		r, g, b = p, q, v
	case 4:
		r, g, b = t, p, v
	case 5:
		r, g, b = v, p, q
	}

	return color.RGBA{
		R: uint8(r * 255),
		G: uint8(g * 255),
		B: uint8(b * 255),
		A: 255,
	}
}

// inputJustPressed returns true on the frame a key is first pressed.
var prevKeys = make(map[ebiten.Key]bool)

func inputJustPressed(key ebiten.Key) bool {
	pressed := ebiten.IsKeyPressed(key)
	was := prevKeys[key]
	prevKeys[key] = pressed
	return pressed && !was
}

// --- Main ---

const guiVersion = "2.0.0"

func main() {
	filePath := flag.String("file", "", "Path to the project database (.db file) [required]")
	envName := flag.String("env", "", "Environment name to simulate (auto-selected if only one)")
	envID := flag.Int64("env-id", 0, "Environment ID to simulate (alternative to --env)")
	speed := flag.Int("speed", 1, "Initial simulation speed (ticks per frame)")
	width := flag.Int("width", windowWidth, "Window width in pixels")
	height := flag.Int("height", windowHeight, "Window height in pixels")
	showVersion := flag.Bool("version", false, "Show version and exit")

	flag.Usage = func() {
		fmt.Fprintf(os.Stderr, "Galatea Simulation Visualizer v%s\n\n", guiVersion)
		fmt.Fprintf(os.Stderr, "Usage:\n")
		fmt.Fprintf(os.Stderr, "  galatea --file project.db [options]\n\n")
		fmt.Fprintf(os.Stderr, "Options:\n")
		flag.PrintDefaults()
		fmt.Fprintf(os.Stderr, "\nControls:\n")
		fmt.Fprintf(os.Stderr, "  Space       Start/Pause simulation\n")
		fmt.Fprintf(os.Stderr, "  Escape      Quit\n")
		fmt.Fprintf(os.Stderr, "  Up/Down     Double/halve tick speed\n")
		fmt.Fprintf(os.Stderr, "  M           Toggle max-speed mode\n")
		fmt.Fprintf(os.Stderr, "  Scroll      Zoom in/out\n")
		fmt.Fprintf(os.Stderr, "  Left-drag   Pan viewport\n")
	}

	flag.Parse()

	if *showVersion {
		fmt.Printf("galatea v%s\n", guiVersion)
		return
	}

	if *filePath == "" {
		flag.Usage()
		fmt.Fprintf(os.Stderr, "\nerror: --file is required\n")
		os.Exit(1)
	}

	if err := runFromDB(*filePath, *envName, *envID, *speed, *width, *height); err != nil {
		log.Fatalf("Error: %v", err)
	}
}

// runFromDB opens an existing project database and launches the visualizer.
func runFromDB(dbPath string, envName string, envID int64, initialSpeed, winW, winH int) error {
	if _, err := os.Stat(dbPath); os.IsNotExist(err) {
		return fmt.Errorf("file not found: %s", dbPath)
	}

	db, err := storage.Open(dbPath)
	if err != nil {
		return fmt.Errorf("open db: %w", err)
	}
	defer db.Close()

	// Resolve environment.
	resolvedID, resolvedName, err := storage.ResolveEnvironment(db, envName, envID)
	if err != nil {
		return err
	}

	fmt.Printf("Galatea Visualizer v%s\n", guiVersion)
	fmt.Printf("Project: %s | Environment: %s (id=%d)\n\n", dbPath, resolvedName, resolvedID)

	cfg := kernel.DefaultEngineConfig(resolvedID)
	cfg.WriteBufferCfg = storage.WriteBufferConfig{MaxRecords: 50000, TickInterval: 500}
	engine, err := kernel.Build(db, cfg)
	if err != nil {
		return fmt.Errorf("build engine: %w", err)
	}

	// Give agents reserves if they have none (bootstrap for visualization).
	bootstrapAgentReserves(engine)

	game := NewGame(engine)
	game.ticksPerFrame = initialSpeed

	ebiten.SetWindowSize(winW, winH)
	ebiten.SetWindowTitle(fmt.Sprintf("Galatea — %s", resolvedName))
	ebiten.SetWindowResizingMode(ebiten.WindowResizingModeEnabled)

	return ebiten.RunGame(game)
}

func bootstrapAgentReserves(engine *kernel.Engine) {
	a := engine.World.Agents
	numNut := engine.World.Config.NumNutrients
	for i := 0; i < a.Count; i++ {
		for n := 0; n < numNut; n++ {
			if a.Reserves[i*numNut+n] <= 0 {
				a.Reserves[i*numNut+n] = 5000 // High reserves for long survival.
			}
		}
		if a.Speed[i] <= 0 {
			a.Speed[i] = 1
		}
		if a.Direction[i] == 0 {
			a.Direction[i] = uint8(1 + i%8)
		}
	}
}
