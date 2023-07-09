//
//  CGPoint+IntPoint.swift
//  SwiftUIBresenhamLineAlgorithmExample
//
//  Created by Stephan Casas on 7/9/23.
//

import SwiftUI;

struct IntPoint {
    var x: Int;
    var y: Int;
    
    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
    
    /// Get a copy of this `IntPoint` with the
    /// `x` and `y` positions reversed.
    ///
    func inverted() -> IntPoint {
        IntPoint(self.y, self.x)
    }
    
    /// Get this `IntPoint` as a `CGPoint`.
    ///
    func cgPoint() -> CGPoint {
        CGPointMake(CGFloat(self.x), CGFloat(self.y))
    }
}

extension CGPoint {
    
    /// Get this point as an integer-based point, `IntPoint`.
    ///
    func intPoint() -> IntPoint {
        IntPoint(Int(self.x), Int(self.y))
    }
    
    /// Plot a line from this point to the destination point
    /// using the Bresenham line algorithm.
    ///
    func line(to point: CGPoint) -> [CGPoint] {
        var plot: [IntPoint] = [self.intPoint(), point.intPoint()];
        
        let steep = abs(plot[1].y - plot[0].y) > abs(plot[1].x - plot[0].x);
        
        if steep {
            plot[0] = plot[0].inverted();
            plot[1] = plot[1].inverted();
        }
        
        if plot[1].x < plot[0].x {
            plot.reverse();
        }
        
        let p1 = plot[0];
        let p2 = plot[1];
        
        let dX = p2.x - p1.x;
        let dY = p2.y - p1.y;
        
        var trace = [IntPoint]();
        
        let yStep = (dY >= 0) ? 1 : -1;
        let slope = abs(Float(dY) / Float(dX));
        
        var x = p1.x;
        var y = p1.y;
        
        var error:Float = 0;
        
        trace.append(steep ? .init(y, x) : .init(x, y));
        
        while x <= p2.x {
            x += 1;
            error += slope;
            if (error >= 0.5) {
                y += yStep;
                error -= 1;
            }
            trace.append(steep ? .init(y, x) : .init(x, y));
        }
        
        return trace.map({ $0.cgPoint() });
    }
    
}
