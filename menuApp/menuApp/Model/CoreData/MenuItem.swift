//
//  MenuItem.swift
//  menuApp
//
//  Created by Artem Tselikov on 2018-07-06.
//  Copyright © 2018 Artem Tselikov. All rights reserved.
//

import CoreData
import UIKit

public class MenuItem: NSManagedObject {

    @NSManaged var title: String
    @NSManaged var createdAt: Date
    @NSManaged var info: String?
    @NSManaged var price: NSDecimalNumber
    @NSManaged var imageData: Data?
    @NSManaged var group: MenuGroup?

    var image: UIImage? {

        get {
            guard let data = imageData else {
                return nil
            }
            return UIImage(data: data)
        }

        set {
            guard let _image = newValue else {
                imageData = nil
                return
            }
            imageData = UIImageJPEGRepresentation(_image, 1)
        }
    }

    override public func awakeFromInsert() {
        self.createdAt = Date()
    }
}

extension MenuItem: Managed {

    static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: "createdAt", ascending: true)]
    }

}
