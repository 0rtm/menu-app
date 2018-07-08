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

    var model: MenuGroupEditor? = MenuGroupEditor(menuGroup: nil)
    fileprivate var indexOfEditingImage: IndexPath? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        model?.delegate = self
    }

    fileprivate func setupNavigationBar() {
        setTitle()
        configureBarButtons()
    }

    fileprivate func setupTableView() {
        tableView.register(ShortInputTableViewCell.nib, forCellReuseIdentifier: ShortInputTableViewCell.reuseIdentifier)
        tableView.register(LongInputTableViewCell.nib, forCellReuseIdentifier: LongInputTableViewCell.reuseIdentifier)
        tableView.register(ImageSelectionTableViewCell.nib, forCellReuseIdentifier: ImageSelectionTableViewCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 70
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
    }

    fileprivate func setTitle() {
        title = model?.title
    }

    fileprivate func configureBarButtons() {
        let addButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(save))
        self.navigationItem.rightBarButtonItem = addButton

        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
        self.navigationItem.leftBarButtonItem = cancelButton
    }

    @objc
    fileprivate func save() {
        model?.save()
        cancel()
    }

    @objc
    fileprivate func cancel() {
        self.dismiss(animated: true, completion: nil)
    }

    fileprivate func updateImageSetting(_ image: UIImage?, at indexPath: IndexPath) {
        guard let setting = model?.settings[indexPath.row] else {
            return
        }
        setting.onChangeAction?(.image(newValue: image))
    }

    fileprivate func updateStringSetting(_ string: String?, at indexPath: IndexPath) {
        guard let setting = model?.settings[indexPath.row] else {
            return
        }
        setting.onChangeAction?(.string(newValue: string))
    }
}

extension MenuGroupEditiorViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model?.settings.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let setting = model?.settings[indexPath.row] else {
            fatalError("Model must not be nil")
        }

        switch setting.inputFieldType {
        case .small(let keyboardType):
            return smallInputCell(tableView, indexPath, keyboardType, setting)
        case .large:
            return largeInputCell(tableView, indexPath, setting)
        case .image:
            return imageInputCell(tableView, indexPath, setting)
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

    fileprivate func imageInputCell(_ tableView: UITableView,
                                    _ indexPath: IndexPath,
                                    _ setting: Setting) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImageSelectionTableViewCell.reuseIdentifier, for: indexPath) as! ImageSelectionTableViewCell
        cell.titleLabel.text = setting.title
        cell.delegate = self

        if case .image(let image)? = setting.currentValue {
            cell.imagePreviewView?.image = image
        }

        return cell
    }
}

extension MenuGroupEditiorViewController: UITableViewDelegate {

}

extension MenuGroupEditiorViewController: SettingPresentationDelegate {

    func update(setting: Setting) {

        guard let index = model?.settings.index(of: setting) else {
            return
        }

        let indexPath = IndexPath(row: index, section: 0)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

extension MenuGroupEditiorViewController: InputCellDelegate {

    func inputChanged(to value: String?, inCell cell: UITableViewCell) {

        guard let indexpath = tableView.indexPath(for: cell) else {
            return
        }
        updateStringSetting(value, at: indexpath)
    }

}

extension MenuGroupEditiorViewController: ImageSelectionCellDelegate {

    func updateImage(fromCell cell: UITableViewCell) {
        indexOfEditingImage = tableView.indexPath(for: cell)
        showImagePickerController()
    }

    func deleteImage(fromCell cell: UITableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            updateImageSetting(nil, at: indexPath)
        }
    }

    fileprivate func showImagePickerController() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
}

extension MenuGroupEditiorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        guard let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            dismissPickerAndResetIndex()
            return
        }

        if let indexPath = indexOfEditingImage {
            updateImageSetting(pickedImage, at: indexPath)
        }
        dismissPickerAndResetIndex()
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismissPickerAndResetIndex()
    }

    fileprivate func dismissPickerAndResetIndex() {
        dismiss(animated: true, completion: nil)
        indexOfEditingImage = nil
    }
}
