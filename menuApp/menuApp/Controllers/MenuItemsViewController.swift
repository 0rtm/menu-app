//
//  MenuItemsViewController.swift
//  menuApp
//
//  Created by Artem Tselikov on 2018-07-08.
//  Copyright © 2018 Artem Tselikov. All rights reserved.
//

import UIKit
import CoreData

protocol MenuItemsViewControllerDelegate: class {
    func newMenuItem(inGroup: MenuGroup)
    func editMenuItem(menuItem: MenuItem)
}

final class MenuItemsViewController: UIViewController, ViewControllerFromNib {

    @IBOutlet weak var tableView: UITableView!
    fileprivate var fetchedResultsController: NSFetchedResultsController<MenuItem>?

    weak var delegate: MenuItemsViewControllerDelegate? = nil
    var menuGroup: MenuGroup? = nil

    fileprivate lazy var currencyNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()

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
        title = menuGroup?.title ?? "Items"
    }

    fileprivate func configureBarButtons() {
        let addButton = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addItem))
        self.navigationItem.rightBarButtonItem = addButton
    }

    fileprivate func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MenuItemTableViewCell.nib, forCellReuseIdentifier: MenuItemTableViewCell.reuseIdentifier)
        tableView.tableFooterView = UIView()
    }

    fileprivate func setupFetchedResultsController() {

        guard let _menuGroup = menuGroup else {
            return
        }
        
        let moc = AppEnvironment.current.mainContext

        let r =  NSFetchRequest<MenuItem>(entityName: "MenuItem")
        r.fetchBatchSize = 20
        r.sortDescriptors = MenuItem.defaultSortDescriptors
        r.predicate = NSPredicate(format:"group = %@", _menuGroup)

        fetchedResultsController = NSFetchedResultsController(fetchRequest: r, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self
        try! fetchedResultsController?.performFetch()
        tableView.reloadData()
    }

    @objc
    fileprivate func addItem() {

        guard let group = menuGroup else {
            return
        }
        
        delegate?.newMenuItem(inGroup: group)
    }
    
}

extension MenuItemsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController?.fetchedObjects?.count ?? 0
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let object = fetchedResultsController?.object(at: indexPath) else {
                return
            }
            let moc = object.managedObjectContext
            moc?.delete(object)
            try! moc?.save()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let menuItem = fetchedResultsController?.object(at: indexPath) else {
            fatalError("Fetched results controller must not be nil")
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: MenuItemTableViewCell.reuseIdentifier, for: indexPath) as! MenuItemTableViewCell

        cell.configure(forMenuItem: menuItem, numberFormatter: currencyNumberFormatter)

        return cell
    }
}

extension MenuItemsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let item = fetchedResultsController?.object(at: indexPath) else {
            return
        }
        delegate?.editMenuItem(menuItem: item)
    }
}

extension MenuItemsViewController: NSFetchedResultsControllerDelegate {

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
            guard let item = controller.object(at: indexPath) as? MenuItem else { break}
            guard let cell = tableView.cellForRow(at: indexPath) as? MenuItemTableViewCell else { break }
            cell.configure(forMenuItem: item, numberFormatter: currencyNumberFormatter)
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
