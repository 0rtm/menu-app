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

        sections = [SettingSection.settings(settings: settings) ,SettingSection.actions(actions: actions)]

        titleSetting.onChangeAction = {[unowned self, weak titleSetting] (action) in
            if case .string(let value) = action {

                guard let newTitle = value else { return }
                self.menuGroup.title = newTitle
            }
            titleSetting?.currentValue = action
            self.delegate?.updateCanSave(canSave: self.canSave)
            self.delegate?.updateTitle()
        }

        titleSetting.currentValue = SettingValue.string(value: menuGroup.title)

        imageSetting.onChangeAction = {[weak self, weak imageSetting]  (action) in
            if case .image(let image) = action {
                self?.menuGroup.image = image
            }
            imageSetting?.currentValue = action
            if let _imageSetting = imageSetting {
                self?.delegate?.update(setting: _imageSetting)
            }
        }
        imageSetting.currentValue = SettingValue.image(value: menuGroup.image)

        deleteAction.onAction = {[weak self] in
            self?.deleteOrDiscard()
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
