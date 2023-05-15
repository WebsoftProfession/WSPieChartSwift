//
//  DSPieChartView.swift
//  PieChartSwift
//
//  Created by praveen on 20/01/23.
//

import UIKit


public protocol WSPieChartViewDelegate {
    func valueForDataInChart(for index: Int) -> WSChartData
    func didSelectChartIndex(index: Int)
    func datasetForChart() -> [WSChartData]
}


public class WSPieChartView: UIView {
    
    
    private var outlineAreaPath: UIBezierPath!
    
    public var delegate: WSPieChartViewDelegate?
    
    private var timer:Timer?
    
    private var isAnimationCompleted = true
    
    private var previousData = [Double]()
    private var previousEndData = 0.0
    private var animationDataValue = [Double]()
    
    private var reduceRatio: Float = 0.0
    
    public var titleColor: UIColor = .black
    public var titleFont = UIFont.systemFont(ofSize: 14)
    
    
    private var arcPaths = [UIBezierPath]()
    private var activeIndex = -1
    var isInitialStage = true
    private var totalCalculatedValue:Double = 100.0
    
    private var variationIncreaseDecrease:Double = 0.0
    
    /*
     // Only override draw() if you perform custom drawing.
     public  // An empty implementation adversely affects performance during animation.*/
    public override func draw(_ rect: CGRect) {
        // Drawing code
        
        outlineAreaPath = UIBezierPath.init(roundedRect: rect, cornerRadius: rect.width / 2)
        
        let insetRect = rect.inset(by: .init(top: 40, left: 40, bottom: 40, right: 40))
        arcPaths.removeAll()
        previousEndData = 0.0
        
        var startData = 0.0
        var endData = 0.0
        var centerPoint = CGPoint.zero
        
        
        if isInitialStage {
            previousData.removeAll()
        }
        
        if let datasets = self.delegate?.datasetForChart() {
            totalCalculatedValue = round(datasets.compactMap({ $0.value }).reduce(0.0, +))
        }
        
        
        for dataset in self.delegate?.datasetForChart() ?? [] {
            let index = self.delegate!.datasetForChart().firstIndex(of: dataset)
            let arcPath = UIBezierPath()
            centerPoint = CGPoint.init(x: insetRect.midX, y: insetRect.midY)
            
            if isInitialStage {
                if index == 0 {
                    startData = 0
                }
                else{
                    let previousDataset = self.delegate!.datasetForChart()[index! - 1]
                    startData += (previousDataset.value / totalCalculatedValue) * 100
                }
                
                endData = (dataset.value / totalCalculatedValue) * 100
                endData += startData
                endData = round(endData)
                previousData.append(round((dataset.value / totalCalculatedValue) * 100))
            }
            else {
                if index == 0 {
                    startData = 0
                    endData = startData + round((dataset.value / totalCalculatedValue) * 100)
                }
                else{
//                    let previousDataset = self.delegate!.datasetForChart()[index! - 1]
//                    startData += (previousDataset.value / totalCalculatedValue) * 100
                    
                    startData += round(previousData[index! - 1])
                    
                    endData = round((dataset.value / totalCalculatedValue) * 100)
                    
//                    if index! == (self.delegate!.datasetForChart().count-1)  {
//                        endData = 100 - startData
//                    }
//                    else {
//                        endData = round((dataset.value / totalCalculatedValue) * 100)
//                    }
                }
                
                if previousData[index!] != endData {
                    if previousData[index!] > endData  {
                        // need to decrease
                        if variationIncreaseDecrease > 0 {
                            previousData[index!] -= (1 + variationIncreaseDecrease)
                        }
                        else {
                            previousData[index!] -= 1
                        }
                        if previousData[index!] < endData {
                            previousData[index!] = endData
                        }
                        else {
                            endData = previousData[index!]
                        }
                    }
                    else {
                        // need to increase
                        if variationIncreaseDecrease > 0 {
                            previousData[index!] += 1
                        }
                        else {
                            previousData[index!] += (1 + (variationIncreaseDecrease * -1))
                        }
                        
                        if previousData[index!] > endData {
                            previousData[index!] = endData
                        }
                        else {
                            endData = previousData[index!]
                        }
                    }
                    
                    endData += startData
                    print("StartData: \(startData)")
                    print("EndData: \(endData)")
                }
                else {
                    endData = previousData[index!]
                    endData += startData
                    print("StartData: \(startData)")
                    print("EndData: \(endData)")
                }
            }

            /*
            if isInitialStage {
                animationDataValue.append(0.0)
            }
            else{
                
                if animationDataValue[index!] != 0 {
                    if index == 0 {
                        if animationDataValue[index!] > 0 {
                            // increase case
                            animationDataValue[index!] -= 1
                            endData -= animationDataValue[index!]
                        }
                        else{
                            // decrease case
                            animationDataValue[index!] += 1
                            endData += (-1 * animationDataValue[index!])
                        }
                    }
                    else{
//                        if endData >= 100 {
//                            endData = 100
//                            if animationDataValue[index!] > 0 {
//                                animationDataValue[index!] -= 1
//                                startData += animationDataValue[index!]
//                            }
//                            else{
//                                animationDataValue[index!] += 1
//                                startData += animationDataValue[index!]
//                            }
//                        }
//                        else{
//                            startData = previousEndData
//                            if animationDataValue[index!] > 0 {
//                                // increase case
//                                animationDataValue[index!] -= 1
//                                endData += animationDataValue[index!]
//                            }
//                            else{
//                                // decrease case
//                                animationDataValue[index!] += 1
//                                endData -= 1
//                            }
//                        }
                        
                        startData = previousEndData
                        if animationDataValue[index!] > 0 {
                            // increase case
                            animationDataValue[index!] -= 1
                            endData += animationDataValue[index!]
                        }
                        else{
                            // decrease case
                            animationDataValue[index!] += 1
                            endData -= 1
                        }
                    }
                }
            }*/
            
            
            let midPointArc = self.getMidPointOfArc(withStartValue: Float(startData), andEndValue: Float(endData), andCenter: centerPoint, andRadious: 3)
            arcPath.move(to: midPointArc)
            
            
            arcPath.addArc(withCenter: midPointArc, radius: insetRect.width / 2, startAngle: self.calculateRadious(withValue: startData), endAngle: self.calculateRadious(withValue: endData), clockwise: true)
            
            if activeIndex == index {
                let glowArcPath = UIBezierPath()
                glowArcPath.addArc(withCenter: midPointArc, radius: insetRect.width / 1.94, startAngle: self.calculateRadious(withValue: startData), endAngle: self.calculateRadious(withValue: endData), clockwise: true)
                glowArcPath.lineWidth = 8
                dataset.color.withAlphaComponent(0.4).setStroke()
                glowArcPath.stroke()
            }
            
            dataset.color.setFill()
            arcPath.lineWidth = 15
            arcPath.close()
            arcPath.fill()
            previousEndData = endData
            
            // Draw title at mid point of arc path
            let midPointForTitle = self.getMidPointOfArc(withStartValue: Float(startData), andEndValue: Float(endData), andCenter: centerPoint, andRadious: insetRect.width / 4)
            self.drawTitle(dataset.title ?? "", with: titleFont, in: CGRect.init(x: midPointForTitle.x-25, y: midPointForTitle.y-25, width: 50, height: 50))
            arcPaths.append(arcPath)
            
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
        
        var decreaseCount = 0.0
        var increaseCount = 0.0
        
        if previousData.count ==  (self.delegate?.datasetForChart() ?? []).count {
            isInitialStage = false
            if let datasets = self.delegate?.datasetForChart() {
                totalCalculatedValue = round(datasets.compactMap({ $0.value }).reduce(0.0, +))
            }
            
            var variation = 100 / (self.delegate?.datasetForChart() ?? []).count
            
            for dataset in self.delegate?.datasetForChart() ?? [] {
                let index = self.delegate!.datasetForChart().firstIndex(of: dataset)
                let newValue = round((dataset.value / totalCalculatedValue) * 100)
                let oldValue = previousData[index!]
                let ratioValue = newValue - oldValue
                if ratioValue < 0 {
                    decreaseCount += 1
                }
                else {
                    increaseCount += 1
                }
//                previousData[index!] = newValue
                animationDataValue.append(Double(ratioValue))
            }
        }
        else {
            isInitialStage = true
        }
        
        variationIncreaseDecrease = increaseCount - decreaseCount
        
        
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }

        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(runAnimation), userInfo: nil, repeats: true)
        isAnimationCompleted = false
    }
    
    @objc private func runAnimation(){
        
        self.isAnimationCompleted = true
//        if self.previousData.count == 0 {
//            self.isAnimationCompleted = true
//        }
        
        let dataSet = self.delegate?.datasetForChart() ?? []
        
        if dataSet.count == self.previousData.count {
            for index in 0..<dataSet.count {
                let calculatedValue = round((dataSet[index].value / totalCalculatedValue) * 100)
                if calculatedValue != self.previousData[index] {
                    self.isAnimationCompleted = false
                }
            }
        }
        
//        self.previousData.forEach { value1 in
//            dataSet.forEach { value2 in
//                let calculatedValue = round((value2.value / totalCalculatedValue) * 100)
//                if calculatedValue != value1 {
//                    self.isAnimationCompleted = false
//                }
//            }
//        }
        
//        if self.previousData.elementsEqual(dataSet, by: { $0 != round(($1.value / totalCalculatedValue) * 100) }) {
//            self.isAnimationCompleted = false
//        }
        
        
//        self.previousData.forEach { value in
//            if value != 0 {
//                self.isAnimationCompleted = false
//            }
//        }
        if self.isAnimationCompleted {
            timer?.invalidate()
            isInitialStage = true
        }
        else{
//            self.setNeedsDisplay()
        }
        self.setNeedsDisplay()
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
                isInitialStage = true
                self.setNeedsDisplay()
            }
        }
        
    }
    
}
