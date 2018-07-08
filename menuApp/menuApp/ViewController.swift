//
//  ViewController.swift
//  menuApp
//
//  Created by Artem Tselikov on 2018-07-06.
//  Copyright © 2018 Artem Tselikov. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()



        //saveItem()

        // Do any additional setup after loading the view, typically from a nib.
    }




    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let menuGroupVC = MenuGroupViewController(nibName: "MenuGroupViewController", bundle: nil)
        self.navigationController?.pushViewController(menuGroupVC, animated: true)
    }

    func saveItem() {

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let moc = appDelegate.persistentContainer.viewContext
        let item = MenuItem(context: moc)
        try! moc.save()

        totalItems()
    }


    func totalItems() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let moc = appDelegate.persistentContainer.viewContext

        let r = NSFetchRequest<MenuItem>(entityName: "MenuItem")

        let items = try! moc.fetch(r)
        print(items.count)

    }

}

