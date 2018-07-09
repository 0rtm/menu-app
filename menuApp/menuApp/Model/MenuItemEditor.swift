//
//  MenuItemEditor.swift
//  menuApp
//
//  Created by Artem Tselikov on 2018-07-08.
//  Copyright © 2018 Artem Tselikov. All rights reserved.
//

import Foundation

class MenuItemEditor: ConfigurableObject {

    var canSave: Bool {
        let hasTitle = item.title.count > 0

        // Probalby the price could be 0 and it would be a still valid menu item
        // For simplicity decided to enforce price > 0
        let hasPrice = item.price.doubleValue > 0.0
        return hasTitle && hasPrice
    }

    weak var delegate: SettingPresentationDelegate?
    
    var title: String {
        return item.title.count > 0 ? item.title : "New Item"
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
        let imageSetting = Setting(title: "Image", inputFieldType: .image)

        settings = [titleSetting, priceSetting, imageSetting]

        let deleteAction = Action(title: "Delete")
        actions = [deleteAction]

        sections = [SettingSection.settings(settings: settings) ,SettingSection.actions(actions: actions)]

        titleSetting.currentValue = SettingValue.string(value: item.title)
        titleSetting.onChangeAction = {[unowned self, weak titleSetting] action in
            if case .string(let value) = action {
                guard let newTitle = value else { return }
                self.item.title = newTitle
            }
            titleSetting?.currentValue = action
            self.delegate?.updateCanSave(canSave: self.canSave)
        }

        priceSetting.currentValue = SettingValue.string(value: item.price.stringValue)
        priceSetting.onChangeAction = {[unowned self, weak priceSetting] action in
            if case .string(let value) = action {
                guard let newPrice = value else { return }
                self.item.price = NSDecimalNumber(string: newPrice)
            }

            priceSetting?.currentValue = action
            self.delegate?.updateCanSave(canSave: self.canSave)
        }
    }

    func saveChanges() {
        let moc = item.managedObjectContext
        try! moc?.save()
    }

    func discardChanges() {
        let moc = item.managedObjectContext
        if isNew {
            moc?.delete(item)
            return
        }
        moc?.reset()
    }

}
