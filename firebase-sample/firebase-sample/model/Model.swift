//
//  Todo.swift
//  ios18
//
//  Created by Stephan on 30.04.18.
//  Copyright © 2018 mobile. All rights reserved.
//

import Foundation

class CostumUser: NSObject, Codable{
    let name: String
    let id: String
    
    init(name: String, id: String) {
        self.name = name
        self.id = id
    }
}

struct Todo: Codable, Equatable {
    let name: String
    let uid: String
    let id: String
}
