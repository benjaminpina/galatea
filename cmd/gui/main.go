package main

import (
	"embed"

	"github.com/benjaminpina/galatea/internal/wire"
	"github.com/wailsapp/wails/v2"
	"github.com/wailsapp/wails/v2/pkg/options"
	"github.com/wailsapp/wails/v2/pkg/options/assetserver"
)

//go:embed all:frontend/dist
var assets embed.FS

func main() {
	// Create an instance of the app structure
	app := NewApp()

	// Initialize GUI with dependency injection
	guiApp, err := wire.InitializeGUI()
	if err != nil {
		println("Error initializing GUI:", err.Error())
		return
	}

	// Create CRUD instances
	substrateCRUD := NewSubstrateCRUD(guiApp.SubstrateAdapter)
	mixedSubstrateCRUD := NewMixedSubstrateCRUD(guiApp.MixedSubstrateAdapter)
	substrateSetCRUD := NewSubstrateSetCRUD(guiApp.SubstrateSetAdapter)
	
	// Create file operation instances
	substrateFileOps := NewSubstrateFileOperations(guiApp.SubstrateFileAdapter, guiApp.SubstrateAdapter.GetService())
	mixedSubstrateFileOps := NewMixedSubstrateFileOperations(guiApp.MixedSubstrateFileAdapter, guiApp.MixedSubstrateAdapter.GetService())
	substrateSetFileOps := NewSubstrateSetFileOperations(guiApp.SubstrateSetFileAdapter, guiApp.SubstrateSetAdapter.GetService())

	// Create application with options
	err = wails.Run(&options.App{
		Title:  "Galatea",
		Width:  1024,
		Height: 768,
		AssetServer: &assetserver.Options{
			Assets: assets,
		},
		BackgroundColour: &options.RGBA{R: 27, G: 38, B: 54, A: 1},
		OnStartup:        app.startup,
		Bind: []any{
			app,
			substrateCRUD,
			mixedSubstrateCRUD,
			substrateSetCRUD,
			substrateFileOps,
			mixedSubstrateFileOps,
			substrateSetFileOps,
		},
	})

	if err != nil {
		println("Error:", err.Error())
	}
}
