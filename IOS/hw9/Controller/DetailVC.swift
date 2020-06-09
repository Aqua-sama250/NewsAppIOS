//
//  DetailVC.swift
//  hw9
//
//  Created by Tianhao Zhang on 5/2/20.
//  Copyright © 2020 Tianhao Zhang. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner

class DetailVC: UIViewController {
    
    var scrollView : DetailView = DetailView()
    let baseUrl = base + "/GuardianApi/article/"
    var news : News = News(imageUrl: "", title: "", time: "", timediff: "", section: "", articleId: "", isBookmarked: "")
    var article : ArticleDetail = ArticleDetail(image: UIImage(), articleUrl: "", section: "", title: "", date: "", description: NSMutableAttributedString())
    var isBookMarked : Bool = false
    var isLoadedDetailView : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(scrollView)
        setScrollViewConstraints()
        configureNavigationItem()
        
        SwiftSpinner.show("Loading Detailed article..");
        fetchData(news.articleId, onSuccess: {(result) in
            self.article = result as! ArticleDetail
            self.scrollView.set(article: result as! ArticleDetail)
            self.isLoadedDetailView = true;
//            self.configureNavigationItem()
            self.stopSpinner();
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print(news.articleId)
        isBookMarked = checkStorage(articleId: news.articleId)
        print(isBookMarked)
        self.navigationItem.rightBarButtonItems![1].image = isBookMarked ? UIImage(systemName: "bookmark.fill") : UIImage(systemName: "bookmark")
    }
    
    func set(news : News){
        self.news = news
    }
    
    func stopSpinner(){
        if(self.isLoadedDetailView){
            SwiftSpinner.hide()
        }
    }
    
    func set(dic : Dictionary<String, String>){
        print(dic)
        self.news = News(imageUrl: dic["imageUrl"]!, title: dic["title"]!, time: dic["time"]!, timediff: dic["timediff"]!, section: dic["section"]!, articleId: dic["articleId"]!, isBookmarked: dic["isBookmarked"]!)
    }
    
    func configureNavigationItem(){
        
        navigationItem.title = self.article.title
        let twitterBtn = UIBarButtonItem(image: UIImage(named: "twitter"), style: .plain, target: self, action: #selector(getter: UICommandAlternate.action))
        twitterBtn.target = self
        twitterBtn.action = #selector(self.twitterBtnClicked)
        
        self.isBookMarked = checkStorage(news: self.news)
        let bookmarkImg = self.isBookMarked ? UIImage(systemName: "bookmark.fill") : UIImage(systemName: "bookmark")
        let bookmarkBtn = UIBarButtonItem(image: bookmarkImg, style: .plain, target: self, action: #selector(getter: UICommandAlternate.action))
        bookmarkBtn.target = self
        bookmarkBtn.action = #selector(self.bookmarkBtnClicked)
        self.navigationItem.rightBarButtonItems = [twitterBtn, bookmarkBtn]
    }
    
    @objc func bookmarkBtnClicked() {
        if(!self.isBookMarked){
            self.navigationItem.rightBarButtonItems![1].image = UIImage(systemName: "bookmark.fill")
            self.view.makeToast("Article Bookmarked. Check out the Bookmarks tab to view")
            setStorage(news: self.news)
        }else{
            self.navigationItem.rightBarButtonItems![1].image = UIImage(systemName: "bookmark")
            deleteStorage(news: self.news)
            self.view.makeToast("Article Removed from Bookmarks")
        }
        self.isBookMarked = !self.isBookMarked
    }
    
    @objc func twitterBtnClicked() {
        let url = URL(string: "https://twitter.com/intent/tweet?text=Check+out+this+Article!"
            + "&url=" + self.article.articleUrl + "&hashtags=CSCI_571_NewsApp")!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
            UIApplication.shared.openURL(url)
        }
    }
    
    func setScrollViewConstraints(){
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
}

extension DetailVC{
    func fetchData(_ params: String,
               onSuccess success: @escaping (_ JSON: Any) -> Void) -> Void {
        print(baseUrl + params);
        AF.request(baseUrl + params, method: .get).responseJSON{
            response in
            switch response.result {
            case .success(let data):
                let json = JSON(data)
                let imageUrl = json["image"].string
                let url = URL(string: imageUrl!)
                let data = try? Data(contentsOf: url!)
                let image = UIImage(data: data!)
                
                let articleUrl = json["articleUrl"].string
                let section = json["section"].string
                let title = json["title"].string
                let date = json["time"].string
                
                let desc = json["description"].string
                let regex = try! NSRegularExpression(pattern: "<iframe.*iframe>")
                let str = regex.stringByReplacingMatches(in: desc!, options: [], range: NSRange(location: 0, length: desc!.count), withTemplate: "p")
                guard let tmp = str.data(using: String.Encoding.unicode) else{return}
                print(type(of: tmp))
                let description = try? NSMutableAttributedString(data: tmp, options: [.documentType: NSAttributedString.DocumentType.html,], documentAttributes: nil)
                
                let res = ArticleDetail(image: image!, articleUrl: articleUrl!, section: section!, title: title!, date: date!, description: description!)
                
                success(res)
                break
            case .failure(let error):
                print(error)
            }
        }
    }

}
