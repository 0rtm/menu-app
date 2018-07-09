//
//  AppDelegate.swift
//  menuApp
//
//  Created by Artem Tselikov on 2018-07-06.
//  Copyright © 2018 Artem Tselikov. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var coordinator: Coordinator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        AppEnvironment.setEnvironment(DefaultEnvironment.shared)

        coordinator = Coordinator()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = coordinator?.rootViewController
        window?.makeKeyAndVisible()

        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        AppEnvironment.current.saveContext()
    }
}

