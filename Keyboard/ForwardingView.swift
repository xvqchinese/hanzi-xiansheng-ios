//
//  ForwardingView.swift
//  TransliteratingKeyboard
//
//  Created by Alexei Baboulevitch on 7/19/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

import UIKit

@objcMembers
class ForwardingView: UIView {
    
    private var activeTouches: [Int]
    private var multiTapTimers: [Int: Timer]
    private var touchToView: [UITouch:UIView]

    private var imageView: UIImageView = UIImageView()
    private var downKey: UIView? = nil
    private var currentKey: UIView? = nil
    private var writting: Bool = false

    var enableSwypeWriting: Bool = false
    var enableHandWriting: Bool = false
    var enableGesture: Bool = false
    var hwRect: CGRect?
    var delegate: KeyboardCandProtocol?
    
    var gestureRecognizer: UISwipeGestureRecognizer?
    var strokeAry: [Int16]
    // 设置调试
    let DEBUG = false
    
    //-------------------------------------------
    // 毛笔效果使用变量
    //-------------------------------------------
    // 存放点集的数组
    var hw_points:[CGPoint] = [CGPoint]()
    // 当前半径
    var hw_currentWidth:CGFloat = 13
    // 最大和最小宽度
    let hw_defaultWidth: CGFloat = 13
    let hw_minWidth:CGFloat = 5
    let hw_maxWidth:CGFloat = 13
    //var hw_lastImage:UIImage?
    //-------------------------------------------
    //-------------------------------------------
    
    
    override init(frame: CGRect) {
        self.activeTouches = []
        self.multiTapTimers = [:]
        self.touchToView = [:]
        self.strokeAry = []

        super.init(frame: frame)
        
        self.backgroundColor = KeyboardColor.mKbBackgroundColor
        self.imageView.backgroundColor = KeyboardColor.mHwBColor

        self.imageView.isUserInteractionEnabled = false
        self.imageView.isHidden = true
        self.imageView.layer.zPosition = 0x2001
        //self.hw_lastImage = UIImage()
        self.addSubview(self.imageView)
        
        self.contentMode = .redraw
        self.isMultipleTouchEnabled = false//true
        self.isUserInteractionEnabled = true
        self.isOpaque = false
        self.layer.zPosition = 100
        //self.backgroundColor = UIColor.green
        self.clipsToBounds = false
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    deinit
    {
        self.End()
    }
    
    func End()
    {
        self.reset()
        self.imageView.removeFromSuperview()
        self.touchToView.removeAll(keepingCapacity: false)
        self.multiTapTimers.removeAll(keepingCapacity: false)
        self.activeTouches.removeAll(keepingCapacity: false)
        self.strokeAry.removeAll(keepingCapacity: false)

        self.currentKey = nil
        self.downKey = nil
        self.hwRect = nil

        if self.gestureRecognizer != nil
        {
            self.removeGestureRecognizer(self.gestureRecognizer!)
            self.gestureRecognizer = nil
        }
    }
    
    func reset()
    {
        self.strokeAry.removeAll(keepingCapacity: false)
        if !self.imageView.isHidden
        {
            self.drawPenClear()
        }
    }
    
    
    func hasInput() -> Bool
    {
        return self.strokeAry.count > 0
    }
    
    // 当输入模式改变了
    func onModeChange(_ mode: Int, handler: KeyboardCandProtocol)
    {
        self.reset()
        self.enableHandWriting = (mode == KbPage.M_HW)
        self.enableSwypeWriting = (mode == KbPage.M_En26)
        self.enableGesture = (mode == KbPage.M_SK9)

        if self.enableHandWriting
        {
            self.delegate = handler
        }
        
        if self.enableGesture
        {
            // 加入手势识别: 下
            if self.gestureRecognizer == nil
            {
                self.gestureRecognizer = UISwipeGestureRecognizer()
                self.gestureRecognizer!.direction = UISwipeGestureRecognizer.Direction.down
                self.gestureRecognizer!.addTarget(self, action: Selector("handleSwipeDown"))
                self.addGestureRecognizer(self.gestureRecognizer!)
            }
        }
        else
        {
            if self.gestureRecognizer != nil
            {
                self.removeGestureRecognizer(self.gestureRecognizer!)
                self.gestureRecognizer = nil
            }
        }
    }
    
    // 手势识别
    @objc func handleSwipeDown()
    {
        for obj in self.touchToView
        {
            if obj.1 is KeyboardKey
            {
                let key = obj.1 as! KeyboardKey
                key.isSwipeDown = true
                self.handleControl(key, controlEvent: .touchUpInside)
            }
        }
        self.touchToView.removeAll(keepingCapacity: false)
    }
    
    // Why have this useless drawRect? Well, if we just set the backgroundColor to clearColor,
    // then some weird optimization happens on UIKit's side where tapping down on a transparent pixel will
    // not actually recognize the touch. Having a manual drawRect fixes this behavior, even though it doesn't
    // actually do anything.
    override func draw(_ rect: CGRect) {}
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView?
    {
        let obj = super.hitTest(point, with: event)
        
        if !self.isHidden
        {
            if self.point(inside: point, with: event)
            {
                return self
            }
        }
        if (obj == self.imageView)
        {
            return self
        }
        
        return obj
    }
    
    override func layoutSubviews()
    {
        self.imageView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
    }
    
    func show()
    {
        self.isHidden = false
    }
    
    func hide()
    {
        self.isHidden = true
    }
    
    // TODO: drag up control centre from bottom == stuck
    func handleControl(_ view: UIView?, controlEvent: UIControl.Event)
    {
        if let control = view as? UIControl
        {
            let targets = control.allTargets
            for target in targets
            { // TODO: Xcode crashes
                let actions = control.actions(forTarget: target, forControlEvent: controlEvent)
                if (actions != nil)
                {
                    for action in actions!
                    {
                        let selector = Selector(action as String)
                        control.sendAction(selector, to: target, for: nil)
                    }
                }
            }
        }
    }

    // 找被按下的view
    func findPointView(_ position: CGPoint) -> UIView?
    {
        for anyView in self.subviews
        {
            let view = anyView as UIView
            
            if view.isHidden
            {
                continue
            }
            
            //view.alpha = 1
            let distance = distanceBetween(view.frame, point: position)
            if distance == 0
            {
                return view
            }
        }
        
        return nil
    }
    
    func findPointOnView(_ touches: NSSet, withEvent event: UIEvent?) -> UIView?
    {
        if touches.count != 1
        {
            return nil
        }
        
        for obj in touches
        {
            let touch = obj as! UITouch
            let position = touch.location(in: self)

            for anyView in self.subviews
            {
                //MyLog("obj = \(NSString.stringWithUTF8String(object_getClassName(anyView)))")
                //let cName : NSString = String(cString: object_getClassName(anyView))
                //if cName.isEqualToString("Keyboard.KeyboardKey")
                if anyView is KeyboardKey
                {
                    let view = anyView as! KeyboardKey
                    if view.isHidden
                    {
                        continue
                    }
                
                    if CGRectContainsPoint(view.frame, position) && view.getType() == Key.KeyType.Character
                    {
                        return view
                    }
                }
            }
            break;
        }
        
        return nil
    }
    
    // TODO: there's a bit of "stickiness" to Apple's implementation
    func findNearestView(_ position: CGPoint) -> UIView?
    {
        var closest: (UIView, CGFloat)? = nil
        
        for anyView in self.subviews
        {
            let view = anyView as UIView
            
            if view.isHidden
            {
                continue
            }
            
            view.alpha = 1
            
            let distance = distanceBetween(view.frame, point: position)
            
            if closest != nil
            {
                if distance < closest!.1
                {
                    closest = (view, distance)
                }
            }
            else
            {
                closest = (view, distance)
            }
        }
        
        if closest != nil
        {
            return closest!.0
        }
        else
        {
            return nil
        }
    }
    
    // http://stackoverflow.com/questions/3552108/finding-closest-object-to-cgpoint b/c I'm lazy
    func distanceBetween(_ rect: CGRect, point: CGPoint) -> CGFloat
    {
        if CGRectContainsPoint(rect, point)
        {
            return 0
        }

        var closest = rect.origin
        
        if (rect.origin.x + rect.size.width < point.x)
        {
            closest.x += rect.size.width
        }
        else if (point.x > rect.origin.x)
        {
            closest.x = point.x
        }
        if (rect.origin.y + rect.size.height < point.y)
        {
            closest.y += rect.size.height
        }
        else if (point.y > rect.origin.y)
        {
            closest.y = point.y
        }
        
        let a = pow(Double(closest.y - point.y), 2)
        let b = pow(Double(closest.x - point.x), 2)
        return CGFloat(sqrt(a + b));
    }
    
    /**
     画毛笔效果
     */
    func drawBrush()
    {
        //UIGraphicsBeginImageContext(self.frame.size)
        //self.hw_lastImage!.drawInRect(self.bounds)
        
        // 贝赛尔曲线的起始点和末尾点
        let tempPoint1 = CGPoint(x: (hw_points[0].x+hw_points[1].x)/2, y: (hw_points[0].y+hw_points[1].y)/2)
        let tempPoint2 = CGPoint(x: (hw_points[1].x+hw_points[2].x)/2, y: (hw_points[1].y+hw_points[2].y)/2)
        
        if DEBUG{
            var pointPath = UIBezierPath(arcCenter: hw_points[2], radius: 3, startAngle: 0, endAngle: CGFloat.pi*2.0, clockwise: true)
            UIColor.red.set()
            pointPath.stroke()
            pointPath = UIBezierPath(arcCenter: hw_points[1], radius: 3, startAngle: 0, endAngle: CGFloat.pi*2.0, clockwise: true)
            pointPath.stroke()
            pointPath = UIBezierPath(arcCenter: hw_points[0], radius: 3, startAngle: 0, endAngle: CGFloat.pi*2.0, clockwise: true)
            pointPath.stroke()
            pointPath = UIBezierPath(arcCenter: tempPoint1, radius: 3, startAngle: 0, endAngle: CGFloat.pi*2.0, clockwise: true)
            pointPath.stroke()
            pointPath = UIBezierPath(arcCenter: tempPoint2, radius: 3, startAngle: 0, endAngle: CGFloat.pi*2.0, clockwise: true)
            pointPath.stroke()
        }
        
        // 贝赛尔曲线的估算长度
        let x1 = abs(tempPoint1.x-tempPoint2.x)
        let x2 = abs(tempPoint1.y-tempPoint2.y)
        let len = Int(sqrt(pow(x1, 2) + pow(x2,2))*10)
        
        // 如果仅仅点击一下
        if len == 0
        {
            let zeroPath = UIBezierPath(arcCenter: hw_points[1], radius: hw_maxWidth/2-2, startAngle: 0, endAngle: CGFloat.pi*2.0, clockwise: true)
            //UIColor.black.setFill()
            KeyboardColor.mHwStrokeColor.setFill()
            zeroPath.fill()
            
            // 绘图
            self.imageView.image = UIGraphicsGetImageFromCurrentImageContext()
            //self.hw_lastImage = self.imageView.image
            //UIGraphicsEndImageContext()
            return
        }
        
        let rgb = (KeyboardColor.mHwStrokeColor.cgColor).components!
        
        // 如果距离过短，直接画线
        if len < 1 {
            let zeroPath = UIBezierPath()
            zeroPath.move(to: tempPoint1)
            zeroPath.addLine(to: tempPoint2)
            
            hw_currentWidth += 0.05
            if hw_currentWidth > hw_maxWidth {hw_currentWidth = hw_maxWidth}
            if hw_currentWidth < hw_minWidth {hw_currentWidth = hw_minWidth}
            
            // 画线
            zeroPath.lineWidth = hw_currentWidth
            zeroPath.lineCapStyle = .round
            zeroPath.lineJoinStyle = .round
            //UIColor(white: 0, alpha: (hw_currentWidth-hw_minWidth)/hw_maxWidth*0.6+0.2).setStroke()
            UIColor(red: rgb[0], green: rgb[1], blue: rgb[2], alpha: (hw_currentWidth-hw_minWidth)/hw_maxWidth*0.6+0.2).setStroke()
            zeroPath.stroke()
            
            self.imageView.image = UIGraphicsGetImageFromCurrentImageContext()
            //UIGraphicsEndImageContext()
            return
        }
        
        // 目标半径
        let aimWidth:CGFloat = CGFloat(300)/CGFloat(len)*(hw_maxWidth-hw_minWidth)
        
        // 获取贝塞尔点集
        let curvePoints = AFBezierPath.curveFactorization(tempPoint1, toPoint: tempPoint2, controlPoints: [hw_points[1]], countIn: len)
        
        // 画每条线段
        var lastPoint:CGPoint = tempPoint1
        for i in 0..<(len+1)
        {
            let bPath = UIBezierPath()
            bPath.move(to: lastPoint)
            
            // 省略多余的点
            let delta = sqrt(pow(curvePoints[i].x-lastPoint.x, 2) + pow(curvePoints[i].y-lastPoint.y, 2))
            if delta < 1 {continue}
            
            lastPoint = CGPoint(x: curvePoints[i].x, y: curvePoints[i].y)
            
            bPath.addLine(to: CGPoint(x: curvePoints[i].x, y: curvePoints[i].y))
            
            // 计算当前点
            if hw_currentWidth > aimWidth {
                hw_currentWidth -= 0.15//0.05
            }else{
                hw_currentWidth += 0.15//0.05
            }
            if hw_currentWidth > hw_maxWidth {hw_currentWidth = hw_maxWidth}
            if hw_currentWidth < hw_minWidth {hw_currentWidth = hw_minWidth}
            
            // 画线
            bPath.lineWidth = hw_currentWidth
            bPath.lineCapStyle = .round
            bPath.lineJoinStyle = .round
            //UIColor(white: 0, alpha: (hw_currentWidth-hw_minWidth)/hw_maxWidth*0.3+0.1).setStroke()
            UIColor(red: rgb[0], green: rgb[1], blue: rgb[2], alpha: (hw_currentWidth-hw_minWidth)/hw_maxWidth*0.3+0.1).setStroke()
            bPath.stroke()
            
        }
        
        // 保存图片
        //self.hw_lastImage = UIGraphicsGetImageFromCurrentImageContext() // hw_lastImage
        
        let pointCount = Int(sqrt(pow(tempPoint2.x-hw_points[2].x,2)+pow(tempPoint2.y-hw_points[2].y,2)))*2
        let delX = (tempPoint2.x-hw_points[2].x)/CGFloat(pointCount)
        let delY = (tempPoint2.y-hw_points[2].y)/CGFloat(pointCount)
        
        var addRadius = hw_currentWidth
        
        // 尾部线段
        for i in 0..<(pointCount)
        {
            let bpath = UIBezierPath()
            bpath.move(to: lastPoint)
            
            let newPoint = CGPoint(x: lastPoint.x-delX, y: lastPoint.y-delY)
            lastPoint = newPoint
            
            bpath.addLine(to: newPoint)
            
            // 计算当前点
            if addRadius > aimWidth {
                addRadius -= 0.02
            }else{
                addRadius += 0.02
            }
            if addRadius > hw_maxWidth {addRadius = hw_maxWidth}
            if addRadius < 0 {addRadius=0}
            
            // 画线
            bpath.lineWidth = addRadius
            bpath.lineCapStyle = .round
            bpath.lineJoinStyle = .round
            //UIColor(white: 0, alpha: (hw_currentWidth-hw_minWidth)/hw_maxWidth*0.05+0.05).setStroke()
            UIColor(red: rgb[0], green: rgb[1], blue: rgb[2], alpha: (hw_currentWidth-hw_minWidth)/hw_maxWidth*0.05+0.05).setStroke()
            bpath.stroke()
            
        }
        
        self.imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        
        //UIGraphicsEndImageContext()
    }

    private func drawPenDown(_ touches: NSSet)
    {
        if Globals.hwBrush
        {
            if self.imageView.isHidden
            {
                UIGraphicsBeginImageContext(self.frame.size);
            }
            
            let touch : UITouch = touches.anyObject() as! UITouch
            let p : CGPoint = touch.location(in: self)
            self.hw_points = [p,p,p]
            self.hw_currentWidth = self.hw_defaultWidth
            drawBrush()
            self.bringSubviewToFront(self.imageView)
            self.imageView.isHidden = false
        }
        else
        {
            if self.imageView.isHidden
            {
                UIGraphicsBeginImageContext(self.frame.size);
            }
            let rgb = (KeyboardColor.mHwStrokeColor.cgColor).components!
            MyLog("\(rgb[0]), \(rgb[1]), \(rgb[2]), \(rgb[3])")
            
            UIGraphicsGetCurrentContext()!.setLineCap(CGLineCap.round);
            UIGraphicsGetCurrentContext()!.setLineWidth(3);
            UIGraphicsGetCurrentContext()!.setAllowsAntialiasing(true);
            UIGraphicsGetCurrentContext()!.setShouldAntialias(true);
            UIGraphicsGetCurrentContext()!.setStrokeColor(red: rgb[0], green: rgb[1], blue: rgb[2], alpha: rgb[3]);
            self.bringSubviewToFront(self.imageView)
            self.imageView.isHidden = false
        }
    }

    private func drawPenMove(_ touches: NSSet)
    {
        if Globals.hwBrush
        {
            let touch : UITouch = touches.anyObject() as! UITouch
            let p : CGPoint = touch.location(in: self)
            hw_points = [hw_points[1],hw_points[2],p]
            drawBrush()
        }
        else
        {
            let touch : UITouch = touches.anyObject() as! UITouch
            let location : CGPoint = touch.location(in: self)
            let pastLocation : CGPoint = touch.previousLocation(in: self)
            
            // draw lines
            UIGraphicsGetCurrentContext()!.beginPath();
            UIGraphicsGetCurrentContext()!.move(to: CGPoint(x: pastLocation.x, y: pastLocation.y));
            UIGraphicsGetCurrentContext()!.addLine(to: CGPoint(x: location.x, y: location.y));
            UIGraphicsGetCurrentContext()!.strokePath();
            self.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
        }
    }

    private func drawPenClear()
    {
        //CGContextClosePath(UIGraphicsGetCurrentContext());
        UIGraphicsEndImageContext();
        self.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
        self.imageView.isHidden = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        // 开始手写
        if self.enableHandWriting
        {
            for obj in touches
            {
                let touch = obj as UITouch
                let position = touch.location(in: self)
                if self.hwRect != nil && CGRectContainsPoint(self.hwRect!, position)
                {
                    if self.strokeAry.count == 0
                    {
                        self.delegate?.didHwBegin()
                    }
                    self.delegate?.didHwPenDown()
                    self.drawPenDown(touches as NSSet)
                    self.strokeAry.append(Int16(position.x))
                    self.strokeAry.append(Int16(position.y))
                    self.writting = true
                    return
                }
            }
        }
        
        for obj in touches
        {
            let touch = obj as UITouch
            let position = touch.location(in: self)
            if let view = self.enableHandWriting ? findPointView(position) : findNearestView(position)
            {
                self.touchToView[touch] = view
                self.handleControl(view, controlEvent: .touchDown)
                if touch.tapCount > 1
                {
                    // two events, I think this is the correct behavior but I have not tested with an actual UIControl
                    self.handleControl(view, controlEvent: .touchDownRepeat)
                }
            }
        }

        // 计算按下键
        if self.enableSwypeWriting
        {
            self.downKey = self.findPointOnView(touches as NSSet, withEvent: event)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        // 手写中
        if self.enableHandWriting && self.writting
        {
            for obj in touches
            {
                let touch = obj as UITouch
                let position = touch.location(in: self)
            
                self.strokeAry.append(Int16(position.x))
                self.strokeAry.append(Int16(position.y))
                self.drawPenMove(touches as NSSet)
                return
            }
        }
        
        if !self.enableGesture
        {
            for obj in touches
            {
                let touch = obj as UITouch
                let position = touch.location(in: self)
            
                let view = self.touchToView[touch]
                if let newView = self.enableHandWriting ? findPointView(position) : findNearestView(position)
                {
                    if view != newView
                    {
                        self.handleControl(view, controlEvent: .touchUpOutside)
                        self.touchToView[touch] = newView
                        self.handleControl(newView, controlEvent: .touchDown)
                    }
                    else
                    {
                        self.handleControl(view, controlEvent: .touchDragInside)
                    }
                }
            }
        }

        // 开始滑行
        if self.enableSwypeWriting
        {
            self.currentKey = self.findPointOnView(touches as NSSet, withEvent: event)
            
            if self.downKey != nil && self.writting == false && self.currentKey != self.downKey
            {
                self.drawPenDown(touches as NSSet)
                self.writting = true
            }
            if self.writting
            {
                self.drawPenMove(touches as NSSet)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        // 手写结束
        if self.enableHandWriting && self.writting
        {
            self.strokeAry.append(Int16(-1))
            self.strokeAry.append(Int16(0))
            self.delegate?.didHwPenUp()
            
            //self.drawPenUp(touches)
            self.writting = false
            return
        }
        
        if self.touchToView.count > 0
        {
            for obj in touches
            {
                let touch = obj as UITouch
                let view = self.touchToView[touch]
                self.handleControl(view, controlEvent: .touchUpInside)
                self.touchToView.removeValue(forKey: touch)
            }
        }
        
        // 手写、滑行结束
        if self.enableSwypeWriting
        {
            if self.writting
            {
                self.drawPenClear()
                self.writting = false
            }
            self.downKey = nil
            self.currentKey = nil
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?)
    {
        if self.touchToView.count > 0
        {
            if let touchesOK = touches
            {
                for obj in touchesOK
                {
                    let touch = obj as UITouch
                    let view = self.touchToView[touch]
                    self.handleControl(view, controlEvent: .touchCancel)
                    self.touchToView.removeValue(forKey: touch)
                }
            }
        }
    }
}




/**
 *分解贝塞尔曲线
 */
class AFBezierPath {
    
    /**
     fromPoint:起始点
     toPoint:终止点
     controlPoints:控制点数组
     count:分解数量
     返回:分解的点集
     */
    class func curveFactorization(_ fromPoint:CGPoint, toPoint: CGPoint, controlPoints:[CGPoint], countIn:Int) -> [CGPoint]{
        var count = countIn
        
        //如果分解数量为0，生成默认分解数量
        if count == 0 {
            let x1 = abs(fromPoint.x-toPoint.x)
            let x2 = abs(fromPoint.y-toPoint.y)
            count = Int(sqrt(pow(x1, 2) + pow(x2,2)))
        }
        
        // 贝赛尔曲线的计算
        var s:CGFloat = 0.0
        var t:[CGFloat] = [CGFloat]()
        let pc:CGFloat = 1/CGFloat(count)
        
        let power = controlPoints.count + 1
        
        for _ in 0...count+1 {t.append(s);s=s+pc}
        
        var newPoint:[CGPoint] = [CGPoint]()
        
        for i in 0...count+1 {
            
            var resultX = fromPoint.x * bezMaker(power, k:0, t:t[i])
                + toPoint.x * bezMaker(power, k:power, t:t[i])
            
            for j in 1...power-1 {
                resultX += controlPoints[j-1].x * bezMaker(power, k:j, t:t[i])
            }
            
            var resultY = fromPoint.y * bezMaker(power, k:0, t:t[i])
                + toPoint.y * bezMaker(power, k:power, t:t[i])
            
            for j in 1...power-1 {
                resultY += controlPoints[j-1].y * bezMaker(power, k:j, t:t[i])
            }
            
            newPoint.append(CGPoint(x: resultX, y: resultY))
            
        }
        
        return newPoint
    }
    
    private class func comp(_ n:Int, k:Int) -> CGFloat{
        var s1:Int = 1
        var s2:Int = 1
        
        if k == 0 {return 1}
        
        for i in stride(from: n, through: n-k+1, by: -1) {s1=s1*i}
        for i in stride(from: k, through: 2, by: -1) {s2=s2*i}
        
        return CGFloat(s1/s2)
    }
    
    private class func realPow(_ n:CGFloat, k:Int) -> CGFloat{
        if k==0 {return 1.0}
        return pow(n, CGFloat(k))
    }
    
    private class func bezMaker(_ n:Int, k:Int, t:CGFloat) -> CGFloat{
        return comp(n, k: k) * realPow(1-t, k: n-k) * realPow(t, k: k)
    }
}




