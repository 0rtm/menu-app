//
//  Setting.swift
//  menuApp
//
//  Created by Artem Tselikov on 2018-07-08.
//  Copyright © 2018 Artem Tselikov. All rights reserved.
//

import Foundation

final class Setting {
    let title: String
    let inputFieldType: InputFieldType
    var onChangeAction: ((SettingValue)->())? = nil
    var currentValue: SettingValue? = nil

    init(title: String, inputFieldType: InputFieldType) {
        self.title = title
        self.inputFieldType = inputFieldType
    }
}

extension Setting: Equatable {
    static func == (lhs: Setting, rhs: Setting) -> Bool {
        return lhs.title == rhs.title
    }
}
