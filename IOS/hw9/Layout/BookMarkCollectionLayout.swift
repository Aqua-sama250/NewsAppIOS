//
//  BookMarkCollectionLayout.swift
//  hw9
//
//  Created by Tianhao Zhang on 5/4/20.
//  Copyright © 2020 Tianhao Zhang. All rights reserved.
//

import UIKit

class BookMarkCollectionLayout: UICollectionViewFlowLayout {

    private let cellHeight: CGFloat = 270
    
    private var deletingIndexPaths = [IndexPath]()
    private var insertingIndexPaths = [IndexPath]()
    
    override func prepare() {
        super.prepare()

        guard let collectionView = collectionView else { return }
        
        let availableWidth = collectionView.bounds.inset(by: collectionView.layoutMargins).width
        let cellWidth = (availableWidth / 2).rounded(.down)
        
        self.itemSize = CGSize(width: cellWidth, height: cellHeight)
        self.sectionInset = UIEdgeInsets(top: self.minimumInteritemSpacing, left: 0.0, bottom: 0.0, right: 0.0)
        self.sectionInsetReference = .fromSafeArea
    }
}
