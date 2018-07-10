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
        resetContext()
    }

    func newMenuGroup() -> MenuGroup {
        return MenuGroup(context: moc)
    }

    func existingMenuGroup() -> MenuGroup {

        let m = MenuGroup(context: moc)
        m.title = "Lunch"
        m.info = "From 7 to 11"
        try! moc.save()

        return m
    }

    func menuEditorWith(group: MenuGroup)-> MenuGroupEditor {
        return MenuGroupEditor(menuGroup: group, isNew: false)
    }

    func menuEditorWithNew(group: MenuGroup)-> MenuGroupEditor {
        return MenuGroupEditor(menuGroup: group, isNew: true)
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

    func testCorrectTitleForExistingGroup() {
        let group = existingMenuGroup()
        let editor = menuEditorWith(group: group)
        XCTAssertEqual(editor.title, group.title)
        resetContext()
    }


    func setting(withTitle title: String, in sections: [SettingSection]) -> Setting? {

        for section in sections {

            guard case .settings(let settings) = section else {
                continue
            }

            for s in settings {
                if s.title == title {
                    return s
                }
            }

        }

        return nil
    }


    func testCanChangeTitleAndImage() {
        let editor = newMenuGroupEditor()

        let hasTitleSetting = setting(withTitle: "Title", in: editor.sections) != nil
        XCTAssertTrue(hasTitleSetting, "Editor must have title setting")

        let hasImageSetting = setting(withTitle: "Image", in: editor.sections) != nil
        XCTAssertTrue(hasImageSetting, "Editor must have image setting")

        resetContext()
    }

    func testNewGroupIsDeleted() {

        let group = newMenuGroup()
        let editor = menuEditorWithNew(group: group)
        group.title = "Soup"
        editor.discardChanges()
        XCTAssertTrue(group.isDeleted, "New group must be deleted")
        resetContext()
    }

    func testChangesRevertedWhenCancelled() {
        let group = existingMenuGroup()
        let editor = menuEditorWith(group: group)

        let newTitle = "A new title"
        group.title = newTitle
        editor.discardChanges()

        XCTAssertFalse(group.isDeleted, "Group must not be deleted")
        XCTAssertNotNil(group.managedObjectContext, "Group context must not be null")
        XCTAssertNotEqual(newTitle, group.title, "Title must not chage")

        resetContext()
    }

    func testChangingTitleHasEffect() {
        let group = existingMenuGroup()
        let editor = menuEditorWith(group: group)

        let titleSetting = setting(withTitle: "Title", in: editor.sections)

        XCTAssertNotNil(titleSetting, "Title setting must exist")

        let newTitle = "Pizza"

        titleSetting!.onChangeAction?(.string(value: newTitle))
        XCTAssertEqual(newTitle, group.title)

        resetContext()
    }

    func testChangingImageHasEffect() {
        let group = existingMenuGroup()
        let editor = menuEditorWith(group: group)

        let imageSetting = setting(withTitle: "Image", in: editor.sections)

        XCTAssertNotNil(imageSetting, "Image setting must exist")

        let newImage = UIImage(named: "TestImage")

        imageSetting!.onChangeAction?(.image(value: newImage))
        XCTAssertEqual(newImage, group.image)

        resetContext()
    }

    func TestDeleteActionDeletes() {
        
    }

    func resetContext() {
        moc.reset()
    }

}
