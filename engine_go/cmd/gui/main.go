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

	// Nutrient/resource color cache (index = nutrient type 0-based).
	nutrientColors []color.RGBA

	// Prototype color cache (index = prototype ID).
	prototypeColors []color.RGBA

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

// NewGame creates a new visualizer game from an engine and colors from DB.
func NewGame(engine *kernel.Engine, substrateColors, nutrientColors, prototypeColors []color.RGBA) *Game {
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

	return &Game{
		engine:          engine,
		state:           statePaused,
		cellSize:        cellSize,
		gridWidth:       cfg.GridWidth,
		gridHeight:      cfg.GridHeight,
		substrateColors: substrateColors,
		nutrientColors:  nutrientColors,
		prototypeColors: prototypeColors,
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

// drawResources renders resource instances as colored diamonds centered in cells.
func (g *Game) drawResources(screen *ebiten.Image) {
	w := g.engine.World
	r := w.Resources
	cs := g.cellSize
	ox := g.offsetX
	oy := g.offsetY

	for i := 0; i < r.Count; i++ {
		// Center within the cell.
		px := float32(ox + (r.PosX[i]+0.5)*cs)
		py := float32(oy + (r.PosY[i]+0.5)*cs)

		if px < -10 || px > windowWidth+10 || py < -10 || py > windowHeight+10 {
			continue
		}

		typeIdx := int(r.TypeID[i])
		clr := color.RGBA{200, 200, 200, 200}
		if typeIdx < len(g.nutrientColors) {
			clr = g.nutrientColors[typeIdx]
		}

		size := float32(cs * 0.7)
		if size < 4 {
			size = 4
		}
		half := size / 2
		// Draw as a small diamond.
		vector.FillRect(screen, px-half, py-half, size, size, clr, false)
		// Border.
		vector.StrokeRect(screen, px-half, py-half, size, size, 1, color.RGBA{255, 255, 255, 60}, false)
	}
}

// drawAgents renders agents as two-circle "bugs" (body + head) centered in cells.
// Body color = prototype color, Head color = sex color (blue/pink).
func (g *Game) drawAgents(screen *ebiten.Image) {
	w := g.engine.World
	a := w.Agents
	cs := g.cellSize
	ox := g.offsetX
	oy := g.offsetY

	r := float32(cs * 0.4)
	if r < 2 {
		r = 2
	}

	for i := 0; i < a.Count; i++ {
		// Center within the cell.
		cx := float32(ox + (a.PosX[i]+0.5)*cs)
		cy := float32(oy + (a.PosY[i]+0.5)*cs)

		if cx < -20 || cx > windowWidth+20 || cy < -20 || cy > windowHeight+20 {
			continue
		}

		// Head color by sex.
		var headClr color.RGBA
		isMale := a.Sex[i] == world.SexMale
		if isMale {
			headClr = color.RGBA{85, 153, 238, 255} // Blue
		} else {
			headClr = color.RGBA{238, 102, 153, 255} // Pink
		}

		// Body color by prototype.
		bodyClr := color.RGBA{80, 80, 100, 255} // Default
		protoIdx := int(a.PrototypeID[i])
		if protoIdx >= 0 && protoIdx < len(g.prototypeColors) {
			bodyClr = g.prototypeColors[protoIdx]
		}

		// Dead agents: gray out.
		if a.Situation[i] == world.SituationDead {
			bodyClr = color.RGBA{100, 50, 50, 150}
			headClr = color.RGBA{150, 50, 50, 150}
		}

		// Direction vector for orienting the bug.
		dirX, dirY := directionVector(a.Direction[i])

		// Body: larger circle offset backward from center.
		bodyR := r * 0.55
		bodyX := cx - float32(dirX)*r*0.2
		bodyY := cy - float32(dirY)*r*0.2
		vector.FillCircle(screen, bodyX, bodyY, bodyR, bodyClr, false)
		vector.StrokeCircle(screen, bodyX, bodyY, bodyR, 0.8, color.RGBA{0, 0, 0, 80}, false)

		// Head: smaller circle offset forward from center.
		headR := r * 0.38
		headX := cx + float32(dirX)*r*0.4
		headY := cy + float32(dirY)*r*0.4
		vector.FillCircle(screen, headX, headY, headR, headClr, false)
		vector.StrokeCircle(screen, headX, headY, headR, 0.8, color.RGBA{0, 0, 0, 100}, false)

		// Eyes (only if zoomed in enough).
		if cs >= 10 {
			eyeR := headR * 0.25
			// Perpendicular to direction for eye spread.
			perpX := float32(-dirY)
			perpY := float32(dirX)
			eyeSpread := headR * 0.45
			eyeFwd := headR * 0.35

			e1x := headX + float32(dirX)*eyeFwd + perpX*eyeSpread
			e1y := headY + float32(dirY)*eyeFwd + perpY*eyeSpread
			e2x := headX + float32(dirX)*eyeFwd - perpX*eyeSpread
			e2y := headY + float32(dirY)*eyeFwd - perpY*eyeSpread

			white := color.RGBA{255, 255, 255, 255}
			vector.FillCircle(screen, e1x, e1y, eyeR, white, false)
			vector.FillCircle(screen, e2x, e2y, eyeR, white, false)
		}

		// Egg indicator for females.
		if !isMale && a.FertilizedCount[i] > 0 {
			vector.FillCircle(screen, bodyX, bodyY, bodyR*0.3, color.RGBA{255, 255, 255, 220}, false)
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

	// Load substrate colors from DB.
	subColors := loadSubstrateColors(db, engine.World.Config.NumSubstrates)

	// Load nutrient colors from DB.
	nutColors := loadNutrientColors(db, engine.World.Config.NumNutrients)

	// Load prototype colors from DB.
	protoColors := loadPrototypeColors(db, engine.World.Config.NumPrototypes)

	game := NewGame(engine, subColors, nutColors, protoColors)
	game.ticksPerFrame = initialSpeed

	ebiten.SetWindowSize(winW, winH)
	ebiten.SetWindowTitle(fmt.Sprintf("Galatea — %s", resolvedName))
	ebiten.SetWindowResizingMode(ebiten.WindowResizingModeEnabled)

	return ebiten.RunGame(game)
}

// loadNutrientColors reads nutrient colors from the DB.
// Index 0-based corresponds to nutrient type index (TypeID in resources).
func loadNutrientColors(db *storage.DB, numNutrients int) []color.RGBA {
	colors := make([]color.RGBA, numNutrients)
	for i := range colors {
		colors[i] = color.RGBA{200, 200, 200, 200} // Default gray.
	}

	rows, err := db.Conn.Query("SELECT id, color FROM nutrients ORDER BY sort_order")
	if err != nil {
		return colors
	}
	defer rows.Close()

	for rows.Next() {
		var id int64
		var colorVal int
		if err := rows.Scan(&id, &colorVal); err != nil {
			continue
		}
		idx := int(id - 1) // 1-based ID to 0-based index.
		if idx >= 0 && idx < numNutrients {
			r := uint8((colorVal >> 16) & 0xFF)
			g := uint8((colorVal >> 8) & 0xFF)
			b := uint8(colorVal & 0xFF)
			colors[idx] = color.RGBA{r, g, b, 200}
		}
	}
	return colors
}

// Index 0 = empty/default (black), indices 1..N correspond to substrate IDs.
func loadSubstrateColors(db *storage.DB, numSubstrates int) []color.RGBA {
	colors := make([]color.RGBA, numSubstrates+1)
	colors[0] = color.RGBA{20, 20, 25, 255} // Empty cell.

	rows, err := db.Conn.Query("SELECT id, color FROM substrates ORDER BY sort_order")
	if err != nil {
		return colors
	}
	defer rows.Close()

	for rows.Next() {
		var id int64
		var colorVal int
		if err := rows.Scan(&id, &colorVal); err != nil {
			continue
		}
		if int(id) <= numSubstrates {
			r := uint8((colorVal >> 16) & 0xFF)
			g := uint8((colorVal >> 8) & 0xFF)
			b := uint8(colorVal & 0xFF)
			colors[id] = color.RGBA{r, g, b, 255}
		}
	}
	return colors
}

// loadPrototypeColors reads prototype colors from the DB.
// Index 0-based corresponds to prototype internal index (PrototypeID in agents).
func loadPrototypeColors(db *storage.DB, numPrototypes int) []color.RGBA {
	colors := make([]color.RGBA, numPrototypes)
	for i := range colors {
		colors[i] = color.RGBA{80, 80, 100, 255} // Default dark gray.
	}

	rows, err := db.Conn.Query("SELECT id, color FROM prototypes ORDER BY sort_order")
	if err != nil {
		return colors
	}
	defer rows.Close()

	for rows.Next() {
		var id int64
		var colorVal int
		if err := rows.Scan(&id, &colorVal); err != nil {
			continue
		}
		idx := int(id - 1) // 1-based ID to 0-based index.
		if idx >= 0 && idx < numPrototypes {
			r := uint8((colorVal >> 16) & 0xFF)
			g := uint8((colorVal >> 8) & 0xFF)
			b := uint8(colorVal & 0xFF)
			colors[idx] = color.RGBA{r, g, b, 255}
		}
	}
	return colors
}
