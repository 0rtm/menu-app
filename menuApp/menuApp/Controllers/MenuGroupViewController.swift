//
//  MenuGroupViewController.swift
//  menuApp
//
//  Created by Artem Tselikov on 2018-07-07.
//  Copyright © 2018 Artem Tselikov. All rights reserved.
//

import UIKit
import CoreData

class MenuGroupViewController: UIViewController {

    @IBOutlet fileprivate weak var tableView: UITableView!

    fileprivate var frController: NSFetchedResultsController<MenuGroup>?
    fileprivate var _editRowAction: UITableViewRowAction?

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
        self.navigationItem.rightBarButtonItem = addButton
    }


    fileprivate func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MenuGroupTableViewCell.nib, forCellReuseIdentifier: MenuGroupTableViewCell.reuseIdentifier)
        tableView.tableFooterView = UIView()
    }

    fileprivate func setupFetchedResultsController() {

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let moc = appDelegate.persistentContainer.viewContext

        let r =  NSFetchRequest<MenuGroup>(entityName: "MenuGroup")
        r.fetchBatchSize = 20
        r.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]

        frController = NSFetchedResultsController(fetchRequest: r, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        frController?.delegate = self
        try! frController?.performFetch()
    }

    fileprivate var editorVC: MenuGroupEditiorViewController {
        return MenuGroupEditiorViewController(nibName: "MenuGroupEditiorViewController", bundle: nil)
    }

    fileprivate func showEditor(for group: MenuGroup?) {

        let _editorVC = editorVC
        let model = MenuGroupEditor(menuGroup: group)

        _editorVC.model = model

        
        let navVC = UINavigationController()
        navVC.viewControllers = [_editorVC]

        present(navVC, animated: true, completion: nil)
    }

    @objc
    fileprivate func addItem() {
        showEditor(for: nil)
    }

}

extension MenuGroupViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return frController?.fetchedObjects?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let menuGroup = frController?.object(at: indexPath) else {
            fatalError("Fetched results controller must not be nil")
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: MenuGroupTableViewCell.reuseIdentifier, for: indexPath) as! MenuGroupTableViewCell

        cell.configureFor(menuGroup: menuGroup)
        return cell
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return [editRowAction()]
    }

    func editRowAction() -> UITableViewRowAction {

        if _editRowAction == nil {
            _editRowAction = UITableViewRowAction(style: .normal, title: "Edit", handler: {[unowned self] (action, indexPath) in
                let menuGroup = self.frController?.object(at: indexPath)
                self.showEditor(for: menuGroup)
            })
        }
        return _editRowAction!
    }
}

extension MenuGroupViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
        default:
            break
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
