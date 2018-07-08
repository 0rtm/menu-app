//
//  MenuGroupEditiorViewController.swift
//  menuApp
//
//  Created by Artem Tselikov on 2018-07-07.
//  Copyright © 2018 Artem Tselikov. All rights reserved.
//

import UIKit

class MenuGroupEditiorViewController: UIViewController {

    @IBOutlet fileprivate weak var tableView: UITableView!

    var settings: [Setting] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()

        //Move to model class

        let titleSetting = Setting(title: "Title", inputFieldType: .small(keyboardType: .default)) { (action) in

            if case .string(let value) = action {
                print("title will be set to \(value ?? "N?A")")
            }
        }

        settings = [titleSetting]

    }

    fileprivate func setupNavigationBar() {
        setTitle()
        configureBarButtons()
    }

    fileprivate func setupTableView() {
        tableView.register(ShortInputTableViewCell.nib, forCellReuseIdentifier: ShortInputTableViewCell.reuseIdentifier)
        tableView.register(LongInputTableViewCell.nib, forCellReuseIdentifier: LongInputTableViewCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
    }

    fileprivate func setTitle() {
        title = "Edit"
    }

    fileprivate func configureBarButtons() {
        let addButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(save))
        self.navigationItem.rightBarButtonItem = addButton

        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
        self.navigationItem.leftBarButtonItem = cancelButton

    }

    @objc
    fileprivate func save() {
        cancel()
    }

    @objc
    fileprivate func cancel() {
        self.dismiss(animated: true, completion: nil)
    }

}

extension MenuGroupEditiorViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let setting = settings[indexPath.row]

        switch setting.inputFieldType {
        case .small(let keyboardType):
            return smallInputCell(tableView, indexPath, keyboardType, setting)

        case .large:
            return largeInputCell(tableView, indexPath, setting)
        }
    }

    fileprivate func smallInputCell(_ tableView: UITableView,
                                    _ indexPath: IndexPath,
                                    _ keyboardType: UIKeyboardType,
                                    _ setting: Setting) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ShortInputTableViewCell.reuseIdentifier, for: indexPath) as! ShortInputTableViewCell

        cell.titleLabel.text = setting.title
        cell.inputField.keyboardType = keyboardType
        cell.delegate = self

        return cell
    }

    fileprivate func largeInputCell(_ tableView: UITableView,
                                    _ indexPath: IndexPath,
                                    _ setting: Setting) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LongInputTableViewCell.reuseIdentifier, for: indexPath) as! LongInputTableViewCell

        cell.titleLabel.text = setting.title

        return cell
    }
}

extension MenuGroupEditiorViewController: UITableViewDelegate {

}

extension MenuGroupEditiorViewController: InputCellDelegate {

    func inputChanged(to value: String?, inCell cell: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        let setting = settings[indexPath.row]
        setting.onChangeAction(.string(newValue: value))
    }

}
