//
//  Setting.swift
//  menuApp
//
//  Created by Artem Tselikov on 2018-07-08.
//  Copyright © 2018 Artem Tselikov. All rights reserved.
//

import Foundation

struct Setting {
    let title: String
    let inputFieldType: InputFieldType
    let onChangeAction: ((ChangeAction)->())
}
