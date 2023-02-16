//
//  ViewController.swift
//  WSPieChartSwift
//
//  Created by WebsoftProfession on 02/16/2023.
//  Copyright (c) 2023 WebsoftProfession. All rights reserved.
//

import UIKit
import WSPieChartSwift

class ViewController: UIViewController {

    
    @IBOutlet weak var chartControl: WSPieChartView!
    var chartDataArray = [WSChartData]()
    
    @IBOutlet weak var txtField1: UITextField!
    @IBOutlet weak var txtField2: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        chartControl.delegate = self
        chartControl.titleFont = .systemFont(ofSize: 18)
        chartControl.titleColor = .white
        chartDataArray.append(WSChartData(value: 20, color: .systemGreen, title: "20%"))
        chartDataArray.append(WSChartData(value: 80, color: .systemRed, title: "80%"))
    }
    
    @IBAction func reloadClicked(_ sender: Any) {
        self.view.endEditing(true)
        chartDataArray.removeAll()
        chartDataArray.append(WSChartData(value: Float(txtField1.text ?? "0") ?? 0.0, color: .systemGreen, title: "\(txtField1.text ?? "0")%"))
        chartDataArray.append(WSChartData(value: Float(txtField2.text ?? "0") ?? 0.0, color: .systemRed, title: "\(txtField2.text ?? "0")%"))
        chartControl.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: WSPieChartViewDelegate {
    
    func numberOfDataInChart() -> Int {
        return chartDataArray.count
    }
    
    func valueForDataInChart(for index: Int) -> WSChartData {
        return chartDataArray[index]
    }
    
    func didSelectChartIndex(index: Int) {
        // Show some more detailed information anywhere on screen for selected aread index
    }
}

