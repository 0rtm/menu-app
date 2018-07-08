//
//  MenuGroupEditor.swift
//  menuApp
//
//  Created by Artem Tselikov on 2018-07-08.
//  Copyright © 2018 Artem Tselikov. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol SettingPresentationDelegate: class {
    func update(setting: Setting)
}

class MenuGroupEditor {

    private(set) var settings: [Setting]
    weak var delegate: SettingPresentationDelegate? = nil

    var title: String {

        let genericTitle = "New Group"

        guard let _title = menuGroup?.title else {
            return genericTitle
        }

        return _title.count > 0 ? _title : genericTitle
    }

    fileprivate let menuGroup: MenuGroup?

    private let moc: NSManagedObjectContext

    private let isNew: Bool

    init(menuGroup group: MenuGroup?) {

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        moc = appDelegate.persistentContainer.viewContext

        if group == nil {
            self.menuGroup = MenuGroup(context: moc)
            isNew = true
        } else {
            self.menuGroup = group
            isNew = false
        }

        let titleSetting = Setting(title: "Title", inputFieldType: .small(keyboardType: .default))
        let imageSetting = Setting(title: "Image", inputFieldType: .image)
        let descriptionSetting = Setting(title: "Description", inputFieldType: .large)

        settings = [titleSetting, imageSetting, descriptionSetting]

        titleSetting.onChangeAction = {[weak self, weak titleSetting] (action) in
            if case .string(let value) = action {

                guard let newTitle = value else { return }
                self?.menuGroup?.title = newTitle
            }
            titleSetting?.currentValue = action
        }

        titleSetting.currentValue = SettingValue.string(newValue: menuGroup?.title)

        imageSetting.onChangeAction = {[weak self, weak imageSetting]  (action) in
            if case .image(let image) = action {
                self?.menuGroup?.image = image
            }
            imageSetting?.currentValue = action
            if let _imageSetting = imageSetting {
                self?.delegate?.update(setting: _imageSetting)
            }
        }
        imageSetting.currentValue = SettingValue.image(newValue: menuGroup?.image)
    }

    func save() {
        try! moc.save()
    }

    func cancel() {

        if !isNew {
            moc.reset()
            return
        }

        if let _menuGroup = menuGroup {
            moc.delete(_menuGroup)
        }
    }

}
