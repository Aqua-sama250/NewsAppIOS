//
//  PagerStripVC.swift
//  hw9
//
//  Created by Tianhao Zhang on 5/3/20.
//  Copyright © 2020 Tianhao Zhang. All rights reserved.
//

import Foundation
import XLPagerTabStrip

class PagerStripVC: ButtonBarPagerTabStripViewController{
    

    let purpleInspireColor = UIColor(red:0.13, green:0.03, blue:0.25, alpha:1.0)
    var resultSearchController: UISearchController!
    private var resultsTableController: ResultsTableController!
    
    override func viewDidLoad() {
        configureSearch()

        // change selected bar color
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.selectedBarBackgroundColor = .systemBlue
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 20)
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .systemBlue
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        changeCurrentIndexProgressive = {
            [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = UIColor(red: 150/255, green: 150/255, blue: 150/255, alpha: 1.0)
            newCell?.label.textColor = .systemBlue
        }
        super.viewDidLoad()
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
        resultSearchController.hidesNavigationBarDuringPresentation = false
    }
    
    @objc func onDidReceiveData(_ notification: Notification){
            let data:String = notification.userInfo!["keyword"] as! String
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let myVC = storyboard.instantiateViewController(withIdentifier: "searchResult") as! SearchVC
            myVC.set(section: data)
            self.navigationController?.pushViewController(myVC, animated: true)
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let sectionList = ["world","business","politics","sports","technology","science"]
        var children:[UIViewController] = []
        for section in sectionList{
            let childVC = SectionChildVC()
            childVC.set(section: section.uppercased())
            children.append(childVC)
        }
        return children
    }
}

extension PagerStripVC: UISearchResultsUpdating{
    
    func updateSearchResults(for searchController: UISearchController) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(getAutoSuggest), object: self)
        self.perform(#selector(getAutoSuggest), with: self, afterDelay: 1)
    }
    
    @objc func getAutoSuggest(){
        guard let text = resultSearchController.searchBar.text else { return }
        if (text.count >= 3){
            self.resultsTableController.fetchData(keyword: text, onSuccess: {(result) in
                self.resultsTableController.set(results: result as! [String])
            })
        }
        
    }
}
