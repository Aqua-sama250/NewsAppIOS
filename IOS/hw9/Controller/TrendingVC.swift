//
//  TrendingVC.swift
//  hw9
//
//  Created by Tianhao Zhang on 5/3/20.
//  Copyright © 2020 Tianhao Zhang. All rights reserved.
//

import UIKit
import Charts
import Alamofire
import SwiftyJSON

class TrendingVC: UIViewController {
    
    var hintLabel = UILabel()
    var trendingText = UITextField()
    let baseUrl = base + "/trendingApi/"
    lazy var lineChartView: LineChartView = {
        let chartView = LineChartView()
        return chartView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTrendingVC()
        setData(keywords: "Coronavirus")
        
        trendingText.delegate = self
        trendingText.placeholder = "Enter Search term.."
    }
    
    func setData(keywords: String){
        fetchData(keywords, onSuccess: {(result) in
            let set1 = LineChartDataSet(entries: (result as! [ChartDataEntry]), label: "Trending Chart for " + keywords)//input
            set1.colors = [UIColor(red: 0/255, green: 122/255, blue: 250/255, alpha: 1.0)]
            set1.circleRadius = 5
            set1.circleHoleRadius = 0
            set1.circleColors = [UIColor(red: 0/255, green: 122/255, blue: 250/255, alpha: 1.0)]
            
            let data = LineChartData(dataSet: set1)
            self.lineChartView.data = data
        })
    }
    
    func setTrendingVC(){
        view.addSubview(hintLabel)
        view.addSubview(trendingText)
        view.addSubview(lineChartView)
        
        hintLabel.text = "Enter Search Term";
        trendingText.borderStyle = .roundedRect
        setHintLabelConstraint();
        setTrendingTextConstraint();
        setLineViewConstraint();
    }
}

extension TrendingVC : ChartViewDelegate, UITextFieldDelegate{
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField.text != ""){
            self.setData(keywords: textField.text!)
        }
        return true
    }
    
}

extension TrendingVC{
    func fetchData(_ params: String,
               onSuccess success: @escaping (_ JSON: Any) -> Void) -> Void {
        AF.request(baseUrl + params, method: .get).responseJSON{
            response in
            switch response.result {
            case .success(let data):
                let json = JSON(data)
                var dataList : [ChartDataEntry] = []
                for (index,subJson):(String, JSON) in json {
                    dataList.append(ChartDataEntry(x: Double(index)!, y: subJson.double!))
                }
                success(dataList)
                break
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension TrendingVC{
    func setHintLabelConstraint(){
        hintLabel.translatesAutoresizingMaskIntoConstraints = false
        hintLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        hintLabel.topAnchor.constraint(equalTo: view.topAnchor,constant: 200).isActive = true
    }
    
    func setTrendingTextConstraint(){
        trendingText.translatesAutoresizingMaskIntoConstraints = false
        trendingText.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        trendingText.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        trendingText.topAnchor.constraint(equalTo: hintLabel.bottomAnchor, constant: 30).isActive = true
    }
    
    func setLineViewConstraint(){
        lineChartView.translatesAutoresizingMaskIntoConstraints = false
        lineChartView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        lineChartView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        lineChartView.topAnchor.constraint(equalTo: trendingText.bottomAnchor, constant: 40).isActive = true
        lineChartView.heightAnchor.constraint(equalTo: lineChartView.widthAnchor).isActive = true
    }
}
