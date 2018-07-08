//
//  MenuGroupEditor.swift
//  menuApp
//
//  Created by Artem Tselikov on 2018-07-08.
//  Copyright © 2018 Artem Tselikov. All rights reserved.
//

import Foundation

protocol SettingPresentationDelegate: class {
    func update(setting: Setting)
}

class MenuGroupEditor {

    private(set) var settings: [Setting]
    weak var delegate: SettingPresentationDelegate? = nil

    fileprivate let menuGroup: MenuGroup?

    init(menuGroup: MenuGroup?) {
        self.menuGroup = menuGroup
        let titleSetting = Setting(title: "Title", inputFieldType: .small(keyboardType: .default))
        let imageSetting = Setting(title: "Image", inputFieldType: .image)

        settings = [titleSetting, imageSetting]

        titleSetting.onChangeAction = { (action) in
            if case .string(let value) = action {
                print("title will be set to \(value ?? "N?A")")
            }
            titleSetting.currentValue = action
        }

        imageSetting.onChangeAction = { (action) in
            if case .image(let image) = action {
                print("title will be set to")
            }
            imageSetting.currentValue = action
            self.delegate?.update(setting: imageSetting)
        }
    }


}
