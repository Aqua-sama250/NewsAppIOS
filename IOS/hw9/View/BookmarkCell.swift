//
//  BookmarkCell.swift
//  hw9
//
//  Created by Tianhao Zhang on 5/4/20.
//  Copyright © 2020 Tianhao Zhang. All rights reserved.
//

import UIKit

class BookmarkCell: UICollectionViewCell {
    
    var bookmarkImageView  = UIImageView()
    var bookmarkTitleLable = UILabel()
    var bookmarkTimeLable = UILabel()
    var bookmarkSectionLable = UILabel()
    var bookmarkBookMarkView = UIButton()
    var articleId : String = ""
    
    let baseUrl = "https://theguardian.com"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(bookmarkImageView)
        addSubview(bookmarkTitleLable)
        addSubview(bookmarkTimeLable)
        addSubview(bookmarkSectionLable)
        addSubview(bookmarkBookMarkView)
        
        configureCell()
        setImage()
        setTitleLable()
        setTimeLable()
        setSectionLable()
        setBookMarkView()
    }
    
    func set(dic : Dictionary<String, String>){
        let url = URL(string: dic["imageUrl"]!)
        let data = try? Data(contentsOf: url!)
        bookmarkImageView.image = UIImage(data: data!)
        
        bookmarkTitleLable.text = dic["title"]
        bookmarkTimeLable.text = dic["time"]
        bookmarkSectionLable.text = "|" + dic["section"]!
        bookmarkBookMarkView.setImage(UIImage(systemName: "bookmark.fill") , for: .normal)
        
        self.articleId = dic["articleId"]!
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(){
        self.backgroundColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1.0)
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(red: 150/255, green: 150/255, blue: 150/255, alpha: 1.0).cgColor
        self.clipsToBounds = true
        
//        contextMenu
        self.isUserInteractionEnabled = true
        let interaction = UIContextMenuInteraction(delegate: self)
        self.addInteraction(interaction)
    }
    
    func setImage(){
        bookmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        bookmarkImageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        bookmarkImageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        bookmarkImageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        bookmarkImageView.heightAnchor.constraint(equalTo: bookmarkImageView.widthAnchor, multiplier: 4/5).isActive = true
    }
    
    func setTitleLable(){
        bookmarkTitleLable.numberOfLines = 3
        bookmarkTitleLable.font = UIFont.boldSystemFont(ofSize: 18)
        bookmarkTitleLable.textAlignment = .center
        bookmarkTitleLable.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        bookmarkTitleLable.translatesAutoresizingMaskIntoConstraints = false
        bookmarkTitleLable.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        bookmarkTitleLable.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        bookmarkTitleLable.topAnchor.constraint(equalTo: bookmarkImageView.bottomAnchor, constant: 10).isActive = true
    }
    
    func setTimeLable(){
        bookmarkTimeLable.numberOfLines = 1
        bookmarkTimeLable.font.withSize(5)
        bookmarkTimeLable.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        bookmarkTimeLable.translatesAutoresizingMaskIntoConstraints = false
        bookmarkTimeLable.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        bookmarkTimeLable.widthAnchor.constraint(equalToConstant: 60).isActive = true
        bookmarkTimeLable.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
    }
    
    func setSectionLable(){
        bookmarkSectionLable.numberOfLines = 1
        bookmarkSectionLable.font.withSize(5)
        
        bookmarkSectionLable.translatesAutoresizingMaskIntoConstraints = false
        bookmarkSectionLable.leadingAnchor.constraint(equalTo: bookmarkTimeLable.trailingAnchor, constant: 10).isActive = true
        bookmarkSectionLable.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40).isActive = true
        bookmarkSectionLable.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
    }
    
    func setBookMarkView(){
        bookmarkBookMarkView.addTarget(self, action: #selector(self.buttonClicked), for: .touchUpInside)
        
        bookmarkBookMarkView.translatesAutoresizingMaskIntoConstraints = false
        bookmarkBookMarkView.leadingAnchor.constraint(equalTo: bookmarkSectionLable.trailingAnchor, constant: 10).isActive = true
        bookmarkBookMarkView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        bookmarkBookMarkView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
    }
    
    @objc func buttonClicked() {
        bookmarkBookMarkView.setImage(UIImage(systemName: "bookmark") , for: .normal)
        self.superview?.superview?.makeToast("Article Removed from Bookmarks")
        deleteStorage(articleId: self.articleId)
        NotificationCenter.default.post(name: .didDeleteBookmark, object: self)
    }
    
}

extension BookmarkCell : UIContextMenuInteractionDelegate{
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
                image: self.bookmarkBookMarkView.currentImage,
                identifier: nil) { _ in
                    self.bookmarkBookMarkView.setImage(UIImage(systemName: "bookmark") , for: .normal)
                    deleteStorage(articleId: self.articleId)
                    NotificationCenter.default.post(name: .didDeleteBookmark, object: self)
                    self.superview?.superview?.makeToast("Article Removed from Bookmarks")
            }
        }
}
