//
//  NewsCell.swift
//  hw9
//
//  Created by Tianhao Zhang on 4/24/20.
//  Copyright © 2020 Tianhao Zhang. All rights reserved.
//

import UIKit
import Toast_Swift

class NewsCell: UITableViewCell {
    
    var newsImageView  = UIImageView()
    var newsTitleLable = UILabel()
    var newsTimeLable = UILabel()
    var newsSectionLable = UILabel()
    var newsBookMarkView = UIButton()
    var articleId : String = ""
    var news : News = News(imageUrl: "", title: "", time: "", timediff: "", section: "", articleId: "", isBookmarked: "")
//    var news : News = News(image: "", title: "", time: "", section: "", articleId: "")
    let baseUrl = "https://theguardian.com"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(newsImageView)
        addSubview(newsTitleLable)
        addSubview(newsTimeLable)
        addSubview(newsSectionLable)
        addSubview(newsBookMarkView)
        
        configureCell()
        configureImageView()
        configureTitleLable()
        configureSectionLabel()
        configureBookmarkView()
        
        setImageConstraints()
        setTitleLableConstraints()
        setTimeLableConstraints()
        setSectionLableConstraints()
        setBookMarkViewConstraints()
        
        //interaction
        self.isUserInteractionEnabled = true
        let interaction = UIContextMenuInteraction(delegate: self)
        self.addInteraction(interaction)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var frame: CGRect {
      get {
          return super.frame
      }
      set (newFrame) {
          var frame =  newFrame
          frame.size.height -= 10
          super.frame = frame
      }
    }
    
    func set(news: News){
        let url = URL(string: news.imageUrl)
        let data = try? Data(contentsOf: url!)
        newsImageView.image = UIImage(data: data!)
        newsTitleLable.text = news.title
        newsTimeLable.text = news.timediff
        newsSectionLable.text = "| " + news.section
        if(checkStorage(news: news)){
            newsBookMarkView.setImage(UIImage(systemName: "bookmark.fill") , for: .normal)
        }else{
            newsBookMarkView.setImage(UIImage(systemName: "bookmark") , for: .normal)
        }
        articleId = news.articleId
        self.news = news
    }
    
    func configureCell(){
        self.backgroundColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1.0)
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(red: 150/255, green: 150/255, blue: 150/255, alpha: 1.0).cgColor
        self.clipsToBounds = true
        self.selectionStyle = .none
    }
    
    func configureImageView(){
        newsImageView.layer.cornerRadius = 10
        newsImageView.clipsToBounds      = true
        newsImageView.contentMode = .scaleAspectFill
    }
    
    func configureTitleLable(){
        newsTitleLable.numberOfLines = 3
    }
    
    func configureSectionLabel(){
        newsSectionLable.numberOfLines = 1
    }
    
    func configureBookmarkView(){
        newsBookMarkView.addTarget(self, action: #selector(self.buttonClicked), for: .touchUpInside)
    }
    
    @objc func buttonClicked() {
        if(newsBookMarkView.currentImage == UIImage(systemName: "bookmark")){
            newsBookMarkView.setImage(UIImage(systemName: "bookmark.fill") , for: .normal)
            setStorage(news: self.news)
            self.superview?.superview?.makeToast("Article Bookmarked. Check out the Bookmarks tab to view")
        }else{
            newsBookMarkView.setImage(UIImage(systemName: "bookmark") , for: .normal)
            deleteStorage(news: self.news)
            self.superview?.superview?.makeToast("Article Removed from Bookmarks")
        }
    }
    
    func setImageConstraints(){
        newsImageView.translatesAutoresizingMaskIntoConstraints = false
        newsImageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        newsImageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        newsImageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        newsImageView.widthAnchor.constraint(equalTo: newsImageView.heightAnchor).isActive = true
    }
    
    func setTitleLableConstraints(){
        newsTitleLable.translatesAutoresizingMaskIntoConstraints = false
        newsTitleLable.leadingAnchor.constraint(equalTo: newsImageView.trailingAnchor, constant: 20).isActive = true
        newsTitleLable.topAnchor.constraint(equalTo: newsImageView.topAnchor, constant: 10).isActive = true
        newsTitleLable.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12).isActive = true
        newsTitleLable.font = UIFont.boldSystemFont(ofSize: 18)
    }
    
    func setTimeLableConstraints(){
        newsTimeLable.translatesAutoresizingMaskIntoConstraints = false
        newsTimeLable.leadingAnchor.constraint(equalTo: newsTitleLable.leadingAnchor).isActive = true
        newsTimeLable.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6).isActive = true
    }
    
    func setSectionLableConstraints(){
        newsSectionLable.translatesAutoresizingMaskIntoConstraints = false
        newsSectionLable.leadingAnchor.constraint(equalTo: newsImageView.trailingAnchor, constant: 120).isActive = true
        newsSectionLable.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40).isActive = true
        newsSectionLable.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6).isActive = true
    }
    
    func setBookMarkViewConstraints(){
        newsBookMarkView.translatesAutoresizingMaskIntoConstraints = false
        newsBookMarkView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        newsBookMarkView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6).isActive = true
    }
    
    func shareWithTwitter() -> UIAction {
//        print(self.url)
        return UIAction(
            title: "Share with Twitter",
            image: UIImage(named: "twitter"),
            identifier: nil) { _ in
                let newsurl = self.baseUrl + self.articleId
                let url = URL(string:"https://twitter.com/intent/tweet?text=Check+out+this+Article!"
                    + "&url=" + newsurl + "&hashtags=CSCI_571_NewsApp")!
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                    UIApplication.shared.openURL(url)
                }
        }
    }
    
    func setBookMark() -> UIAction {
        return UIAction(
            title: "Bookmark",
            image: self.newsBookMarkView.currentImage,
            identifier: nil) { _ in
                if(self.newsBookMarkView.currentImage == UIImage(systemName: "bookmark")){
                    self.newsBookMarkView.setImage(UIImage(systemName: "bookmark.fill") , for: .normal)
                    setStorage(news: self.news)
                    self.superview?.superview?.makeToast("Article Bookmarked. Check out the Bookmarks tab to view")
                }else{
                    self.newsBookMarkView.setImage(UIImage(systemName: "bookmark") , for: .normal)
                    deleteStorage(news: self.news)
                    self.superview?.superview?.makeToast("Article Removed from Bookmarks")
                }
        }
    }
}

extension NewsCell : UIContextMenuInteractionDelegate{
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(
          identifier: nil,
          previewProvider: nil,
          actionProvider: { _ in
            let shareWithTwitter = self.shareWithTwitter()
            let setBookmark = self.setBookMark()
            let children = [shareWithTwitter,setBookmark]
            return UIMenu(title: "Menu", children: children)
        })
    }
}
