//
//  ImageSelectionTableViewCell.swift
//  menuApp
//
//  Created by Artem Tselikov on 2018-07-07.
//  Copyright © 2018 Artem Tselikov. All rights reserved.
//

import UIKit

protocol ImageSelectionCellDelegate: class {
    func updateImage(fromCell: UITableViewCell)
    func deleteImage(fromCell: UITableViewCell)
}

class ImageSelectionTableViewCell: UITableViewCell, CellFromNib {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imagePreviewView: UIImageView!

    weak var delegate: ImageSelectionCellDelegate?

    override func prepareForReuse() {
        self.delegate = nil
    }

    @IBAction func updateImage(_ sender: Any) {
        delegate?.updateImage(fromCell: self)
    }
    
    @IBAction func deleteImage(_ sender: Any) {
        delegate?.deleteImage(fromCell: self)
    }
}
