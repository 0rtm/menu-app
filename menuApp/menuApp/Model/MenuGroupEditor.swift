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

    init(menuGroup: MenuGroup?) {

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        moc = appDelegate.persistentContainer.viewContext

        if menuGroup == nil {
            self.menuGroup = MenuGroup(context: moc)
            isNew = true
        } else {
            self.menuGroup = menuGroup
            isNew = false
        }

        let titleSetting = Setting(title: "Title", inputFieldType: .small(keyboardType: .default))
        let imageSetting = Setting(title: "Image", inputFieldType: .image)
        let descriptionSetting = Setting(title: "Description", inputFieldType: .large)

        settings = [titleSetting, imageSetting, descriptionSetting]

        titleSetting.onChangeAction = {[weak self] (action) in
            if case .string(let value) = action {

                guard let newTitle = value else { return }
                self?.menuGroup?.title = newTitle
            }
            titleSetting.currentValue = action
        }

        titleSetting.currentValue = SettingValue.string(newValue: menuGroup?.title)

        imageSetting.onChangeAction = {[weak self] (action) in
            if case .image(let image) = action {
                print("title will be set to")
            }
            imageSetting.currentValue = action
            self?.delegate?.update(setting: imageSetting)
        }
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
