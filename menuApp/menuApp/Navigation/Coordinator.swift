//
//  Coordinator.swift
//  menuApp
//
//  Created by Artem Tselikov on 2018-07-08.
//  Copyright © 2018 Artem Tselikov. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Coordinator {

    let rootViewController: UINavigationController

    fileprivate func navigationController(with controller: UIViewController) -> UINavigationController {
        let nav = UINavigationController()
        nav.viewControllers = [controller]
        return nav
    }

    fileprivate var menuGroupsVC: MenuGroupViewController {
        let _menuGroupsVC =  MenuGroupViewController.fromNib()
        _menuGroupsVC.delegate = self
        return _menuGroupsVC
    }

    fileprivate var menuItemsVC: MenuItemsViewController {
        let _menuItemsVC = MenuItemsViewController.fromNib()
        _menuItemsVC.delegate = self
        return _menuItemsVC
    }

    fileprivate var editorVC: EditorViewController {
        return EditorViewController.fromNib()
    }

    fileprivate var moc: NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }

    fileprivate func showEditor(with model: ConfigurableObject) {
        let editor = editorVC
        editor.model = model

        let editorInNav = navigationController(with: editor)
        self.rootViewController.present(editorInNav, animated: true, completion: nil)
    }

    init() {
        rootViewController = UINavigationController()
        rootViewController.viewControllers = [menuGroupsVC]
    }

}

extension Coordinator: MenuGroupViewControllerDelegate {

    func edit(menuGroup: MenuGroup) {
        let model = MenuGroupEditor(menuGroup: menuGroup, isNew: false)
        showEditor(with: model)
    }

    func addNewGroup() {
        let newGroup = MenuGroup(context: moc)
        let model = MenuGroupEditor(menuGroup: newGroup, isNew: true)
        showEditor(with: model)
    }

    func selected(menuGroup: MenuGroup) {
        let _menuItemsVC = menuItemsVC
        _menuItemsVC.menuGroup = menuGroup
        rootViewController.pushViewController(_menuItemsVC, animated: true)
    }
}

extension Coordinator: MenuItemsViewControllerDelegate {

    func newMenuItem(inGroup group: MenuGroup) {
        let newIem = MenuItem(context: moc)
        newIem.group = group
        let model = MenuItemEditor(item: newIem, isNew: true)
        showEditor(with: model)
    }

    func editMenuItem(menuItem: MenuItem) {
        let model = MenuItemEditor(item: menuItem, isNew: false)
        showEditor(with: model)
    }

}
