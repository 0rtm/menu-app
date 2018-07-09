//
//  AppEnvironment.swift
//  menuApp
//
//  Created by Artem Tselikov on 2018-07-08.
//  Copyright © 2018 Artem Tselikov. All rights reserved.
//

import Foundation
import CoreData

protocol Environment {
    var persistentContainer: NSPersistentContainer { get }
    var mainContext: NSManagedObjectContext { get }
    func saveContext()
}


struct AppEnvironment {

    static var current: Environment {
        // This will crash when current environment is not set
        return _currentEnvironment!
    }

    fileprivate static var _currentEnvironment: Environment?

    static func setEnvironment(_ env: Environment) {
        _currentEnvironment = env
    }
}
