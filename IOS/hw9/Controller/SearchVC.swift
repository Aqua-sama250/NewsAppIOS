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

class SearchVC: UIViewController, IndicatorInfoProvider {
    
    var section: String = ""
    var newsList : [News] = []
    var tableView = UITableView()
    let baseUrl = base + "/GuardianApi/search"
    
    var noResultLabel: UILabel!
    
    struct Cells {
        static let newsCell = "NewsCell"
        static let weatherCell = "WeatherCell"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureTableView()
        
        noResultLabel = UILabel()
        view.addSubview(noResultLabel)
        configureNoResultLabel()
        
        self.navigationItem.largeTitleDisplayMode = .automatic
        
        SwiftSpinner.show("Loading Search Results..");
        fetchNews(baseUrl, onSuccess: {(result) in
            self.newsList = result as! [News];
            self.tableView.reloadData();
            SwiftSpinner.hide();
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
    
    func configureNoResultLabel(){
        noResultLabel.text = "No search result"
        
        noResultLabel.translatesAutoresizingMaskIntoConstraints = false
        noResultLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        noResultLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

}

extension SearchVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.isHidden = newsList.count == 0
        self.noResultLabel.isHidden = newsList.count != 0
        
        return newsList.count
       
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
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

extension SearchVC{
    func fetchNews(_ params: String,
               onSuccess success: @escaping (_ JSON: Any) -> Void) -> Void {
        AF.request(baseUrl,method: .get, parameters: ["keyword":self.section.lowercased()]).responseJSON{
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
                    let isBookmarked = checkStorage(articleId: articleId!) ? "true" : "false";
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
