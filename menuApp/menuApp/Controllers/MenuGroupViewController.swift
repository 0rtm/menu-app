//
//  MenuGroupViewController.swift
//  menuApp
//
//  Created by Artem Tselikov on 2018-07-07.
//  Copyright © 2018 Artem Tselikov. All rights reserved.
//

import UIKit
import CoreData

protocol MenuGroupViewControllerDelegate: class {
    func addNewGroup()
    func selected(menuGroup: MenuGroup)
    func edit(menuGroup: MenuGroup)
}

class MenuGroupViewController: UIViewController, ViewControllerFromNib {

    weak var delegate: MenuGroupViewControllerDelegate? = nil

    @IBOutlet fileprivate weak var tableView: UITableView!

    fileprivate var fetchedResultsController: NSFetchedResultsController<MenuGroup>?
    fileprivate var _editRowAction: UITableViewRowAction?
    fileprivate var _deleteRowAction: UITableViewRowAction?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        setupFetchedResultsController()
    }

    fileprivate func setupNavigationBar() {
        setTitle()
        configureBarButtons()
    }

    fileprivate func setTitle() {
        title = "Menu Groups"
    }

    fileprivate func configureBarButtons() {
        let addButton = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addItem))
        navigationItem.rightBarButtonItem = addButton

        let backButton = UIBarButtonItem()
        backButton.title = ""
        navigationItem.backBarButtonItem = backButton
    }

    fileprivate func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MenuGroupTableViewCell.nib, forCellReuseIdentifier: MenuGroupTableViewCell.reuseIdentifier)
        tableView.tableFooterView = UIView()
    }

    fileprivate func setupFetchedResultsController() {

        let moc = AppEnvironment.current.mainContext

        let r =  NSFetchRequest<MenuGroup>(entityName: "MenuGroup")
        r.fetchBatchSize = 20
        r.sortDescriptors = MenuGroup.defaultSortDescriptors

        fetchedResultsController = NSFetchedResultsController(fetchRequest: r, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self
        try! fetchedResultsController?.performFetch()
        tableView.reloadData()
    }

    @objc
    fileprivate func addItem() {
        delegate?.addNewGroup()
    }

}

extension MenuGroupViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController?.fetchedObjects?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let menuGroup = fetchedResultsController?.object(at: indexPath) else {
            fatalError("Fetched results controller must not be nil")
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: MenuGroupTableViewCell.reuseIdentifier, for: indexPath) as! MenuGroupTableViewCell

        cell.configureFor(menuGroup: menuGroup)
        return cell
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return [deleteRowAction(), editRowAction()]
    }

    func editRowAction() -> UITableViewRowAction {

        if _editRowAction == nil {
            _editRowAction = UITableViewRowAction(style: .normal, title: "Edit", handler: {[unowned self] (action, indexPath) in
                if let menuGroup = self.fetchedResultsController?.object(at: indexPath) {
                    self.delegate?.edit(menuGroup: menuGroup)
                }
            })
        }
        return _editRowAction!
    }

    func deleteRowAction() -> UITableViewRowAction {

        if _deleteRowAction == nil {
            _deleteRowAction = UITableViewRowAction(style: .destructive, title: "Delete", handler: {[unowned self] (action, indexPath) in
                guard let menuGroup = self.fetchedResultsController?.object(at: indexPath) else {
                    return
                }
                let moc = AppEnvironment.current.mainContext
                moc.delete(menuGroup)
                try! moc.save()
            })
        }
        return _deleteRowAction!
    }
}

extension MenuGroupViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let menuGroup = fetchedResultsController?.object(at: indexPath) else {
            return
        }

        delegate?.selected(menuGroup: menuGroup)
    }
}

extension MenuGroupViewController: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case .insert:
            guard let indexPath = newIndexPath else { fatalError("Index path should be not nil") }
            tableView.insertRows(at: [indexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case .move:
            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
            guard let newIndexPath = newIndexPath else { fatalError("New index path should be not nil") }
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
