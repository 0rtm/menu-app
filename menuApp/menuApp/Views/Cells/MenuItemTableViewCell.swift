//
//  MenuItemTableViewCell.swift
//  menuApp
//
//  Created by Artem Tselikov on 2018-07-08.
//  Copyright © 2018 Artem Tselikov. All rights reserved.
//

import UIKit

class MenuItemTableViewCell: UITableViewCell, CellFromNib {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var itemImageView: UIImageView!

    static var defaultHeight: CGFloat {
        return 80.0
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView?.image = nil
    }

    func configure(forMenuItem menuItem: MenuItem, numberFormatter formatter: NumberFormatter) {
        titleLabel.text = menuItem.title
        descriptionLabel.text = menuItem.info
        priceLabel.text = formatter.string(from: menuItem.price)//String( menuItem.price)

        if let image = menuItem.image {
            itemImageView.image = image
        } else {
            itemImageView.backgroundColor = UIColor.imagePlaceholderColor
        }
    }
}
