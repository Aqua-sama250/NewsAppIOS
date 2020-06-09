//
//  DetailView.swift
//  hw9
//
//  Created by Tianhao Zhang on 5/2/20.
//  Copyright © 2020 Tianhao Zhang. All rights reserved.
//

import UIKit

var articleUrl = ""

class DetailView: UIScrollView {
    
    var imageView = UIImageView()
    var titleLabel = UILabel()
    var sectionLabel = UILabel()
    var timeLabel = UILabel()
    var contentLabel = UILabel()
    var showMoreBtn = UIButton()
//    var articleUrl = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        set(article: ArticleDetail(image: UIImage(), articleUrl: "", section: "", title: "", date: "", description: NSMutableAttributedString()))
        
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(sectionLabel)
        addSubview(timeLabel)
        addSubview(contentLabel)
        addSubview(showMoreBtn)
        
        configureImageView()
        configureTitleLabel()
        configureSectionLabel()
        configureTimeLabel()
        configureContentLabel()
        configureShowMoreLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(article: ArticleDetail){
        imageView.image = article.image
        titleLabel.text = article.title
        sectionLabel.text = article.section
        timeLabel.text = article.date
        articleUrl = article.articleUrl
        
        let font = UIFont.systemFont(ofSize: 15)
        article.description.addAttribute(.font, value: font, range: NSRange(location: 0, length: article.description.length))
        contentLabel.attributedText = article.description
        showMoreBtn.setTitle("View Full Article", for: .normal)
    }
    
    func configureImageView(){
        imageView.translatesAutoresizingMaskIntoConstraints=false
        imageView.topAnchor.constraint(equalTo:topAnchor, constant: 20).isActive=true
        imageView.widthAnchor.constraint(equalTo:widthAnchor).isActive=true
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor,multiplier: 3/4).isActive=true

    }
    
    func configureTitleLabel(){
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.numberOfLines = 0
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 50).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
    }
    
    func configureSectionLabel(){
        sectionLabel.textColor = UIColor(red: 150/255, green: 150/255, blue: 150/255, alpha: 1.0)
        sectionLabel.translatesAutoresizingMaskIntoConstraints = false
        sectionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40).isActive = true
        sectionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40).isActive = true
    }
    
    func configureTimeLabel(){
        timeLabel.textColor = UIColor(red: 150/255, green: 150/255, blue: 150/255, alpha: 1.0)
        
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40).isActive = true
        timeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40).isActive = true
    }
    
    func configureContentLabel(){
        contentLabel.numberOfLines = 30
        contentLabel.lineBreakMode = .byTruncatingTail
        
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.topAnchor.constraint(equalTo: sectionLabel.bottomAnchor, constant: 60).isActive = true
        contentLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        contentLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
    }
    
    func configureShowMoreLabel(){
        showMoreBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 25)
        showMoreBtn.setTitleColor(.systemBlue, for: .normal)
        showMoreBtn.tintColor = .red
        showMoreBtn.addTarget(self, action: #selector(self.buttonClicked), for: .touchUpInside)
        showMoreBtn.addTarget(self, action: #selector(self.buttonTouchDown), for: .touchDown)
        showMoreBtn.addTarget(self, action: #selector(self.buttonCancel), for: .touchUpOutside)
        
        showMoreBtn.translatesAutoresizingMaskIntoConstraints = false
        showMoreBtn.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 40).isActive = true
        showMoreBtn.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        showMoreBtn.widthAnchor.constraint(equalToConstant: 200).isActive = true
        showMoreBtn.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
    }
    
    @objc func buttonClicked() {
        print("Button up")
        let url = URL(string: articleUrl)!
        if #available(iOS 10.0, *) {
            showMoreBtn.backgroundColor = .white
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
            UIApplication.shared.openURL(url)
        }
    }
    
    @objc func buttonTouchDown() {
        showMoreBtn.backgroundColor = UIColor(red: 150/255, green: 150/255, blue: 150/255, alpha: 1.0)
    }
    
    @objc func buttonCancel() {
        showMoreBtn.backgroundColor = .white
    }

}
