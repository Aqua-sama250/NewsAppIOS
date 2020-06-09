/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The table view controller responsible for displaying the filtered products as the user types in the search field.
*/

import UIKit
import Alamofire
import SwiftyJSON

class ResultsTableController: UITableViewController {
    
    let tableViewCellIdentifier = "cellID"

    var suggestResults : [String] = []
    
    @IBOutlet weak var resultsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(SuggestResultCell.self, forCellReuseIdentifier: tableViewCellIdentifier)
        tableView.rowHeight = 45
        
    }
    
    func set(results: [String]){
        suggestResults = results
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifier) as! SuggestResultCell
        cell.set(data: suggestResults[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NotificationCenter.default.post(name: .didReceiveData, object: self, userInfo: ["keyword" : suggestResults[indexPath.row]])
    }
}

extension ResultsTableController{
    func fetchData(keyword: String, onSuccess success: @escaping (_ JSON: Any) -> Void){
        AF.request("https://api.cognitive.microsoft.com/bing/v7.0/suggestions",parameters:["q":keyword],headers: ["bing autosuggest key"] ).responseJSON{
            response in
            switch response.result {
            case .success(let data):
                let json = JSON(data)
                var resultList:[String] = []
                for (_,result) in json["suggestionGroups"][0]["searchSuggestions"]{
                    resultList.append(result["displayText"].string!)
                }
                success(resultList)
                break
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension Notification.Name {
    static let didReceiveData = Notification.Name("didReceiveData")
    static let didCompleteTask = Notification.Name("didCompleteTask")
    static let completedLengthyDownload = Notification.Name("completedLengthyDownload")
    static let didDeleteBookmark = Notification.Name("didDeleteBookmark")
}
