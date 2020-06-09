//
//  SuggestResultCell.swift
//  hw9
//
//  Created by Tianhao Zhang on 5/4/20.
//  Copyright © 2020 Tianhao Zhang. All rights reserved.
//

import UIKit

class SuggestResultCell: UITableViewCell {
    
    var data: String = ""
    
    var resultLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(resultLabel)
        resultLabel.font.withSize(25)
        resultLabel.translatesAutoresizingMaskIntoConstraints=false
        resultLabel.topAnchor.constraint(equalTo:topAnchor).isActive=true
        resultLabel.heightAnchor.constraint(equalTo:heightAnchor).isActive=true
        resultLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        resultLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 20).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(data: String){
        resultLabel.text = data
    }

}
