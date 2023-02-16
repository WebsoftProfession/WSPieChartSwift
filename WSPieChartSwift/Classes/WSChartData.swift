//
//  ChartModel.swift
//  PieChartSwift
//
//  Created by praveen on 20/01/23.
//

import Foundation
import UIKit


public struct WSChartData {
    let value: Float
    let color: UIColor
    let title: String?
    
    public init(value:Float, color: UIColor, title: String = ""){
        self.value = value
        self.color = color
        self.title = title
    }
    
}
