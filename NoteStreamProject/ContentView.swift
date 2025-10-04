//
//  ContentView.swift
//  NoteStreamProject
//
//  Created by Jade Keegan and Ajay Gandecha on 10/3/25.
//

import SwiftUI
import PencilKit

struct ContentView: View {
    
    @Environment(\.undoManager) private var undoManager
    @State private var canvasView = PKCanvasView()
    
    var body: some View {
            VStack(spacing: 10) {
                Button("Clear") {
                    canvasView.drawing = PKDrawing()
                }
                Button("Undo") {
                    undoManager?.undo()
                }
                Button("Redo") {
                    undoManager?.redo()
                }
                MyCanvas(canvasView: $canvasView)
            }
        }
}

#Preview {
    ContentView()
}
