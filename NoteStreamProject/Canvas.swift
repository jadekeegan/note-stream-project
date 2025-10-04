//
//  Canvas.swift
//  NoteStreamProject
//
//  Created by Jade Keegan and Ajay Gandecha on 10/3/25.
//

import SwiftUI
import UIKit
import PencilKit

struct MyCanvas: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 15)
        return canvasView
    }

    func updateUIView(_ canvasView: PKCanvasView, context: Context) { }
}
