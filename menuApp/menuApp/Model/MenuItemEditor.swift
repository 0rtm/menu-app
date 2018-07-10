//
//  MenuItemEditor.swift
//  menuApp
//
//  Created by Artem Tselikov on 2018-07-08.
//  Copyright © 2018 Artem Tselikov. All rights reserved.
//

import Foundation

final class MenuItemEditor: ConfigurableObject {

    var canSave: Bool {
        let hasTitle = item.title.count > 0

        // Probalby the price could be 0 and it would be a still valid menu item
        // For simplicity decided to enforce price > 0
        let hasPrice = item.price.doubleValue > 0.0
        return hasTitle && hasPrice
    }

    weak var delegate: SettingPresentationDelegate?
    
    var title: String {
        return isNew ? "New Item" : item.title
    }

    fileprivate let item: MenuItem
    fileprivate let isNew: Bool

    private let settings: [Setting]
    private let actions: [Action]

    private(set) var sections: [SettingSection]

    init(item: MenuItem, isNew: Bool) {
        self.item = item
        self.isNew = isNew

        let titleSetting = Setting(title: "Title", inputFieldType: .small(keyboardType: .default))
        let priceSetting = Setting(title: "Price", inputFieldType: .small(keyboardType: .decimalPad))
        let descriptionSetting = Setting(title: "Description", inputFieldType: .large)
        let imageSetting = Setting(title: "Image", inputFieldType: .image)

        settings = [titleSetting, priceSetting, descriptionSetting, imageSetting]

        let deleteAction = Action(title: "Delete")
        actions = [deleteAction]

        sections = [SettingSection.settings(settings: settings) ,SettingSection.actions(actions: actions)]

        titleSetting.currentValue = SettingValue.string(value: item.title)
        titleSetting.onChangeAction = {[unowned self, unowned titleSetting] action in
            guard case .string(let value) = action else {
                return
            }

            guard let newTitle = value else { return }
            self.item.title = newTitle

            titleSetting.currentValue = action
            self.delegate?.updateCanSave(canSave: self.canSave)
            self.delegate?.updateTitle()
        }

        priceSetting.currentValue = SettingValue.string(value: item.price.stringValue)
        priceSetting.onChangeAction = {[unowned self, unowned priceSetting] action in
            guard case .string(let value) = action else {
                return
            }
            guard let newPrice = value else { return }
            self.item.price = NSDecimalNumber(string: newPrice)

            priceSetting.currentValue = action
            self.delegate?.updateCanSave(canSave: self.canSave)
        }

        descriptionSetting.currentValue = SettingValue.string(value: item.info)
        descriptionSetting.onChangeAction = {[unowned self, unowned descriptionSetting] action in
            guard case .string(let value) = action else {
                return
            }
            self.item.info = value
            descriptionSetting.currentValue = action
        }

        deleteAction.onAction = {[weak self] in
            self?.deleteOrDiscard()
        }

        imageSetting.currentValue = SettingValue.image(value: item.image)
        imageSetting.onChangeAction = {[unowned self, unowned imageSetting]  (action) in
            guard case .image(let image) = action else {
                return
            }
            self.item.image = image
            imageSetting.currentValue = action
            self.delegate?.update(setting: imageSetting)
        }
        imageSetting.currentValue = SettingValue.image(value: item.image)

    }

    func saveChanges() {
        try! item.managedObjectContext?.save()
    }

    func discardChanges() {
        let moc = item.managedObjectContext
        if isNew {
            moc?.delete(item)
            return
        }
        moc?.rollback()
    }

    fileprivate func deleteOrDiscard() {

        if (isNew) {
            discardChanges()
        } else {
            item.managedObjectContext?.delete(item)
        }

        self.delegate?.dismiss()

    }

}
