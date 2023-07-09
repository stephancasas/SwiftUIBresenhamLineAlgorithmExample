//
//  TraceView.swift
//  SwiftUIBresenhamLineAlgorithmExample
//
//  Created by Stephan Casas on 7/9/23.
//

import SwiftUI;
import Combine;

// MARK: - Trace Viewer

struct TraceView: NSViewRepresentable {
    
    @ObservedObject var plotter: Plotter;
    
    init(_ plotter: Plotter) {
        self.plotter = plotter;
    }
    
    func makeNSView(context: Context) -> TraceVisualizer {
        let nsView = TraceVisualizer();

        nsView.plotter = self.plotter;
        nsView.subscribeToTraceExport();
        
        return nsView;
    }
    
    func updateNSView(_ nsView: TraceVisualizer, context: Context) {
        /// Re-draw line on every state manager update.
        ///
        nsView.needsDisplay = true;
    }
    
}

// MARK: - Trace Visualizer

extension TraceView {
    
    class TraceVisualizer: NSView {
        
        var plotter = Plotter();
        
        var subscriptions = [AnyCancellable]();
        
        override func draw(_ dirtyRect: NSRect) {
            guard let context = NSGraphicsContext
                .current?.cgContext
            else { return }
            
            /// Erase existing content trace.
            ///
            context.setFillColor(red: 0, green: 0, blue: 0, alpha: 0);
            context.fill(CGRectMake(0, 0, dirtyRect.width, dirtyRect.height));
            
            context.setFillColor(red: 1, green: 0, blue: 0, alpha: 1);
            for point in self.plotter.plot()  {
                context.fill(CGRect(
                    x: point.x - (self.plotter.brushSize / 2),
                    y: point.y - (self.plotter.brushSize / 2),
                    width: self.plotter.brushSize,
                    height: self.plotter.brushSize
                ));
            }
        }
        
        override func mouseDown(with event: NSEvent) {
            guard
                let window = self.window,
                let frameView = window.contentView?.superview
            else { return }
            
            self.plotter.insert(point: self.convert(
                event.locationInWindow,
                from: frameView
            ));
        }
        
        func subscribeToTraceExport() {
            self.plotter.exportPublisher.sink(receiveValue: { url in
                self.exportTrace(to: url);
            }).store(in: &self.subscriptions);
        }
        
        private func exportTrace(to url: URL) {
            guard let bitmap = self.bitmapImageRepForCachingDisplay(
                in: self.bounds
            ) else { return }
            
            self.cacheDisplay(in: self.bounds, to: bitmap);
            
            try? bitmap.tiffRepresentation?.write(to: url);
        }
         
    }
    
}
