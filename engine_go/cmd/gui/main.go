// Command galatea is the 2D visualizer for the Galatea simulation suite.
// It renders the simulation state in real-time using Ebitengine and provides
// basic controls: Space=start/pause, Escape=quit.
package main

import (
	"fmt"
	"image/color"
	"log"
	"math"
	"os"
	"path/filepath"
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

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: galatea <workspace_path>")
		fmt.Println("       galatea path/to/project/galatea.db")
		fmt.Println("")
		fmt.Println("If no argument provided, runs a self-contained demo.")
		runDemo()
		return
	}

	dbPath := os.Args[1]
	if err := runFromDB(dbPath); err != nil {
		log.Fatalf("Error: %v", err)
	}
}

// runFromDB opens an existing project database and launches the visualizer.
func runFromDB(dbPath string) error {
	db, err := storage.Open(dbPath)
	if err != nil {
		return fmt.Errorf("open db: %w", err)
	}
	defer db.Close()

	// Find the first environment.
	envRepo := storage.NewEnvironmentRepo(db)
	envs, err := envRepo.List()
	if err != nil || len(envs) == 0 {
		return fmt.Errorf("no environments found in database")
	}

	cfg := kernel.DefaultEngineConfig(envs[0].ID)
	cfg.Longevity = 2000
	engine, err := kernel.Build(db, cfg)
	if err != nil {
		return fmt.Errorf("build engine: %w", err)
	}

	// Give agents reserves if they have none (bootstrap for visualization).
	bootstrapAgentReserves(engine)

	return launchVisualizer(engine)
}

// runDemo creates a self-contained demo world and launches the visualizer.
func runDemo() {
	wsDir := filepath.Join(os.TempDir(), "galatea_demo")
	dbPath := filepath.Join(wsDir, "galatea.db")
	os.RemoveAll(wsDir)

	db, err := storage.Open(dbPath)
	if err != nil {
		log.Fatalf("open db: %v", err)
	}
	defer func() {
		db.Close()
		os.RemoveAll(wsDir)
	}()

	populateDemoProject(db)

	cfg := kernel.DefaultEngineConfig(1)
	cfg.Longevity = 5000
	engine, err := kernel.Build(db, cfg)
	if err != nil {
		log.Fatalf("build engine: %v", err)
	}

	bootstrapAgentReserves(engine)

	if err := launchVisualizer(engine); err != nil {
		log.Fatalf("visualizer: %v", err)
	}
}

func launchVisualizer(engine *kernel.Engine) error {
	game := NewGame(engine)

	ebiten.SetWindowSize(windowWidth, windowHeight)
	ebiten.SetWindowTitle("Galatea — Simulation Visualizer")
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

func populateDemoProject(db *storage.DB) {
	projRepo := storage.NewProjectInfoRepo(db)
	projRepo.Init("Visual Demo", "Self-contained demo for the visualizer")

	nutRepo := storage.NewNutrientRepo(db)
	nutRepo.Create("Water", 0, 1)
	nutRepo.Create("Sugar", 0, 2)
	nutRepo.Create("Fat", 0, 3)

	subRepo := storage.NewSubstrateRepo(db)
	subRepo.Create("Grass", 0x228B22, false, 1)
	subRepo.Create("Sand", 0xC2B280, false, 2)
	subRepo.Create("Water", 0x1E90FF, false, 3)
	subRepo.Create("Rock", 0x696969, false, 4)
	subRepo.Create("Forest", 0x006400, false, 5)

	locRepo := storage.NewLocusRepo(db)
	locRepo.Create(&storage.Locus{Name: "Size", IsContinuous: true, DominantValue: 1, RecessiveValue: 0.5, SortOrder: 1, DefaultExpression: "0"})
	locRepo.Create(&storage.Locus{Name: "Speed", IsContinuous: true, DominantValue: 1, RecessiveValue: 0.5, SortOrder: 2, DefaultExpression: "0"})

	stageRepo := storage.NewStageRepo(db)
	stageRepo.Create(&storage.Stage{
		Name: "Juvenile", SortOrder: 1, CyclesFormula: "100",
		Condition1Formula: "0", Condition1Op: ">", Condition1Value: 0,
		Condition2Formula: "0", Condition2Op: ">", Condition2Value: 0,
		LogicCyclesReqs: "AND", LogicReqsConds: "AND", LogicCond1Cond2: "AND", Color: 0x00FF00,
	})

	protoRepo := storage.NewPrototypeRepo(db)
	protoRepo.Create(&storage.Prototype{
		Name: "MaleA", Sex: "M", LongevityFormula: "5000",
		RefractoryCombatFormula: "10", RefractoryCourtshipFormula: "15",
		SexRatioMalesFormula: "50", SexRatioFemalesFormula: "50", SortOrder: 1,
	})
	protoRepo.Create(&storage.Prototype{
		Name: "FemaleA", Sex: "F", LongevityFormula: "6000",
		RefractoryCombatFormula: "10", RefractoryCourtshipFormula: "15",
		SexRatioMalesFormula: "50", SexRatioFemalesFormula: "50", SortOrder: 1,
	})

	const gridSize = 60
	envRepo := storage.NewEnvironmentRepo(db)
	envID, _ := envRepo.Create("Demo Arena", gridSize, gridSize, "60x60 demo with substrate zones")

	// Paint substrate map with distinct zones.
	// Zone layout:
	//   Top-left: Grass (1)     Top-right: Sand (2)
	//   Center: Water (3) band
	//   Bottom-left: Forest (5) Bottom-right: Rock (4)
	for y := 0; y < gridSize; y++ {
		row := ""
		for x := 0; x < gridSize; x++ {
			var subID int
			switch {
			case y >= 28 && y <= 32: // Horizontal water band.
				subID = 3
			case x >= 28 && x <= 32 && y < 28: // Vertical water channel (top).
				subID = 3
			case x < 30 && y < 28:
				subID = 1 // Grass top-left.
			case x >= 30 && y < 28:
				subID = 2 // Sand top-right.
			case x < 30 && y > 32:
				subID = 5 // Forest bottom-left.
			default:
				subID = 4 // Rock bottom-right.
			}
			if x > 0 {
				row += ","
			}
			row += fmt.Sprintf("%d", subID)
		}
		db.Conn.Exec(
			"INSERT INTO substrate_map_rows (environment_id, y_coord, map_data) VALUES (?, ?, ?)",
			envID, y, row,
		)
	}

	// Place nutrient sources in appropriate zones.
	// Water sources along the water band (nutrient_id=1).
	for i := 0; i < 10; i++ {
		envRepo.PlaceSource(&storage.EnvironmentSource{
			EnvironmentID: envID, NutrientID: 1, Name: fmt.Sprintf("pool_%d", i),
			PosX: 5 + i*6, PosY: 30, Quality: 10, Level: 200, MaxLevel: 300, RegenRate: 1.08,
		})
	}
	// Sugar sources in the grass zone (nutrient_id=2).
	for i := 0; i < 10; i++ {
		envRepo.PlaceSource(&storage.EnvironmentSource{
			EnvironmentID: envID, NutrientID: 2, Name: fmt.Sprintf("flower_%d", i),
			PosX: 3 + i*3, PosY: 5 + i*2, Quality: 8, Level: 150, MaxLevel: 250, RegenRate: 1.1,
		})
	}
	// Fat sources in the forest zone (nutrient_id=3).
	for i := 0; i < 8; i++ {
		envRepo.PlaceSource(&storage.EnvironmentSource{
			EnvironmentID: envID, NutrientID: 3, Name: fmt.Sprintf("tree_%d", i),
			PosX: 5 + i*3, PosY: 40 + i*2, Quality: 12, Level: 180, MaxLevel: 300, RegenRate: 1.06,
		})
	}

	// Place 100 agents spread across the map.
	for i := 0; i < 100; i++ {
		sex := "M"
		protoID := int64(1)
		if i%2 == 1 {
			sex = "F"
			protoID = 2
		}
		// Distribute in a grid pattern with some offset.
		px := 5 + (i%10)*5 + i%3
		py := 5 + (i/10)*5 + i%4
		if px >= gridSize {
			px = gridSize - 2
		}
		if py >= gridSize {
			py = gridSize - 2
		}
		envRepo.PlaceAgent(&storage.EnvironmentAgent{
			EnvironmentID: envID, Name: fmt.Sprintf("a_%03d", i),
			PosX: px, PosY: py,
			PrototypeID: &protoID, Sex: sex, Age: 0,
		})
	}
}
