//
//  CellFromNib.swift
//  menuApp
//
//  Created by Artem Tselikov on 2018-07-08.
//  Copyright © 2018 Artem Tselikov. All rights reserved.
//

import Foundation
import UIKit

protocol CellFromNib {

}

extension CellFromNib where Self: UITableViewCell {

    static var reuseIdentifier: String {
        return className + ".reuseId"
    }

    static var nib: UINib {
        return UINib(nibName: className, bundle: nil)
    }

    private static var className: String {
        return "\(self)"
    }
}
