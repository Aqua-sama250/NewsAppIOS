//
//  HomeVC.swift
//  hw9
//
//  Created by Tianhao Zhang on 4/24/20.
//  Copyright © 2020 Tianhao Zhang. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation
import MapKit
import SwiftSpinner
import Toast_Swift

class HomeVC: UIViewController {
//    @IBOutlet weak var tableView: UITableView!
    
    private var pendingRequestWorkItem: DispatchWorkItem?
    
    var newsList : [News] = []
    
    var weather : Weather = Weather(city: "Not set", state: "Not set", temperature: "0", summary: "Not set")
    let locationManager = CLLocationManager()
    var location = CLPlacemark()
    let baseUrl = base + "/GuardianApi"
    var isLoadedNews = false
    var isLoadedWeather = false
    
    private var resultsTableController: ResultsTableController!
    var resultSearchController: UISearchController!
    
    var refreshController = UIRefreshControl()
    
    var tableView = UITableView()
    
    struct Cells {
        static let newsCell = "NewsCell"
        static let weatherCell = "WeatherCell"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureLocation()
        
        //fetchData
        SwiftSpinner.show("Loading Home Page..");
        fetchNews(baseUrl, onSuccess: {(result) in
            self.newsList = result as! [News];
            self.tableView.reloadData();
            self.isLoadedNews = true
            self.stopSpinner()
        })
        
        //refresh
        refreshController.addTarget(self, action:  #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshController)
        
        configureSearch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func configureSearch(){
        resultsTableController =
            self.storyboard?.instantiateViewController(withIdentifier: "ResultsTableController") as? ResultsTableController
        resultSearchController = UISearchController(searchResultsController: resultsTableController)
        //searchListener
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData(_:)), name: .didReceiveData, object: nil)
        
        
        navigationItem.searchController = resultSearchController
        resultSearchController.searchResultsUpdater = self
        resultSearchController.searchBar.placeholder = "Enter keyword.."
    }
    
    @objc func onDidReceiveData(_ notification: Notification){
            let data:String = notification.userInfo!["keyword"] as! String
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let myVC = storyboard.instantiateViewController(withIdentifier: "searchResult") as! SearchVC
            myVC.set(section: data)
            self.navigationController?.pushViewController(myVC, animated: true)
    }
    
    @objc func refresh(){
        fetchNews(baseUrl, onSuccess: { (result) in
            self.newsList = result as! [News];
            self.tableView.reloadData();
            self.refreshController.endRefreshing();
        })
    }
    
    func stopSpinner(){
        if(self.isLoadedNews && self.isLoadedWeather){
            SwiftSpinner.hide()
        }
    }
    
    func configureLocation(){
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()

        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func configureTableView(){
        view.addSubview(tableView)
        tableView.rowHeight = 130
        tableView.pin(to: view)
        setTableViewDelegates()
        tableView.register(NewsCell.self , forCellReuseIdentifier: Cells.newsCell)
        tableView.register(WeatherCell.self , forCellReuseIdentifier: Cells.weatherCell)
    }
    
    func setTableViewDelegates(){
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    /*
     // MARK: - Navigation
     // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    let stateCodes = ["AL","AK","AZ","AR","CA","CO","CT","DE","DC","FL","GA","HI","ID","IL","IN","IA","KS","KY","LA","ME","MD","MA","MI","MN","MS","MO","MT","NE","NV","NH","NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI","SC","SD","TN","TX","UT","VT","VA","WA","WV","WI","WY"]
    let fullStateNames = ["Alabama","Alaska","Arizona","Arkansas","California","Colorado","Connecticut","Delaware","District of Columbia","Florida","Georgia","Hawaii","Idaho","Illinois","Indiana","Iowa","Kansas","Kentucky","Louisiana","Maine","Maryland","Massachusetts","Michigan","Minnesota","Mississippi","Missouri","Montana","Nebraska","Nevada","New Hampshire","New Jersey","New Mexico","New York","North Carolina","North Dakota","Ohio","Oklahoma","Oregon","Pennsylvania","Rhode Island","South Carolina","South Dakota","Tennessee","Texas","Utah","Vermont","Virginia","Washington","West Virginia","Wisconsin","Wyoming"]
    
    func longStateName(_ stateCode:String) -> String {
        let dic = NSDictionary(objects: fullStateNames, forKeys:stateCodes as [NSCopying])
        return dic.object(forKey:stateCode) as? String ?? stateCode
    }

}

extension HomeVC: UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return newsList.count + 1
       
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if(indexPath.row == 0){
            return 160
        }else{
            return 140
        }
//        return CGFloat(indexPath.row * 20)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            // return weather cell
            let cell = WeatherCell()
            cell.set(weather: self.weather)
            cell.separatorInset = UIEdgeInsets.zero;
            return cell
        } else{
            let cell = tableView.dequeueReusableCell(withIdentifier: Cells.newsCell) as! NewsCell
            let news = newsList[indexPath.row - 1]
            cell.set(news: news)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row != 0){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let myVC = storyboard.instantiateViewController(withIdentifier: "thirdView") as! DetailVC
            myVC.set(news: self.newsList[indexPath.row - 1])
            self.navigationController?.pushViewController(myVC, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
//        print("locations = \(locValue.latitude) \(locValue.longitude)")
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(manager.location!,
                    completionHandler: { (placemarks, error) in
            if error == nil {
                let firstLocation = placemarks?[0]
                self.fetchWeather(placeMark: firstLocation!, onSuccess: {(result) in
                    self.weather = result as! Weather
                    self.tableView.reloadData()
                    self.isLoadedWeather = true
                    self.stopSpinner()
                })
            }
            else {
             // An error occurred during geocoding.
//                print(error as Any)
            }
        })
    }
    
}

extension HomeVC{
    
    func fetchWeather(placeMark: CLPlacemark,
                      onSuccess success: @escaping (_ JSON: Any) -> Void) -> Void{
        let params = ["q":placeMark.locality,"units":"metric","appid":"e704f9477f328261d28f7479836eaa03"]
        AF.request("https://api.openweathermap.org/data/2.5/weather",method: .get,parameters: params).responseJSON{
            response in
            switch response.result{
            case .success(let data):
                let json = JSON(data)
                let temp = String(Int(round(json["main"]["temp"].double!)))
                let weather = json["weather"][0]["main"].string
                let state = self.longStateName(placeMark.administrativeArea!)
                let res = Weather(city: placeMark.locality!, state: state, temperature: temp, summary: weather!)
                success(res)
                break
            case .failure(let err):
                print(err)
            }
        }
    }
        
    func fetchNews(_ params: String,
                   onSuccess success: @escaping (_ JSON: Any) -> Void) -> Void {
            print(baseUrl)
            AF.request(baseUrl, method: .get).responseJSON{
                response in
                switch response.result {
                case .success(let data):
                    let json = JSON(data)
                    var newsList : [News] = []
                    for (_,subJson):(String, JSON) in json {
                        let imageUrl = subJson["image"].string
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

extension UIView {
    func pin(to superView:UIView){
        translatesAutoresizingMaskIntoConstraints = false;
        topAnchor.constraint(equalTo: superView.topAnchor).isActive = true;
        bottomAnchor.constraint(equalTo: superView.bottomAnchor).isActive = true;
        leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: 10).isActive = true;
        trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: -10).isActive = true;
    }
}

extension HomeVC: UISearchResultsUpdating{
    
    func updateSearchResults(for searchController: UISearchController) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(getAutoSuggest), object: self)
        self.perform(#selector(getAutoSuggest), with: self, afterDelay: 1)
    }
    
    @objc func getAutoSuggest(){
        guard let text = resultSearchController.searchBar.text else { return }
        if(text.count >= 3){
            self.resultsTableController.fetchData(keyword: text, onSuccess: {(result) in
                self.resultsTableController.set(results: result as! [String])
            })
        }
    }
}
