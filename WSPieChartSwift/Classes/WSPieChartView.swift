//
//  DSPieChartView.swift
//  PieChartSwift
//
//  Created by praveen on 20/01/23.
//

import UIKit


public protocol WSPieChartViewDelegate {
    func numberOfDataInChart() -> Int
    func valueForDataInChart(for index: Int) -> WSChartData
    func didSelectChartIndex(index: Int)
}


public class WSPieChartView: UIView {
    
    
    private var outlineAreaPath: UIBezierPath!
    
    public var delegate: WSPieChartViewDelegate?
    
    private var timer:Timer?
    
    private var isAnimationCompleted = true
    
    private var previousData = [Float]()
    private var previousEndData = 0.0
    private var animationDataValue = [Double]()
    
    private var reduceRatio: Float = 0.0
    
    public var titleColor: UIColor = .black
    public var titleFont = UIFont.systemFont(ofSize: 14)
    
    
    private var arcPaths = [UIBezierPath]()
    private var activeIndex = -1
    /*
     // Only override draw() if you perform custom drawing.
     public  // An empty implementation adversely affects performance during animation.*/
    public override func draw(_ rect: CGRect) {
        // Drawing code
        
        outlineAreaPath = UIBezierPath.init(roundedRect: rect, cornerRadius: rect.width / 2)
        
        let insetRect = rect.inset(by: .init(top: 40, left: 40, bottom: 40, right: 40))
        arcPaths.removeAll()
        previousEndData = 0.0
        if let numberOfData = self.delegate?.numberOfDataInChart() {
            var previousEndData = 0.0
            previousData = [Float]()
            var startData = 0.0
            var endData = 0.0
            var centerPoint = CGPoint.zero
            var isInitialStage = false
            
            if animationDataValue.count == 0 {
                isInitialStage = true
            }
            
            
            for index in 0..<numberOfData {
                
                let arcPath = UIBezierPath()
                if index == 0 {
                    startData = 0
                }
                else{
                    startData += Double(self.delegate?.valueForDataInChart(for: index - 1).value ?? 0.0)
                }
                
                centerPoint = CGPoint.init(x: insetRect.midX, y: insetRect.midY)
                endData = Double(self.delegate?.valueForDataInChart(for: index).value ?? 0.0)
                
                endData += startData
                
                if endData > 100 || (index == numberOfData - 1 && endData < 100) {
                    endData = 100
                    assertionFailure("Invalid chart data")
                }
                
                if isInitialStage {
                    animationDataValue.append(0.0)
                }
                else{
                    if animationDataValue[index] != 0 {
                        if index == 0 {
                            if animationDataValue[index] > 0 {
                                // increase case
                                animationDataValue[index] -= 1
                                endData -= animationDataValue[index]
                            }
                            else{
                                // decrease case
                                animationDataValue[index] += 1
                                endData += (-1 * animationDataValue[index])
                            }
                        }
                        else{
                            if endData >= 100 {
                                endData = 100
                                if animationDataValue[index] > 0 {
                                    animationDataValue[index] -= 1
                                    startData += animationDataValue[index]
                                }
                                else{
                                    animationDataValue[index] += 1
                                    startData += animationDataValue[index]
                                }
                            }
                            else{
                                startData = previousEndData
                                if animationDataValue[index] > 0 {
                                    // increase case
                                    animationDataValue[index] -= 1
                                    endData += animationDataValue[index]
                                }
                                else{
                                    // decrease case
                                    animationDataValue[index] += 1
                                    endData -= 1
                                }
                            }
                        }
                    }
                }
                
                previousData.append(self.delegate?.valueForDataInChart(for: index).value ?? 0.0)
                let midPointArc = self.getMidPointOfArc(withStartValue: Float(startData), andEndValue: Float(endData), andCenter: centerPoint, andRadious: 3)
                
                arcPath.move(to: midPointArc)
                
                
                arcPath.addArc(withCenter: midPointArc, radius: insetRect.width / 2, startAngle: self.calculateRadious(withValue: startData), endAngle: self.calculateRadious(withValue: endData), clockwise: true)
                
                if activeIndex == index {
                    let glowArcPath = UIBezierPath()
                    glowArcPath.addArc(withCenter: midPointArc, radius: insetRect.width / 1.94, startAngle: self.calculateRadious(withValue: startData), endAngle: self.calculateRadious(withValue: endData), clockwise: true)
                    glowArcPath.lineWidth = 8
                    (self.delegate?.valueForDataInChart(for: index).color ?? .clear).withAlphaComponent(0.4).setStroke()
                    glowArcPath.stroke()
                }
                
                (self.delegate?.valueForDataInChart(for: index).color ?? .clear).setFill()
                arcPath.lineWidth = 15
                arcPath.close()
                arcPath.fill()
                previousEndData = endData
                
                // Draw title at mid point of arc path
                let midPointForTitle = self.getMidPointOfArc(withStartValue: Float(startData), andEndValue: Float(endData), andCenter: centerPoint, andRadious: insetRect.width / 4)
                self.drawTitle((self.delegate?.valueForDataInChart(for: index).title) ?? "", with: titleFont, in: CGRect.init(x: midPointForTitle.x-25, y: midPointForTitle.y-25, width: 50, height: 50))
                arcPaths.append(arcPath)
            }
        }
    }
    
    func calculateRadious(withValue value: CGFloat) -> CGFloat {
        let pieValue: CGFloat = .pi
        let redious = (value * 2 * pieValue) / 100
        return redious
    }
    
    func getMidPointOfArc(withStartValue startValue: Float, andEndValue endValue: Float, andCenter centerPoint: CGPoint, andRadious radious: CGFloat) -> CGPoint {
        let new = UIBezierPath()
        let midValue = fabsf((endValue - startValue) / 2) + startValue
        new.addArc(withCenter: centerPoint, radius: radious, startAngle: calculateRadious(withValue: CGFloat(startValue)), endAngle: calculateRadious(withValue: CGFloat(midValue)), clockwise: true)
        var endPoint = CGPoint.zero
        endPoint = new.cgPath.currentPoint
        return endPoint
    }
    
    public func reloadData(){
        animationDataValue.removeAll()
        activeIndex = -1
        let count = self.delegate?.numberOfDataInChart() ?? 0
        for index in 0..<count {
            let newValue = self.delegate?.valueForDataInChart(for: index).value ?? 0.0
            let oldValue = previousData[index]
            let ratioValue = newValue - oldValue
            animationDataValue.append(Double(ratioValue))
        }
        
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }

        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(runAnimation), userInfo: nil, repeats: true)
        isAnimationCompleted = false
    }
    
    @objc private func runAnimation(){
        
        self.isAnimationCompleted = true
        self.animationDataValue.forEach { value in
            if value != 0 {
                self.isAnimationCompleted = false
            }
        }
        if self.isAnimationCompleted {
            timer?.invalidate()
        }
        else{
            self.setNeedsDisplay()
        }
    }
    
    func drawTitle(_ title: String, with font: UIFont?, in contextRect: CGRect) {
        /// Make a copy of the default paragraph style
        let paragraphStyle = NSMutableParagraphStyle()
        /// Set line break mode
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.alignment = NSTextAlignment.center
        var attributes: [NSAttributedString.Key : Any]?
        
        attributes = [
            NSAttributedString.Key.font: font ?? UIFont.systemFont(ofSize: 12),
            NSAttributedString.Key.foregroundColor: titleColor,
            NSAttributedString.Key.paragraphStyle: paragraphStyle
        ]
        let size = title.size(withAttributes: attributes)
        let textRect = CGRect(
            x: contextRect.origin.x + Double(floorf(Float((contextRect.size.width - size.width) / 2))),
            y: contextRect.origin.y + Double(floorf(Float((contextRect.size.height - size.height) / 2))),
            width: size.width,
            height: size.height)
        title.draw(in: textRect, withAttributes: attributes)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        
        for path in arcPaths {
            if path.contains(location) {
                activeIndex = arcPaths.firstIndex(of: path) ?? -1
                self.delegate?.didSelectChartIndex(index: activeIndex)
                self.setNeedsDisplay()
            }
        }
        
    }
    
}
