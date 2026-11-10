//
//  KeyboardConnector.swift
//  TransliteratingKeyboard
//
//  Created by Alexei Baboulevitch on 7/19/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

import UIKit

protocol Connectable {
    func attachmentPoints(_ direction: Direction) -> (CGPoint, CGPoint)
    func attachmentDirection() -> Direction?
    func attach(_ direction: Direction?) // call with nil to detach
}

// TODO: Xcode crashes
// <ConnectableView: UIView where ConnectableView: Connectable>
class KeyboardConnector: UIView, KeyboardView {
    
    var start: UIView
    var end: UIView
    var startDir: Direction
    var endDir: Direction
    
    // TODO: temporary fix for Swift compiler crash
    var startConnectable: Connectable
    var endConnectable: Connectable
    var convertedStartPoints: (CGPoint, CGPoint)!
    var convertedEndPoints: (CGPoint, CGPoint)!
    
    var color: UIColor { didSet { self.setNeedsDisplay() }}
    //var underColor: UIColor { didSet { self.setNeedsDisplay() }}
    //var borderColor: UIColor { didSet { self.setNeedsDisplay() }}
    //var drawUnder: Bool { didSet { self.setNeedsDisplay() }}
    //var drawBorder: Bool { didSet { self.setNeedsDisplay() }}
    var drawShadow: Bool { didSet { self.setNeedsDisplay() }}
    
    var _offset: CGPoint
    
    // TODO: until bug is fixed, make sure start/end and startConnectable/endConnectable are the same object
    init(start: UIView, end: UIView, startConnectable: Connectable, endConnectable: Connectable, startDirection: Direction, endDirection: Direction) {
        self.start = start
        self.end = end
        self.startDir = startDirection
        self.endDir = endDirection
        self.startConnectable = startConnectable
        self.endConnectable = endConnectable
        
        self.color = KeyboardColor.mKeyColor// UIColor.white
        //self.underColor = UIColor.gray
        //self.borderColor = UIColor.black
        //self.drawUnder = true
        //self.drawBorder = true
        self.drawShadow = true
        
        self._offset = CGPoint.zero
        
        super.init(frame: CGRect.zero)
        
        self.isUserInteractionEnabled = false // TODO: why is this even necessary if it's under all the other views?
        self.backgroundColor = UIColor.clear
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    deinit
    {
        // ... release objs
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.resizeFrame()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.resizeFrame()
        self.setNeedsDisplay()
    }
    
    func generateConvertedPoints() {
        if self.superview == nil {
            return
        }
        
        let startPoints = self.startConnectable.attachmentPoints(self.startDir)
        let endPoints = self.endConnectable.attachmentPoints(self.endDir)
        
        self.convertedStartPoints = (
            self.superview!.convert(startPoints.0, from: self.start),
            self.superview!.convert(startPoints.1, from: self.start))
        self.convertedEndPoints = (
            self.superview!.convert(endPoints.0, from: self.end),
            self.superview!.convert(endPoints.1, from: self.end))
    }
    
    func resizeFrame() {

        generateConvertedPoints()
        
        let buffer: CGFloat = 32
        self._offset = CGPoint(x: buffer/2, y: buffer/2)
        
        let minX = min(convertedStartPoints.0.x, convertedStartPoints.1.x, convertedEndPoints.0.x, convertedEndPoints.1.x)
        let minY = min(convertedStartPoints.0.y, convertedStartPoints.1.y, convertedEndPoints.0.y, convertedEndPoints.1.y)
        let maxX = max(convertedStartPoints.0.x, convertedStartPoints.1.x, convertedEndPoints.0.x, convertedEndPoints.1.x)
        let maxY = max(convertedStartPoints.0.y, convertedStartPoints.1.y, convertedEndPoints.0.y, convertedEndPoints.1.y)
        let width = maxX - minX
        let height = maxY - minY
        
        self.frame = CGRect(x: minX - buffer/2, y: minY - buffer/2, width: width + buffer, height: height + buffer)
    }
    
    override func draw(_ rect: CGRect) {
        // TODO: quick hack
        resizeFrame()
        
        let startPoints = self.startConnectable.attachmentPoints(self.startDir)
        let endPoints = self.endConnectable.attachmentPoints(self.endDir)
        
        var myConvertedStartPoints = (
            self.convert(startPoints.0, from: self.start),
            self.convert(startPoints.1, from: self.start))
        let myConvertedEndPoints = (
            self.convert(endPoints.0, from: self.end),
            self.convert(endPoints.1, from: self.end))
        
        if self.startDir == self.endDir {
            let tempPoint = myConvertedStartPoints.0
            myConvertedStartPoints.0 = myConvertedStartPoints.1
            myConvertedStartPoints.1 = tempPoint
        }
        
        let ctx = UIGraphicsGetCurrentContext()!
        let _ = CGColorSpaceCreateDeviceRGB()
        
        let path = CGMutablePath()

        path.move(to: CGPoint(x: myConvertedStartPoints.0.x, y: myConvertedStartPoints.0.y))
        path.addLine(to: CGPoint(x: myConvertedEndPoints.1.x, y: myConvertedEndPoints.1.y))
        path.addLine(to: CGPoint(x: myConvertedEndPoints.0.x, y: myConvertedEndPoints.0.y))
        path.addLine(to: CGPoint(x: myConvertedStartPoints.1.x, y: myConvertedStartPoints.1.y))
        path.closeSubpath()
        //path = nil
        
        // for now, assuming axis-aligned attachment points
        
        let isVertical = (self.startDir == Direction.Up || self.startDir == Direction.Down) && (self.endDir == Direction.Up || self.endDir == Direction.Down)
        
        var midpoint: CGFloat
        if  isVertical {
            midpoint = myConvertedStartPoints.0.y + (myConvertedEndPoints.1.y - myConvertedStartPoints.0.y) / 2
        }
        else {
            midpoint = myConvertedStartPoints.0.x + (myConvertedEndPoints.1.x - myConvertedStartPoints.0.x) / 2
        }
        
        let bezierPath = UIBezierPath()
        bezierPath.move(to: myConvertedStartPoints.0)
        bezierPath.addCurve(to: 
            myConvertedEndPoints.1,
            controlPoint1: (isVertical ?
                CGPoint(x: myConvertedStartPoints.0.x, y: midpoint) :
                CGPoint(x: midpoint, y: myConvertedStartPoints.0.y)),
            controlPoint2: (isVertical ?
                CGPoint(x: myConvertedEndPoints.1.x, y: midpoint) :
                CGPoint(x: midpoint, y: myConvertedEndPoints.1.y)))
        bezierPath.addLine(to: myConvertedEndPoints.0)
        bezierPath.addCurve(to: 
            myConvertedStartPoints.1,
            controlPoint1: (isVertical ?
                CGPoint(x: myConvertedEndPoints.0.x, y: midpoint) :
                CGPoint(x: midpoint, y: myConvertedEndPoints.0.y)),
            controlPoint2: (isVertical ?
                CGPoint(x: myConvertedStartPoints.1.x, y: midpoint) :
                CGPoint(x: midpoint, y: myConvertedStartPoints.1.y)))
        bezierPath.addLine(to: myConvertedStartPoints.0)
        bezierPath.close()
        
        let shadow = UIColor.black.withAlphaComponent(0.35)
        let shadowOffset = CGSize(width: 0, height: 1.5)
        let shadowBlurRadius: CGFloat = 12
        
        // shadow is drawn separate from the fill
        // http://stackoverflow.com/questions/6709064/coregraphics-quartz-drawing-shadow-on-transparent-alpha-path
//        ctx.saveGState()
//        self.color.setFill()
//        ctx.setShadow(offset: shadowOffset, blur: shadowBlurRadius, color: shadow.cgColor)
//        CGContextMoveToPoint(ctx, 0, 0);
//        CGContextAddLineToPoint(ctx, self.bounds.width, 0);
//        CGContextAddLineToPoint(ctx, self.bounds.width, self.bounds.height);
//        CGContextAddLineToPoint(ctx, 0, self.bounds.height);
//        CGContextClosePath(ctx);
//        CGContextAddPath(ctx, bezierPath.CGPath)
//        ctx.clip()
//        CGContextAddPath(ctx, bezierPath.CGPath)
//        CGContextDrawPath(ctx, kCGPathFillStroke)
//        ctx.restoreGState()
        
//        CGContextAddPath(ctx, bezierPath.CGPath)
//        ctx.clip()
        
        ctx.saveGState()
        UIColor.black.setFill()
        ctx.setShadow(offset: shadowOffset, blur: shadowBlurRadius, color: shadow.cgColor)
        bezierPath.fill()
        ctx.restoreGState()
        
        /*
        if self.drawUnder
        {
            ctx.translateBy(x: 0, y: 1)
            self.underColor.setFill()
            CGContextAddPath(ctx, bezierPath.CGPath)
            ctx.fillPath()
            ctx.translateBy(x: 0, y: -1)
        }*/
        
        self.color.setFill()
        bezierPath.fill()
        
        /*
        if self.drawBorder
        {
            self.borderColor.setStroke()
            ctx.setLineWidth(1)
            
            CGContextMoveToPoint(ctx, myConvertedStartPoints.0.x, myConvertedStartPoints.0.y)
            CGContextAddCurveToPoint(
                ctx,
                (isVertical ? myConvertedStartPoints.0.x : midpoint),
                (isVertical ? midpoint : myConvertedStartPoints.0.y),
                (isVertical ? myConvertedEndPoints.1.x : midpoint),
                (isVertical ? midpoint : myConvertedEndPoints.1.y),
                myConvertedEndPoints.1.x,
                myConvertedEndPoints.1.y)
            ctx.strokePath()
            
            CGContextMoveToPoint(ctx, myConvertedEndPoints.0.x, myConvertedEndPoints.0.y)
            CGContextAddCurveToPoint(
                ctx,
                (isVertical ? myConvertedEndPoints.0.x : midpoint),
                (isVertical ? midpoint : myConvertedEndPoints.0.y),
                (isVertical ? myConvertedStartPoints.1.x : midpoint),
                (isVertical ? midpoint : myConvertedStartPoints.1.y),
                myConvertedStartPoints.1.x,
                myConvertedStartPoints.1.y)
            ctx.strokePath()
        }*/
    }
}
