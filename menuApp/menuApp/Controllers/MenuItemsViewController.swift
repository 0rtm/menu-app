//
//  MenuItemsViewController.swift
//  menuApp
//
//  Created by Artem Tselikov on 2018-07-08.
//  Copyright © 2018 Artem Tselikov. All rights reserved.
//

import UIKit
import CoreData

class MenuItemsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    fileprivate var fetchedResultsController: NSFetchedResultsController<MenuItem>?

    var menuGroup: MenuGroup? = nil

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

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let moc = appDelegate.persistentContainer.viewContext

        let r =  NSFetchRequest<MenuItem>(entityName: "MenuItem")
        r.fetchBatchSize = 20
        r.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]

        fetchedResultsController = NSFetchedResultsController(fetchRequest: r, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self
        try! fetchedResultsController?.performFetch()
        tableView.reloadData()
    }

    @objc
    fileprivate func addItem() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let editorVC = MenuGroupEditiorViewController(nibName: "MenuGroupEditiorViewController", bundle: nil)
        let moc = appDelegate.persistentContainer.viewContext

        let item = MenuItem(context: moc)

        let model = MenuItemEditor(item: item, isNew: true)//MenuGroupEditor(menuGroup: group)

        editorVC.model = model

        let navVC = UINavigationController()
        navVC.viewControllers = [editorVC]

        present(navVC, animated: true, completion: nil)
    }
    
}

extension MenuItemsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController?.fetchedObjects?.count ?? 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return MenuItemTableViewCell.defaultHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let menuItem = fetchedResultsController?.object(at: indexPath) else {
            fatalError("Fetched results controller must not be nil")
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: MenuItemTableViewCell.reuseIdentifier, for: indexPath) as! MenuItemTableViewCell

        cell.configure(forMenuItem: menuItem)

        return cell
    }
}

extension MenuItemsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
            tableView.reloadRows(at: [indexPath], with: .automatic)
        default:
            break
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
