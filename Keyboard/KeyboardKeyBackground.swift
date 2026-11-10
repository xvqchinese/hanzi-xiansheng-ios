//
//  KeyboardKeyBackground.swift
//  TransliteratingKeyboard
//
//  Created by Alexei Baboulevitch on 7/19/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

import UIKit
var gIdent = CGAffineTransform.identity


// TODO: CAShapeLayer
// TODO: dark keys semi-transparent, pass through blur; dark theme?
class KeyboardKeyBackground: UIView, KeyboardView, Connectable {
    
    private var shadowOffset: Double { didSet { self.setNeedsDisplay() }}
    var cornerRadius: Double {
        didSet {
            self.generatePointsForDrawing()
            self.setNeedsDisplay()
        }
    }
    
    var color:      UIColor { didSet { self.setNeedsDisplay() }}
    var underColor: UIColor { didSet { self.setNeedsDisplay() }}
    //var borderColor: UIColor { didSet { self.setNeedsDisplay() }}
    var drawUnder:  Bool { didSet { self.setNeedsDisplay() }}
    //var drawOver:   Bool { didSet { self.setNeedsDisplay() }}
    //var drawBorder: Bool { didSet { self.setNeedsDisplay() }}
    
    var _startingPoints: [CGPoint]
    var _segmentPoints: [(CGPoint, CGPoint)]
    var _arcCenters: [CGPoint]
    var _arcStartingAngles: [CGFloat]
    
    var _attached: Direction? { didSet { self.setNeedsDisplay() }}
    
    override init(frame: CGRect) {
        _attached = nil
        
        _startingPoints = []
        _segmentPoints = []
        _arcCenters = []
        _arcStartingAngles = []
        
        shadowOffset = 1.0
        cornerRadius = 3.0
        
        self.color = KeyboardColor.mKeyColor            // UIColor.white
        self.underColor = KeyboardColor.mKeyShadowColor // UIColor.gray    // 按键3D效果阴影
        //self.borderColor = UIColor.black
        self.drawUnder = true
        //self.drawOver = true
        //self.drawBorder = false
        
        super.init(frame: frame)
        
        self.contentMode = .redraw
        self.isOpaque = false
        self.isUserInteractionEnabled = false
        
        self.generatePointsForDrawing()
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    deinit
    {
        self._startingPoints.removeAll(keepingCapacity: false)
        self._segmentPoints.removeAll(keepingCapacity: false)
        self._arcCenters.removeAll(keepingCapacity: false)
        self._arcStartingAngles.removeAll(keepingCapacity: false)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.generatePointsForDrawing()
    }
    
    override func draw(_ rect: CGRect) {
        ///////////
        // setup //
        ///////////
        
        let ctx = UIGraphicsGetCurrentContext()!
        _ = CGColorSpaceCreateDeviceRGB()
        
        /////////////////////////
        // draw the background //
        /////////////////////////
        
        ctx.setFillColor(UIColor.clear.cgColor)
        ctx.fill(self.bounds)
        
        /////////////////////
        // draw the border //
        /////////////////////
        
        // order of edge drawing: left edge, down edge, right edge, up edge
        
        // We need to have separate paths for all the edges so we can toggle them as needed.
        // Unfortunately, it doesn't seem possible to assemble the connected fill path
        // by simply using CGPathAddPath, since it closes all the subpaths, so we have to
        // duplicate the code a little bit.
        
        let fillPath = CGMutablePath()
        var edgePaths: [CGMutablePath] = []
        var firstEdge = false
        
        for i in 0..<4
        {
            if self._attached != nil && self._attached!.rawValue == i
            {
                continue
            }
            
            let edgePath = CGMutablePath()
            
            edgePath.move(to: CGPoint(x: self._segmentPoints[i].0.x, y: self._segmentPoints[i].0.y), transform: gIdent)
            edgePath.addLine(to: CGPoint(x: self._segmentPoints[i].1.x, y: self._segmentPoints[i].1.y), transform: gIdent)
            
            // TODO: figure out if this is ncessary
            if !firstEdge {
                fillPath.move(to: CGPoint(x: self._segmentPoints[i].0.x, y: self._segmentPoints[i].0.y), transform: gIdent)
                firstEdge = true
            }
            else {
                fillPath.addLine(to: CGPoint(x: self._segmentPoints[i].0.x, y: self._segmentPoints[i].0.y), transform: gIdent)
            }
            fillPath.addLine(to: CGPoint(x: self._segmentPoints[i].1.x, y: self._segmentPoints[i].1.y), transform: gIdent)
            
            if (self._attached != nil && self._attached!.rawValue == ((i + 1) % 4)) {
                // do nothing
            } else {
                edgePath.addRelativeArc(center: CGPoint(x: self._arcCenters[(i + 1) % 4].x, y: self._arcCenters[(i + 1) % 4].y), radius: CGFloat(self.cornerRadius), startAngle: self._arcStartingAngles[(i + 1) % 4], delta: CGFloat(Double.pi/2.0), transform: gIdent)
                fillPath.addRelativeArc(center: CGPoint(x: self._arcCenters[(i + 1) % 4].x, y: self._arcCenters[(i + 1) % 4].y), radius: CGFloat(self.cornerRadius), startAngle: self._arcStartingAngles[(i + 1) % 4], delta: CGFloat(Double.pi/2.0), transform: gIdent)
            }
            
            edgePaths.append(edgePath)
        }
        
        // drawUnder
        if self.drawUnder && self._attached != Direction.Down
        {
            // TODO: is this the right way to do this? either way, it works for now
            ctx.saveGState()
                ctx.translateBy(x: 0, y: -CGFloat(shadowOffset))
                ctx.addPath(fillPath)
                ctx.translateBy(x: 0, y: CGFloat(shadowOffset))
                ctx.addPath(fillPath)
                ctx.clip(using: .evenOdd)
            
                ctx.translateBy(x: 0, y: CGFloat(shadowOffset))
                ctx.setFillColor(self.underColor.cgColor)
                ctx.addPath(fillPath)
                ctx.fillPath()
            ctx.restoreGState()
        }
        
        // drawOver
        if true
        {
            ctx.setFillColor(self.color.cgColor)
            ctx.setLineWidth(1)
        }
        
        // TODO: border stroke outside, not inside
        ctx.translateBy(x: 0, y: -CGFloat(shadowOffset))
        ctx.saveGState()
        ctx.addPath(fillPath)
        ctx.clip()
        ctx.addPath(fillPath)
        ctx.fillPath()
        /*
        // drawBorder
        if self.drawBorder
        {
            ctx.setStrokeColor(self.borderColor.cgColor)
            for path in edgePaths 
            {
                ctx.addPath(path)
                ctx.strokePath()
            }
        }***/
        ctx.restoreGState()
        ctx.translateBy(x: 0, y: CGFloat(shadowOffset))
        
        /////////////
        // cleanup //
        /////////////
        
        // TODO: apparently you don't need to call CFRelease for "annotated" CG APIs... does this apply to paths and color spaces?
    }
    
    func generatePointsForDrawing() {
        let segmentWidth = self.bounds.width
        let segmentHeight = self.bounds.height - CGFloat(shadowOffset)
        
        // base, untranslated corner points
        self._startingPoints = [
            CGPoint(x: 0, y: segmentHeight),
            CGPoint(x: 0, y: 0),
            CGPoint(x: segmentWidth, y: 0),
            CGPoint(x: segmentWidth, y: segmentHeight),
        ]
        
        // actual coordinates for each edge, including translation
        self._segmentPoints = [] // TODO: is this declaration correct?
        
        // actual coordinates for arc centers for each corner
        self._arcCenters = []
        
        self._arcStartingAngles = []
        
        for i in 0 ..< self._startingPoints.count {
            let currentPoint = self._startingPoints[i]
            let nextPoint = self._startingPoints[(i + 1) % self._startingPoints.count]
            
            var xDir = 0.0
            var yDir = 0.0
            
            if (i == 1) {
                xDir = 1.0
                self._arcStartingAngles.append(CGFloat.pi)
            }
            else if (i == 3) {
                xDir = -1.0
                self._arcStartingAngles.append(CGFloat(0))
            }
            
            if (i == 0) {
                yDir = -1.0
                self._arcStartingAngles.append(CGFloat(Double.pi/2.0))
            }
            else if (i == 2) {
                yDir = 1.0
                self._arcStartingAngles.append(CGFloat(-Double.pi/2.0))
            }
            
            let p0 = CGPoint(x: currentPoint.x + CGFloat(xDir * cornerRadius), y: currentPoint.y + CGFloat(shadowOffset) + CGFloat(yDir * cornerRadius))
            let p1 = CGPoint(x: nextPoint.x - CGFloat(xDir * cornerRadius), y: nextPoint.y + CGFloat(shadowOffset) - CGFloat(yDir * cornerRadius))
            
            self._segmentPoints.append((p0, p1))
            
            let c = CGPoint(x: p0.x - CGFloat(yDir * cornerRadius), y: p0.y + CGFloat(xDir * cornerRadius))
            
            self._arcCenters.append(c)
        }
    }
    
    func attachmentPoints(_ direction: Direction) -> (CGPoint, CGPoint) {
        var returnValue = (
            self._segmentPoints[direction.clockwise().rawValue].0,
            self._segmentPoints[direction.counterclockwise().rawValue].1)
        
        // TODO: quick hack
        returnValue.0.y -= CGFloat(self.shadowOffset)
        returnValue.1.y -= CGFloat(self.shadowOffset)
        
        return returnValue
    }
    
    func attachmentDirection() -> Direction? {
        return self._attached
    }
    
    func attach(_ direction: Direction?) {
        self._attached = direction
    }
}

//class KeyboardKeyPopup: KeyboardKeyBackground {
//    
//    init(frame: CGRect, vertical: Bool) {
//        super.init(frame: frame)
//    }
//    
//    // if action is nil, the key is not selectable
//    func addOption(_ option: String, action: String?) {
//    }
//}
