//
//  MenuGroupEditiorViewController.swift
//  menuApp
//
//  Created by Artem Tselikov on 2018-07-07.
//  Copyright © 2018 Artem Tselikov. All rights reserved.
//

import UIKit

class EditorViewController: UIViewController, ViewControllerFromNib {

    @IBOutlet fileprivate weak var tableView: UITableView!

    var model: ConfigurableObject?
    fileprivate var indexOfEditingImage: IndexPath? = nil
    fileprivate var saveButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        model?.delegate = self
    }

    fileprivate func setupNavigationBar() {
        configureBarButtons()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTitle()
    }

    fileprivate func setupTableView() {
        tableView.register(ShortInputTableViewCell.nib, forCellReuseIdentifier: ShortInputTableViewCell.reuseIdentifier)
        tableView.register(LongInputTableViewCell.nib, forCellReuseIdentifier: LongInputTableViewCell.reuseIdentifier)
        tableView.register(ImageSelectionTableViewCell.nib, forCellReuseIdentifier: ImageSelectionTableViewCell.reuseIdentifier)
        tableView.register(SettingActionTableViewCell.nib, forCellReuseIdentifier: SettingActionTableViewCell.reuseIdentifier)
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
        saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(save))
        saveButton.isEnabled = model?.canSave ?? false
        self.navigationItem.rightBarButtonItem = saveButton

        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
        self.navigationItem.leftBarButtonItem = cancelButton
    }

    @objc
    fileprivate func save() {
        model?.saveChanges()
        self.dismiss(animated: true, completion: nil)
    }

    @objc
    fileprivate func cancel() {
        model?.discardChanges()
        self.dismiss(animated: true, completion: nil)
    }

    fileprivate func updateImageSetting(_ image: UIImage?, at indexPath: IndexPath) {
        let _setting = setting(at: indexPath)
        _setting?.onChangeAction?(.image(value: image))
    }

    fileprivate func updateStringSetting(_ string: String?, at indexPath: IndexPath) {
        let _setting = setting(at: indexPath)
        _setting?.onChangeAction?(.string(value: string))
    }

    fileprivate func setting(at indexPath: IndexPath) -> Setting? {
        guard let section = model?.sections[indexPath.section] else {
            return nil
        }

        guard  case .settings(let settings) = section else {
            return nil
        }

        return settings[indexPath.row]
    }

    fileprivate func action(at indexPath: IndexPath) -> Action? {
        guard let section = model?.sections[indexPath.section] else {
            return nil
        }

        guard case .actions(let actions) = section else {
            return nil
        }

        return actions[indexPath.row]
    }
}

extension EditorViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return model?.sections.count ?? 0
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 10.0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        guard let section = model?.sections[section] else {
            return 0
        }
        switch section {
        case .settings(let settings):
            return settings.count
        case .actions(let actions):
            return actions.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let section = model?.sections[indexPath.section] else {
            fatalError("Model must not be nil")
        }

        switch section {
        case .settings(let settings):
             return cellForSettings(settings, indexPath, tableView)
        case .actions(let actions):
            return cellForActions(actions, indexPath, tableView)
        }
    }

    fileprivate func cellForSettings(_ settings: [Setting], _ indexPath: IndexPath, _ tableView: UITableView) -> UITableViewCell {
        let setting = settings[indexPath.row]
        switch setting.inputFieldType {
        case .small(let keyboardType):
            return smallInputCell(tableView, indexPath, keyboardType, setting)
        case .large:
            return largeInputCell(tableView, indexPath, setting)
        case .image:
            return imageInputCell(tableView, indexPath, setting)
        }
    }

    fileprivate func cellForActions(_ action: [Action],
                                    _ indexPath: IndexPath,
                                    _ tableView: UITableView)-> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: SettingActionTableViewCell.reuseIdentifier, for: indexPath) as! SettingActionTableViewCell
        cell.titleLabel.text = action[indexPath.row].title
        return cell

    }

    fileprivate func smallInputCell(_ tableView: UITableView,
                                    _ indexPath: IndexPath,
                                    _ keyboardType: UIKeyboardType,
                                    _ setting: Setting) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ShortInputTableViewCell.reuseIdentifier, for: indexPath) as! ShortInputTableViewCell

        cell.titleLabel.text = setting.title
        cell.inputField.keyboardType = keyboardType

        if case .string(let value)? = setting.currentValue {
            cell.inputField.text = value
        }

        cell.delegate = self

        return cell
    }

    fileprivate func largeInputCell(_ tableView: UITableView,
                                    _ indexPath: IndexPath,
                                    _ setting: Setting) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LongInputTableViewCell.reuseIdentifier, for: indexPath) as! LongInputTableViewCell
        cell.titleLabel.text = setting.title
        cell.delegate = self
        if case .string(let value)? = setting.currentValue {
            cell.textView.text = value
        }
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

extension EditorViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)

        guard let action = action(at: indexPath) else {
            return
        }
        action.onAction?()
    }

}

extension EditorViewController: SettingPresentationDelegate {

    func dismiss() {
        dismiss(animated: true, completion: nil)
    }

    func updateCanSave(canSave: Bool) {
        saveButton.isEnabled = canSave
    }

    func update(setting: Setting) {

        guard let sections = model?.sections else {
            return
        }

        for (sectionIndex, section) in sections.enumerated() {

            guard case .settings(let settins) = section else {
                break
            }

            guard let indexOfSetting = settins.index(of: setting) else {
                break
            }

            let indexPath = IndexPath(row: indexOfSetting, section: sectionIndex)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}

extension EditorViewController: InputCellDelegate {

    func inputChanged(to value: String?, inCell cell: UITableViewCell) {

        guard let indexpath = tableView.indexPath(for: cell) else {
            return
        }
        updateStringSetting(value, at: indexpath)
    }

}

extension EditorViewController: ImageSelectionCellDelegate {

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

extension EditorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

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
