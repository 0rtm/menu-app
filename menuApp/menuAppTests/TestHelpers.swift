//
//  TestHelpers.swift
//  menuAppTests
//
//  Created by Artem Tselikov on 2018-07-09.
//  Copyright © 2018 Artem Tselikov. All rights reserved.
//

import Foundation
import CoreData
@testable import menuApp

struct TestEnvironment: Environment {

    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func saveContext() {
        try! mainContext.save()
    }

    let persistentContainer: NSPersistentContainer

}

class TestHelper {

    lazy var persistenContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "menuApp")
        try! container.persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
        return container

    }()


    lazy var testEnvironment: Environment = {
        return TestEnvironment(persistentContainer: persistenContainer)
    }()

}
