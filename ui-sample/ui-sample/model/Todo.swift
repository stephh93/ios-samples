//
//  Todo.swift
//  ios18
//
//  Created by Stephan on 30.04.18.
//  Copyright © 2018 mobile. All rights reserved.
//

import Foundation

class Todo: NSObject {
    var name: String
    var id: String
    
    init(with name: String) {
        self.name = name
        id = UUID().uuidString
    }
}
