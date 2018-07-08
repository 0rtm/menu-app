//
//  MenuItem.swift
//  menuApp
//
//  Created by Artem Tselikov on 2018-07-06.
//  Copyright © 2018 Artem Tselikov. All rights reserved.
//

import CoreData

public class MenuItem: NSManagedObject {

    @NSManaged var title: String
    @NSManaged var info: String
    @NSManaged var price: Decimal
    @NSManaged var imageData: Data

}
