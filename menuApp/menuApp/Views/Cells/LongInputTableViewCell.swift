//
//  LongInputTableViewCell.swift
//  menuApp
//
//  Created by Artem Tselikov on 2018-07-07.
//  Copyright © 2018 Artem Tselikov. All rights reserved.
//

import UIKit


class LongInputTableViewCell: UITableViewCell, CellFromNib {

    weak var delegate: InputCellDelegate?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        textView.delegate = self
    }

    override func prepareForReuse() {
        delegate = nil
    }
}

extension LongInputTableViewCell: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        delegate?.inputChanged(to: textView.text, inCell: self)
    }
}

