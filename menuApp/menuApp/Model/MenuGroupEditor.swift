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


enum SettingSection {
    case settings(settings: [Setting])
    case actions(actions: [Action])
}


class Action {
    let title: String
    var onAction: (()->())? = nil

    init(title: String) {
        self.title = title
    }
}

protocol ConfigurableObject {

    var title: String { get }

    var sections: [SettingSection] { get }
    var delegate: SettingPresentationDelegate? { get set }
    var canSave: Bool { get }

    func saveChanges()
    func discardChanges()
}

class MenuGroupEditor: ConfigurableObject {

    private let settings: [Setting]
    private let actions: [Action]
    let sections: [SettingSection]

    weak var delegate: SettingPresentationDelegate? = nil

    var title: String {

        let genericTitle = "New Group"

        guard let _title = menuGroup?.title else {
            return genericTitle
        }

        return _title.count > 0 ? _title : genericTitle
    }

    var canSave: Bool {

        guard let titleLen = menuGroup?.title.count else {
            return false
        }

        return titleLen > 0
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

        let deleteAction = Action(title: "Delete")

        actions = [deleteAction]

        sections = [SettingSection.settings(settings: settings) ,SettingSection.actions(actions: actions)]

        titleSetting.onChangeAction = {[unowned self, weak titleSetting] (action) in
            if case .string(let value) = action {

                guard let newTitle = value else { return }
                self.menuGroup?.title = newTitle
            }
            titleSetting?.currentValue = action
            self.delegate?.updateCanSave(canSave: self.canSave)
        }

        titleSetting.currentValue = SettingValue.string(value: menuGroup?.title)

        imageSetting.onChangeAction = {[weak self, weak imageSetting]  (action) in
            if case .image(let image) = action {
                self?.menuGroup?.image = image
            }
            imageSetting?.currentValue = action
            if let _imageSetting = imageSetting {
                self?.delegate?.update(setting: _imageSetting)
            }
        }
        imageSetting.currentValue = SettingValue.image(value: menuGroup?.image)

        deleteAction.onAction = {[weak self] in
            print("will delete")
        }
    }

    func saveChanges() {
        try! moc.save()
    }

    func discardChanges() {

        if !isNew {
            moc.reset()
            return
        }

        if let _menuGroup = menuGroup {
            moc.delete(_menuGroup)
        }
    }

}
