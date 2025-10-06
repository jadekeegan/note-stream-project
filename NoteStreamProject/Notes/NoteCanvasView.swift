//
//  NoteCanvasView.swift
//  NoteStreamProject
//
//  Created by Ajay Gandecha on 10/4/25.
//

import SwiftUI
import PencilKit

/// View that hooks into UIKit to provide the drawable canvas pages.
struct NoteCanvasView: UIViewRepresentable {

    /// Bind to the view model for the active note feature.
    @Binding var vm: NoteViewModel
    
    /// Change this to the paper size you want (points, not pixels).
    var pageSize: CGSize = CGSize(width: 1200, height: 1600)

    /// Coordinator object that serves as the UIViewDelegate for the scroll view.
    final class NoteCanvasCoordinator: NSObject, UIScrollViewDelegate {
        
        // Reference to the parent SwiftUI view.
        var parent: NoteCanvasView
        
        // Reference to the scroll view
        weak var scrollView: UIScrollView?
        
        // Reference to the page view
        weak var pageView: UIView?

        init(parent: NoteCanvasView) { self.parent = parent }

        // Scroll view delegate function that provides the view to be zoomed in the scroll area
        func viewForZooming(in scrollView: UIScrollView) -> UIView? { pageView }

        // Scroll view delegate function that performs an action when a zoom gesture occurs
        func scrollViewDidZoom(_ scrollView: UIScrollView) { center(scrollView) }
        
        // Scroll view delegate function that performs an action when a scroll gesture occurs
        func scrollViewDidScroll(_ scrollView: UIScrollView) { center(scrollView) }

        // Helper function that re-centers the page
        private func center(_ scrollView: UIScrollView) {
            guard let page = pageView else { return }
            let size = scrollView.bounds.size
            let scaledWidth = page.bounds.width * scrollView.zoomScale
            let scaledHeight = page.bounds.height * scrollView.zoomScale
            let dx = max((size.width  - scaledWidth) / 2, 0)
            let dy = max((size.height - scaledHeight) / 2, 0)
            scrollView.contentInset = UIEdgeInsets(top: dy, left: dx, bottom: dy, right: dx)
        }
    }

    /// Generator for the coordinator
    func makeCoordinator() -> NoteCanvasCoordinator {
        NoteCanvasCoordinator(parent: self)
    }
    
    /// Generates the UIKit view to be wrapped in a SwiftUI view.
    func makeUIView(context: Context) -> some UIView {
        // Create the scroll view which will contain the notes pages.
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .black
        scrollView.delegate = context.coordinator
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = true
        scrollView.maximumZoomScale = 4.0
        scrollView.minimumZoomScale = 0.25

        // Ensure that the scroll view can only be panned and zoomed using the finger so the
        // Apple Pencil does not activate the gestures.
        let fingerOnly = NSNumber(value: UITouch.TouchType.direct.rawValue)
        scrollView.panGestureRecognizer.allowedTouchTypes = [fingerOnly]
        scrollView.pinchGestureRecognizer?.allowedTouchTypes = [fingerOnly]

        // Create the white paper background which sits on the scroll view.
        let pageSize = CGSize(width: 1200, height: 1600)
        let page = UIView(frame: CGRect(origin: .zero, size: pageSize))
        page.backgroundColor = .white
        page.layer.cornerRadius = 12
        page.layer.masksToBounds = true
        scrollView.addSubview(page)

        // Add a transparent PencilKit Canvas on top of the page. User annotations will appear here.
        vm.canvasView.frame = page.bounds
        vm.canvasView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        vm.canvasView.backgroundColor = .clear
        vm.canvasView.isOpaque = false
        vm.canvasView.drawingPolicy = .pencilOnly

        // Disable PKCanvasView’s internal scrolling/zooming so that scroll gestures only
        // activate on the enclosing scroll view.
        vm.canvasView.isScrollEnabled = false
        vm.canvasView.minimumZoomScale = 1.0
        vm.canvasView.maximumZoomScale = 1.0

        page.addSubview(vm.canvasView)

        // Add the scroll view and the page to the coordinator delegate.
        context.coordinator.scrollView = scrollView
        context.coordinator.pageView  = page
            
        // Once the page loads and we know the UI bounds, we can fit the page to the screen.
        DispatchQueue.main.async {
            // Fit page to the visible area
            let fit = min(scrollView.bounds.width / page.bounds.width,
                          scrollView.bounds.height / page.bounds.height)
            
            // Ensure we can set zoomScale = fit so that
            scrollView.minimumZoomScale = min(scrollView.minimumZoomScale, fit)
            scrollView.zoomScale = fit

            // Center the page by calling the delegate scroll function
            context.coordinator.scrollViewDidZoom(scrollView)

            vm.canvasView.becomeFirstResponder()
        }

        // Return the final scroll view
        return scrollView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        guard let scrollView = uiView as? UIScrollView, let page = context.coordinator.pageView else { return }

        // If you change pageSize dynamically, update frames/sizes here:
        if page.bounds.size != pageSize {
            page.frame.size = pageSize
            scrollView.contentSize = pageSize
            vm.canvasView.frame = page.bounds

            // Refit to screen if needed
            let fit = min(scrollView.bounds.width / page.bounds.width,
                          scrollView.bounds.height / page.bounds.height)
            scrollView.minimumZoomScale = min(scrollView.minimumZoomScale, fit)
            if scrollView.zoomScale < fit { scrollView.zoomScale = fit }
        }

        // Recenter on rotation/size changes
        context.coordinator.scrollViewDidZoom(scrollView)
    }
}
