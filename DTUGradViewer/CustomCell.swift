//
//  CustomCell.swift
//  DTUGradViewer
//
//  Created by Troels on 15/02/2019.
//  Copyright © 2019 Troels. All rights reserved.
//

import Foundation
import UIKit

class CustomCell: UITableViewCell {
    var msg: String?
    
    var msgView: UITextView = {
        var textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(msgView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
