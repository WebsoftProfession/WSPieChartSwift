//
//  ChartModel.swift
//  PieChartSwift
//
//  Created by praveen on 20/01/23.
//

import Foundation
import UIKit


public struct WSChartData: Equatable {
    let id = UUID()
    let value: Double
    let color: UIColor
    let title: String?
    
    public init(value:Double, color: UIColor, title: String = ""){
        self.value = value
        self.color = color
        self.title = title
    }
    
}
