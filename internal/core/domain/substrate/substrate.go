package substrate

type Substrate struct {
	ID    string
	Name  string
	Color string
}

// NewSubstrate creates a new substrate with the given ID, name, and color
func NewSubstrate(id, name, color string) *Substrate {
	return &Substrate{
		ID:    id,
		Name:  name,
		Color: color,
	}
}
