
//
//  protocol.swift
//  firebase-sample
//
//  Created by Stephan on 07.05.18.
//  Copyright © 2018 mobile. All rights reserved.
//

import Foundation

protocol DatabaseObserverDelegate{
    associatedtype T
    func add(element: T)
    func delete(element: T)
}
