//
//  SettingPresentationDelegate.swift
//  menuApp
//
//  Created by Artem Tselikov on 2018-07-08.
//  Copyright © 2018 Artem Tselikov. All rights reserved.
//

import Foundation

protocol SettingPresentationDelegate: class {
    func update(setting: Setting)
    func updateTitle()
    func updateCanSave(canSave: Bool)
    func dismiss()
}
