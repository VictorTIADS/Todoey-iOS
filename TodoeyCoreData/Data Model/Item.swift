//
//  Item.swift
//  TodoeyCoreData
//
//  Created by Victor Batista on 11/03/21.
//  Copyright © 2021 Victor Batista. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
