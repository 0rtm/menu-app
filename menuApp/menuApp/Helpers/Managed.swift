//
//  Managed.swift
//  menuApp
//
//  Created by Artem Tselikov on 2018-07-09.
//  Copyright © 2018 Artem Tselikov. All rights reserved.
//

import Foundation
import CoreData

protocol Managed {
    static var defaultSortDescriptors: [NSSortDescriptor] { get }
}
