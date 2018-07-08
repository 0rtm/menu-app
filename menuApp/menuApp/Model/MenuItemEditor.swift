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
        return item.title.count > 0
    }

    weak var delegate: SettingPresentationDelegate?
    
    var title: String {
        return item.title.count > 0 ? item.title : "New Item"
    }

    fileprivate let item: MenuItem
    fileprivate let isNew: Bool

    let settings: [Setting]

    init(item: MenuItem, isNew: Bool) {
        self.item = item
        self.isNew = isNew

        let titleSetting = Setting(title: "Title", inputFieldType: .small(keyboardType: .default))
        settings = [titleSetting]

        titleSetting.currentValue = SettingValue.string(newValue: item.title)
        titleSetting.onChangeAction = {[unowned self, weak titleSetting] action in
            if case .string(let value) = action {
                guard let newTitle = value else { return }
                self.item.title = newTitle
            }
            titleSetting?.currentValue = action
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
