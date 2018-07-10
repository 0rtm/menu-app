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
        return isNew ? "New Group" : menuGroup.title
    }

    var canSave: Bool {
        return menuGroup.title.count > 0
    }

    fileprivate let menuGroup: MenuGroup

    private let isNew: Bool

    init(menuGroup group: MenuGroup, isNew: Bool) {

        self.menuGroup = group
        self.isNew = isNew

        let titleSetting = Setting(title: "Title", inputFieldType: .small(keyboardType: .default))
        let imageSetting = Setting(title: "Image", inputFieldType: .image)
        let descriptionSetting = Setting(title: "Description", inputFieldType: .large)

        settings = [titleSetting, imageSetting, descriptionSetting]

        let deleteAction = Action(title: "Delete")

        actions = [deleteAction]

        sections = [.settings(settings: settings), .actions(actions: actions)]

        titleSetting.onChangeAction = {[unowned self, weak titleSetting] (action) in
            guard case .string(let value) = action else {
                return
            }

            guard let newTitle = value else { return }
            self.menuGroup.title = newTitle

            titleSetting?.currentValue = action
            self.delegate?.updateCanSave(canSave: self.canSave)
            self.delegate?.updateTitle()
        }

        titleSetting.currentValue = SettingValue.string(value: menuGroup.title)

        imageSetting.onChangeAction = {[unowned self, unowned imageSetting]  (action) in
            guard case .image(let image) = action else {
                return
            }
            self.menuGroup.image = image
            imageSetting.currentValue = action
            self.delegate?.update(setting: imageSetting)
        }
        imageSetting.currentValue = SettingValue.image(value: menuGroup.image)

        descriptionSetting.currentValue = SettingValue.string(value: menuGroup.info)
        descriptionSetting.onChangeAction = {[unowned self, unowned descriptionSetting] action in
            guard case .string(let value) = action else {
                return
            }
            self.menuGroup.info = value
            descriptionSetting.currentValue = action
        }

        deleteAction.onAction = {[unowned self] in
            self.deleteOrDiscard()
        }
    }

    func saveChanges() {
        AppEnvironment.current.saveContext()
    }

    func discardChanges() {

        if !isNew {
            AppEnvironment.current.mainContext.rollback()
            return
        }
        
        menuGroup.managedObjectContext?.delete(menuGroup)
    }

    fileprivate func deleteOrDiscard() {
        if isNew {
            discardChanges()
        } else {
            AppEnvironment.current.mainContext.delete(menuGroup)
        }
        delegate?.dismiss()
    }

}
