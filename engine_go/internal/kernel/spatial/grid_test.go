package spatial

import (
	"math"
	"math/rand/v2"
	"testing"
)

func TestInsertAndQueryNeighbors(t *testing.T) {
	g := NewGrid(10.0, 64)

	// Place agents in a 3x3 pattern centered around (15, 15).
	g.Insert(0, 15, 15) // Center cell (1,1)
	g.Insert(1, 5, 5)   // Cell (0,0)
	g.Insert(2, 25, 25) // Cell (2,2)
	g.Insert(3, 15, 5)  // Cell (1,0)
	g.Insert(4, 55, 55) // Cell (5,5) — far away

	// Query neighbors of (15, 15) — should find agents in cells (0,0)-(2,2).
	results := g.QueryNeighbors(15, 15)

	found := make(map[int32]bool)
	for _, idx := range results {
		found[idx] = true
	}

	// Agents 0,1,2,3 should be within the Moore neighborhood.
	for _, expected := range []int32{0, 1, 2, 3} {
		if !found[expected] {
			t.Errorf("expected agent %d in neighbors, not found", expected)
		}
	}
	// Agent 4 should NOT be found.
	if found[4] {
		t.Error("agent 4 should not be in neighbors")
	}
}

func TestRemove(t *testing.T) {
	g := NewGrid(10.0, 64)

	g.Insert(0, 5, 5)
	g.Insert(1, 5, 5) // Same cell as 0.
	g.Insert(2, 5, 5)

	g.Remove(1)

	results := g.QueryNeighbors(5, 5)
	found := make(map[int32]bool)
	for _, idx := range results {
		found[idx] = true
	}

	if found[1] {
		t.Error("removed agent 1 still found")
	}
	if !found[0] || !found[2] {
		t.Error("agents 0 and 2 should still be present")
	}
}

func TestMove(t *testing.T) {
	g := NewGrid(10.0, 64)

	g.Insert(0, 5, 5)   // Cell (0,0)
	g.Insert(1, 55, 55) // Cell (5,5)

	// Move agent 0 to cell (5,5).
	g.Move(0, 55, 55)

	// Query around original position — agent 0 should NOT be there.
	results := g.QueryNeighbors(5, 5)
	for _, idx := range results {
		if idx == 0 {
			t.Error("moved agent 0 still found at old position")
		}
	}

	// Query around new position — both 0 and 1 should be there.
	results = g.QueryNeighbors(55, 55)
	found := make(map[int32]bool)
	for _, idx := range results {
		found[idx] = true
	}
	if !found[0] {
		t.Error("agent 0 not found at new position")
	}
	if !found[1] {
		t.Error("agent 1 not found")
	}
}

func TestMoveSameCell(t *testing.T) {
	g := NewGrid(10.0, 64)

	g.Insert(0, 5, 5)
	// Move within same cell — should be a no-op internally.
	g.Move(0, 7, 8)

	results := g.QueryNeighbors(5, 5)
	found := false
	for _, idx := range results {
		if idx == 0 {
			found = true
		}
	}
	if !found {
		t.Error("agent 0 should still be found in same cell")
	}
}

func TestQueryRadiusExact(t *testing.T) {
	g := NewGrid(5.0, 64)

	// Place agents at known positions.
	posX := []float64{0, 3, 7, 10, 50}
	posY := []float64{0, 4, 7, 10, 50}

	for i := range posX {
		g.Insert(int32(i), posX[i], posY[i])
	}

	// Query radius 5 from origin (0,0).
	results := g.QueryRadiusExact(0, 0, 5.0, posX, posY)

	found := make(map[int32]bool)
	for _, idx := range results {
		found[idx] = true
	}

	// Agent 0: dist=0 ✓
	// Agent 1: dist=5 ✓ (3²+4²=25, √25=5)
	// Agent 2: dist≈9.9 ✗
	// Agent 3: dist≈14.1 ✗
	// Agent 4: dist≈70.7 ✗
	if !found[0] {
		t.Error("agent 0 (dist=0) should be found")
	}
	if !found[1] {
		t.Error("agent 1 (dist=5) should be found")
	}
	if found[2] {
		t.Error("agent 2 (dist≈9.9) should NOT be found")
	}
	if found[3] {
		t.Error("agent 3 should NOT be found")
	}
	if found[4] {
		t.Error("agent 4 should NOT be found")
	}
}

func TestQueryRadius(t *testing.T) {
	g := NewGrid(10.0, 64)

	g.Insert(0, 5, 5)
	g.Insert(1, 15, 15)
	g.Insert(2, 95, 95) // Far away.

	// Broad query: returns candidates within cell range, not exact distance.
	results := g.QueryRadius(10, 10, 10)

	found := make(map[int32]bool)
	for _, idx := range results {
		found[idx] = true
	}

	// Both 0 and 1 are within cells covered by radius 10 around (10,10).
	if !found[0] {
		t.Error("agent 0 should be candidate")
	}
	if !found[1] {
		t.Error("agent 1 should be candidate")
	}
	if found[2] {
		t.Error("agent 2 should NOT be candidate")
	}
}

func TestClear(t *testing.T) {
	g := NewGrid(10.0, 64)

	for i := 0; i < 20; i++ {
		g.Insert(int32(i), float64(i*5), float64(i*5))
	}

	g.Clear()

	results := g.QueryNeighbors(25, 25)
	if len(results) != 0 {
		t.Fatalf("expected 0 results after clear, got %d", len(results))
	}
}

func TestRebuild(t *testing.T) {
	g := NewGrid(10.0, 64)

	posX := make([]float64, 20)
	posY := make([]float64, 20)
	for i := range posX {
		posX[i] = float64(i * 3)
		posY[i] = float64(i * 3)
	}

	g.Rebuild(20, posX, posY)

	// Query around agent 10 (pos 30,30).
	results := g.QueryNeighbors(30, 30)
	if len(results) == 0 {
		t.Fatal("expected results after rebuild")
	}

	// Agent 10 should be in results.
	found := false
	for _, idx := range results {
		if idx == 10 {
			found = true
		}
	}
	if !found {
		t.Error("agent 10 not found after rebuild")
	}
}

func TestCorrectnessVsBruteForce(t *testing.T) {
	const numAgents = 500
	const numQueries = 50
	const worldSize = 200.0
	const radius = 15.0

	g := NewGrid(radius, numAgents)

	posX := make([]float64, numAgents)
	posY := make([]float64, numAgents)

	for i := 0; i < numAgents; i++ {
		posX[i] = rand.Float64() * worldSize
		posY[i] = rand.Float64() * worldSize
		g.Insert(int32(i), posX[i], posY[i])
	}

	// Run random queries and compare with brute force.
	for q := 0; q < numQueries; q++ {
		cx := rand.Float64() * worldSize
		cy := rand.Float64() * worldSize

		// Spatial hash result.
		gridResults := g.QueryRadiusExact(cx, cy, radius, posX, posY)
		gridSet := make(map[int32]bool)
		for _, idx := range gridResults {
			gridSet[idx] = true
		}

		// Brute force result.
		radiusSq := radius * radius
		for i := 0; i < numAgents; i++ {
			dx := posX[i] - cx
			dy := posY[i] - cy
			distSq := dx*dx + dy*dy

			inBrute := distSq <= radiusSq
			inGrid := gridSet[int32(i)]

			if inBrute && !inGrid {
				t.Fatalf("query %d: agent %d (dist=%.2f) missed by grid (pos=(%.1f,%.1f) query=(%.1f,%.1f))",
					q, i, math.Sqrt(distSq), posX[i], posY[i], cx, cy)
			}
			if !inBrute && inGrid {
				t.Fatalf("query %d: agent %d (dist=%.2f) false positive in grid",
					q, i, math.Sqrt(distSq))
			}
		}
	}
}

func TestNegativeCoordinates(t *testing.T) {
	g := NewGrid(10.0, 64)

	g.Insert(0, -5, -5)
	g.Insert(1, -15, -15)
	g.Insert(2, 5, 5)

	results := g.QueryNeighbors(-5, -5)
	found := make(map[int32]bool)
	for _, idx := range results {
		found[idx] = true
	}

	if !found[0] {
		t.Error("agent 0 not found")
	}
	if !found[1] {
		t.Error("agent 1 should be in adjacent cell")
	}
	if !found[2] {
		t.Error("agent 2 should be in adjacent cell")
	}
}

// --- Benchmarks ---

func BenchmarkInsert10K(b *testing.B) {
	positions := generatePositions(10000, 1000.0)
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		g := NewGrid(15.0, 10000)
		for j := 0; j < 10000; j++ {
			g.Insert(int32(j), positions[j*2], positions[j*2+1])
		}
	}
}

func BenchmarkQueryRadius10K(b *testing.B) {
	const n = 10000
	g := NewGrid(15.0, n)
	posX := make([]float64, n)
	posY := make([]float64, n)
	for i := 0; i < n; i++ {
		posX[i] = rand.Float64() * 1000
		posY[i] = rand.Float64() * 1000
		g.Insert(int32(i), posX[i], posY[i])
	}

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		cx := rand.Float64() * 1000
		cy := rand.Float64() * 1000
		g.QueryRadiusExact(cx, cy, 15.0, posX, posY)
	}
}

func BenchmarkQueryRadius50K(b *testing.B) {
	const n = 50000
	g := NewGrid(15.0, n)
	posX := make([]float64, n)
	posY := make([]float64, n)
	for i := 0; i < n; i++ {
		posX[i] = rand.Float64() * 2000
		posY[i] = rand.Float64() * 2000
		g.Insert(int32(i), posX[i], posY[i])
	}

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		cx := rand.Float64() * 2000
		cy := rand.Float64() * 2000
		g.QueryRadiusExact(cx, cy, 15.0, posX, posY)
	}
}

func BenchmarkQueryNeighbors10K(b *testing.B) {
	const n = 10000
	g := NewGrid(15.0, n)
	for i := 0; i < n; i++ {
		g.Insert(int32(i), rand.Float64()*1000, rand.Float64()*1000)
	}

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		g.QueryNeighbors(rand.Float64()*1000, rand.Float64()*1000)
	}
}

func BenchmarkMove10K(b *testing.B) {
	const n = 10000
	g := NewGrid(15.0, n)
	for i := 0; i < n; i++ {
		g.Insert(int32(i), rand.Float64()*1000, rand.Float64()*1000)
	}

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		idx := int32(rand.IntN(n))
		g.Move(idx, rand.Float64()*1000, rand.Float64()*1000)
	}
}

func generatePositions(n int, worldSize float64) []float64 {
	pos := make([]float64, n*2)
	for i := range pos {
		pos[i] = rand.Float64() * worldSize
	}
	return pos
}
