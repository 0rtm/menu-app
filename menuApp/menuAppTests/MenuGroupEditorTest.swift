//
//  MenuGroupEditorTest.swift
//  menuAppTests
//
//  Created by Artem Tselikov on 2018-07-09.
//  Copyright © 2018 Artem Tselikov. All rights reserved.
//

import XCTest
import CoreData
@testable import menuApp

class MenuGroupEditorTest: XCTestCase {

    var moc: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        let testHelper = TestHelper()
        //Set current environment
        moc = AppEnvironment.current.mainContext
        AppEnvironment.setEnvironment(testHelper.testEnvironment)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    func newMenuGroup() -> MenuGroup {
        return MenuGroup(context: moc)
    }

    func newMenuGroupEditor() -> MenuGroupEditor {
        return MenuGroupEditor(menuGroup: newMenuGroup(), isNew: true)
    }

    func testHasCorrectTitleForNewGroup() {
        let editor = newMenuGroupEditor()
        XCTAssertEqual(editor.title, "New Group")
        resetContext()
    }

    func testCannotSaveWithoutTitle() {
        let editor = newMenuGroupEditor()
        XCTAssertFalse(editor.canSave)
        resetContext()
    }

    func resetContext() {
        moc.reset()
    }

}
