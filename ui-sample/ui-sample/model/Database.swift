//
//  DataBase.swift
//  ios18
//
//  Created by Stephan on 30.04.18.
//  Copyright © 2018 mobile. All rights reserved.
//

import Foundation

class Database<T> {
    
    var table = [T]()

    func add (element: T){
        table.append(element)
        NotificationCenter.default.post(name: .add, object: element)
    }
    
    func delete(at index: Int){
        table.remove(at: index)
        NotificationCenter.default.post(name: .delete, object: index)
    }
   
}
