//
//  MenuGroupTableViewCell.swift
//  menuApp
//
//  Created by Artem Tselikov on 2018-07-08.
//  Copyright © 2018 Artem Tselikov. All rights reserved.
//

import UIKit

class MenuGroupTableViewCell: UITableViewCell, CellFromNib {

    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var menuImageView: UIImageView!

    override func prepareForReuse() {
        menuImageView.image = nil
    }

    func configureFor(menuGroup: MenuGroup) {
        titleLabel.text = menuGroup.title
        menuImageView.backgroundColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
    }
    
}
