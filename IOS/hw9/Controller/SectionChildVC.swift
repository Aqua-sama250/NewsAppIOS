//
//  SectionChildVC.swift
//  hw9
//
//  Created by Tianhao Zhang on 5/3/20.
//  Copyright © 2020 Tianhao Zhang. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Alamofire
import SwiftyJSON
import SwiftSpinner

class SectionChildVC: UIViewController, IndicatorInfoProvider {
    
    var section: String = ""
    var newsList : [News] = []
    var tableView = UITableView()
    let baseUrl = base + "/GuardianApi/section/"
    
    var refreshController = UIRefreshControl()
    
    struct Cells {
        static let newsCell = "NewsCell"
        static let weatherCell = "WeatherCell"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureTableView()
        
        SwiftSpinner.show("Loading " + section + " Page..");
        fetchNews(baseUrl, onSuccess: {(result) in
            self.newsList = result as! [News];
            self.tableView.reloadData();
            SwiftSpinner.hide();
        })
        
        //refresh
        refreshController.addTarget(self, action:  #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshController)
    }
    
    @objc func refresh(){
        fetchNews(baseUrl, onSuccess: { (result) in
            self.newsList = result as! [News];
            self.tableView.reloadData();
            self.refreshController.endRefreshing();
        })
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: section)
    }
    
    func set(section:String){
        self.section = section
    }
    
    func configureTableView(){
        view.addSubview(tableView)
        tableView.rowHeight = 130
        setTableViewConstraints()
        setTableViewDelegates()
        tableView.register(NewsCell.self , forCellReuseIdentifier: Cells.newsCell)
        tableView.register(WeatherCell.self , forCellReuseIdentifier: Cells.weatherCell)
    }
    
    func setTableViewDelegates(){
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setTableViewConstraints(){
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
    }

}

extension SectionChildVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return newsList.count
       
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
//        return CGFloat(indexPath.row * 20)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.newsCell) as! NewsCell
        let news = newsList[indexPath.row]
        cell.set(news: news)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let myVC = storyboard.instantiateViewController(withIdentifier: "thirdView") as! DetailVC
        myVC.set(news: self.newsList[indexPath.row])
        self.navigationController?.pushViewController(myVC, animated: true)
    }
}

extension SectionChildVC{
    func fetchNews(_ params: String,
               onSuccess success: @escaping (_ JSON: Any) -> Void) -> Void {
        print(baseUrl + self.section.lowercased())
        AF.request(baseUrl + self.section.lowercased(), method: .get).responseJSON{
            response in
            switch response.result {
            case .success(let data):
                let json = JSON(data)
                var newsList : [News] = []
                for (_,subJson):(String, JSON) in json {
                    let imageUrl = subJson["image"].string
                    let url = URL(string: imageUrl!)
                    let data = try? Data(contentsOf: url!)
                    let image = UIImage(data: data!)
                    
                    let title = subJson["title"].string
                    let timediff = subJson["timediff"].string
                    let time = subJson["time"].string
                    let section = subJson["section"].string
                    let articleId = subJson["id"].string
                    let isBookmarked = checkStorage(articleId: articleId!) ? "true" : "false"
                    newsList.append(News(imageUrl: imageUrl!, title: title!, time: time!, timediff: timediff!, section: section!, articleId: articleId!, isBookmarked: isBookmarked))
                }
                success(newsList)
                break
            case .failure(let error):
                print(error)
            }
        }
    }
}
