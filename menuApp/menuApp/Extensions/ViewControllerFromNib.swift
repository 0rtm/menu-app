//
//  ViewControllerFromNib.swift
//  menuApp
//
//  Created by Artem Tselikov on 2018-07-08.
//  Copyright © 2018 Artem Tselikov. All rights reserved.
//

import Foundation
import UIKit

protocol ViewControllerFromNib {

}

extension ViewControllerFromNib where Self: UIViewController {

    fileprivate static var nibName: String {
        return "\(self)"
    }

    static func fromNib() -> Self {
        return Self(nibName: Self.nibName, bundle: nil)
    }

}
