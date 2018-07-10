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

final class ImageSelectionTableViewCell: UITableViewCell, CellFromNib {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var imagePreviewView: UIImageView!

    weak var delegate: ImageSelectionCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        imagePreviewView.backgroundColor = UIColor.imagePlaceholderColor
    }

    override func prepareForReuse() {
        self.delegate = nil
    }

    func setPreviewImage(_ image: UIImage?) {
        imagePreviewView.backgroundColor = image == nil ? UIColor.imagePlaceholderColor: UIColor.clear
        imagePreviewView.image = image
    }

    @IBAction func updateImage(_ sender: Any) {
        delegate?.updateImage(fromCell: self)
    }
    
    @IBAction func deleteImage(_ sender: Any) {
        delegate?.deleteImage(fromCell: self)
    }
}
