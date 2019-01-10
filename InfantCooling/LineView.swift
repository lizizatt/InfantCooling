//
//  LineView.swift
//  InfantCooling
//
//  Created by Elizabeth Izatt on 12/24/18.
//  Copyright © 2018 LizIzatt. All rights reserved.
//

import Foundation
import UIKit

class LineView : UIView {
    var LINE_THICKNESS : CGFloat = 5
    
    private var defaultFrame : CGRect;
    private var points = [CGPoint]()
    
    init(start : CGVector, end : CGVector) {
        let minX = min(start.dx, end.dx)
        let minY = min(start.dy, end.dy)
        let maxX = max(start.dx, end.dx) + LINE_THICKNESS
        let maxY = max(start.dy, end.dy) + LINE_THICKNESS
        
        defaultFrame = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY);
        points.append(CGPoint(x: start.dx - minX, y: start.dy - minY))
        points.append(CGPoint(x: end.dx - minX, y: end.dy - minY))
        
        super.init(frame: defaultFrame);
        
        backgroundColor = UIColor.clear;
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    public override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState();
        context!.setLineWidth(LINE_THICKNESS)
        context!.setStrokeColor(DukeLookAndFeel.coolGray.cgColor)
        context?.addLines(between: points)
        context!.strokePath()
        context?.restoreGState();
    }
    
    func setOffset(vec : CGVector, duration : Double) {
        let x = vec.dx;
        let y = vec.dy;
        
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseOut, animations: {
            self.frame.origin = CGPoint(x: x + self.defaultFrame.origin.x, y: y + self.defaultFrame.origin.y)
        })
    }
}
