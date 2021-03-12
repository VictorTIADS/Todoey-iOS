//
//  Category.swift
//  TodoeyCoreData
//
//  Created by Victor Batista on 11/03/21.
//  Copyright © 2021 Victor Batista. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    let items = List<Item>()
}
