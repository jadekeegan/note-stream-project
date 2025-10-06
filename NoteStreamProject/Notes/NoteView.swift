//
//  NoteView.swift
//  NoteStreamProject
//
//  Created by Ajay Gandecha on 10/4/25.
//

import SwiftUI
import PencilKit

/// View where the user can interact with a notebook.
struct NoteView: View {
    
    // TODO: Refactor this note creation to pre-load notes.
    /// Initialize the view model for the view
    @State var vm = NoteViewModel()
    
    var body: some View {
        NavigationStack {
            NoteCanvasView(vm: $vm)
                .toolbar {
                    mainToolbar
                }
        }
    }
    
    // TODO: Consider refactoring to a separate view?
    /// Toolbar that contains primary drawing actions
    @ToolbarContentBuilder var mainToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .automatic) {
            Button("Draw", systemImage: "pencil") {
                vm.selectDrawingTool()
            }
            Button("Erase", systemImage: "eraser") {
                vm.selectEraserTool()
            }
        }
    }
}

#Preview {
    NoteView()
}
