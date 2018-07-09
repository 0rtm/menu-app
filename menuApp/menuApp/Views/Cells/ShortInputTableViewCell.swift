//
//  ShortInputTableViewCell.swift
//  menuApp
//
//  Created by Artem Tselikov on 2018-07-07.
//  Copyright © 2018 Artem Tselikov. All rights reserved.
//

import UIKit

protocol InputCellDelegate: class {
    func editingBegin(inCell: UITableViewCell)
    func inputChanged(to: String?, inCell: UITableViewCell)
}

class ShortInputTableViewCell: UITableViewCell, CellFromNib {

    weak var delegate: InputCellDelegate? = nil

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var inputField: UITextField!

    override func prepareForReuse() {
        super.prepareForReuse()
        delegate = nil
    }

    @IBAction func inputChanged(_ sender: Any) {
        delegate?.inputChanged(to: inputField.text, inCell: self)
    }

    @IBAction func editingDidBegin(_ sender: Any) {
        delegate?.editingBegin(inCell: self)
    }

}
