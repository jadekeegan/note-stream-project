//
//  NoteViewModel.swift
//  NoteStreamProject
//
//  Created by Ajay Gandecha on 10/4/25.
//

import SwiftUI
import PencilKit

/// View model that maintains all active state for the notes feature.
@Observable class NoteViewModel {
    
    // TODO: Refactor this to store a list of canvas views for multi-page support
    /// PencilKit canvas view that is used to store all of the stroke data for the canvas.
    var canvasView: PKCanvasView = PKCanvasView()
    
    /// Changes the canvas's active tool to draw based on user settings.
    func selectDrawingTool() {
        canvasView.tool = PKInkingTool(.monoline, color: .blue, width: 20)
    }
    
    /// Changes the canvas's active tool to the eraser based on user settings.
    func selectEraserTool() {
        canvasView.tool = PKEraserTool(.bitmap, width: 20)
    }
}
