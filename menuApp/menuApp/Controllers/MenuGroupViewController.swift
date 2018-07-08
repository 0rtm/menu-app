//
//  MenuGroupViewController.swift
//  menuApp
//
//  Created by Artem Tselikov on 2018-07-07.
//  Copyright © 2018 Artem Tselikov. All rights reserved.
//

import UIKit

class MenuGroupViewController: UIViewController {

    @IBOutlet fileprivate weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
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

    }

    @objc
    fileprivate func addItem() {
        let editorVC = MenuGroupEditiorViewController(nibName: "MenuGroupEditiorViewController", bundle: nil)

        let navVC = UINavigationController()
        navVC.viewControllers = [editorVC]

        present(navVC, animated: true, completion: nil)
    }

}
