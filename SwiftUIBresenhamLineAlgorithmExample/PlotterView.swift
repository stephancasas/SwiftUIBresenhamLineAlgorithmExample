//
//  Plotter.swift
//  SwiftUIBresenhamLineAlgorithmExample
//
//  Created by Stephan Casas on 7/9/23.
//

import SwiftUI;
import Combine;

// MARK: - State Manager

class Plotter: ObservableObject {
    
    // MARK: - Public
    
    @Published var brushSize: CGFloat = 3;
    
    @Published var x1: CGFloat = 10;
    @Published var y1: CGFloat = 10;
    
    @Published var x2: CGFloat = 100;
    @Published var y2: CGFloat = 100;
    
    typealias ExportPublisher = PassthroughSubject<URL, Never>;
    let exportPublisher = ExportPublisher();
    
    /// Plot the trace between the two points.
    ///
    func plot() -> [CGPoint] {
        CGPointMake(self.x1, self.y1).line(
            to: CGPointMake(self.x2, self.y2)
        );
    }
    
    /// Next-inserted point should be in the
    /// secondary series.
    ///
    private var insertFlag = false;
    private var insertFlagReset: DispatchWorkItem? = nil;
    private let kFlagResetInterval: DispatchTimeInterval = .seconds(3);
    
    /// Insert a point for drawing.
    ///
    func insert(point: CGPoint) {
        self.insertFlagReset?.cancel()
        
        if insertFlag {
            self.x2 = point.x;
            self.y2 = point.y;
            insertFlag = false;
            return;
        }
        
        self.x1 = point.x;
        self.y1 = point.y;
        
        self.insertFlag = true;
        self.insertFlagReset = DispatchWorkItem(block: {
            self.insertFlag = false;
        });
        
        DispatchQueue.main.asyncAfter(
            deadline: .now().advanced(by: kFlagResetInterval),
            execute: self.insertFlagReset!);
    }
    
}

// MARK: - View

struct PlotterView: View {
    
    @StateObject var plotter = Plotter();
    
    var body: some View {
        
        VStack(content:  {
            
            TraceView(self.plotter)
                .border(.tertiary, width: 1)
            
            TraceEditor()
            
        })
        .padding()
        .toolbar(content: {
            Button(action: self.exportTraceImage,
                   label: { Image(systemName: "camera.viewfinder")})
        })
        .navigationTitle("SwiftUI Bresenham Line Algorithm Example")
    }
    
    private func exportTraceImage() {
        guard
            let window = NSApplication.shared.keyWindow
        else { return }
        
        let savePanel = NSSavePanel();
        savePanel.allowedContentTypes = [.tiff];
        
        savePanel.beginSheetModal(
            for: window,
            completionHandler: { response in
                if response != .OK { return }
                guard
                    let url = savePanel.url
                else { return }
                self.plotter.exportPublisher.send(url);
            })
    }
    
    private func TraceEditor() -> some View {
        HStack(content: {
            HStack(content: {
                PointEditor("A", self.$plotter.x1, self.$plotter.y1)
                PointEditor("B", self.$plotter.x2, self.$plotter.y2)
            })
            
            Spacer()
            
            GroupBox("Stroke", content: {
                ValueEditor("Stroke", self.$plotter.brushSize)
            })
            .frame(width: 75)
        })
    }
    
    private func PointEditor(
        _ series: String,
        _ x: Binding<CGFloat>,
        _ y: Binding<CGFloat>
    ) -> some View {
        GroupBox("Point \(series)", content: {
            HStack(content: {
                ValueEditor("x", x)
                ValueEditor("y", y)
            })
        })
        .frame(width: 150)
    }
    
    private func ValueEditor(_ label: String , _ data: Binding<CGFloat>) -> some View {
        TextField(label, value: data, formatter: NumberFormatter())
            .multilineTextAlignment(.center)
    }
    
}
