//
//  BookmrakVC.swift
//  hw9
//
//  Created by Tianhao Zhang on 5/4/20.
//  Copyright © 2020 Tianhao Zhang. All rights reserved.
//

import UIKit
import Toast_Swift

class BookmarkVC: UIViewController {
    
    var collectionsView : UICollectionView!
    
    var noResultLabel: UILabel!
    
//    @IBOutlet weak var noResultLabel: UILabel!
    
    var bookmarkList: [Dictionary<String, String>] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionsView = UICollectionView(frame: CGRect(x: 20, y: 0, width: view.frame.width - 40, height: view.frame.height), collectionViewLayout: BookMarkCollectionLayout())
        
        noResultLabel = UILabel()
        
        view.addSubview(collectionsView)
        view.addSubview(noResultLabel)
        
        configureNoResultLabel()
        
        collectionsView.delegate = self
        collectionsView.backgroundColor = .white
        collectionsView.dataSource = self
        collectionsView.register(BookmarkCell.self, forCellWithReuseIdentifier: "reuseIdentifier")
        
        NotificationCenter.default.addObserver(self, selector: #selector(onDidDeleteBookmark(_:)), name: .didDeleteBookmark, object: nil)

        getLocalStorage()
        
    }
    
    @objc func onDidDeleteBookmark(_ notification: Notification){
        print("deletebookmark")
        getLocalStorage()
    }
    
    func getLocalStorage(){
        self.bookmarkList = getStorage()
        collectionsView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getLocalStorage()
    }
    
    func configureNoResultLabel(){
        noResultLabel.text = "No bookmarks added"
        
        noResultLabel.translatesAutoresizingMaskIntoConstraints = false
        noResultLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        noResultLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}

extension BookmarkVC: UICollectionViewDelegate, UICollectionViewDataSource{

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        collectionsView.isHidden = bookmarkList.count == 0
        self.noResultLabel.isHidden = bookmarkList.count != 0
        return bookmarkList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reuseIdentifier", for: indexPath) as! BookmarkCell
        cell.set(dic: bookmarkList[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let myVC = storyboard.instantiateViewController(withIdentifier: "thirdView") as! DetailVC
        myVC.set(dic: self.bookmarkList[indexPath.row])
        self.navigationController?.pushViewController(myVC, animated: true)
    }
}
