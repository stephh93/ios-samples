//
//  FirebaseService.swift
//  firebase-sample
//
//  Created by Stephan on 05.05.18.
//  Copyright © 2018 mobile. All rights reserved.
//

import Foundation
import FirebaseAuth
import Firebase
import FirebaseDatabase

class FirebaseService: NSObject {
    
    //singleton instance
    static let shared = FirebaseService()
    var dataRef: DatabaseReference!
    var userRef: DatabaseReference!
    
    //observed value
    @objc dynamic var user: CostumUser?

    func configure()  {
        registerAuthListener()
        dataRef = Database.database().reference().child("data")
        userRef = Database.database().reference().child("user")
    }
    
    func userId () -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    fileprivate func fetchUser(_ fireUser: User?) {
        let query = self.userRef.child((fireUser!.uid))
        query.observeSingleEvent(of: .value, with: { (snap) in
            if let data = snap.value as? [String: String],
                let json = try? JSONEncoder().encode(data),
                let signdInUser = try? JSONDecoder().decode(CostumUser.self, from: json){
                self.user = signdInUser
            }
        })
    }
    
    func registerAuthListener(){
        Auth.auth().addStateDidChangeListener() { auth, fireUser in
            if fireUser != nil {
                NotificationCenter.default.post(name: .login, object: fireUser)
                self.fetchUser(fireUser)
            } else {
                NotificationCenter.default.post(name: .logout, object: fireUser)
                self.user = nil
            }
        }
    }
    
    func tryRegister(with email: String, and password: String, nickname: String){
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil || user == nil {
                NotificationCenter.default.post(name: .authError, object: error)
            } else{
                //create custom user
                let uid = user!.uid
                self.userRef.child(uid).setValue(CostumUser(name: nickname, id: uid).dictionary!)
            }
        }
    }
    
    func tryLogin(with email: String, and password: String){
        Auth.auth().signIn(withEmail: email, password: password) {(user, error) in
            if error != nil || user == nil {
                NotificationCenter.default.post(name: .authError, object: error)
            }
        }
    }
    
    func logout(){
        try? Auth.auth().signOut()
    }
    
    func add(todo: String, for user: String) {
        let childRef = dataRef.child(user).childByAutoId()
        let key = childRef.key
        let todo = Todo(name: todo, uid: user, id: key)
        if let data = todo.dictionary {
            childRef.setValue(data)
        }
    }
    
    func delete(todo: Todo) {
        dataRef.child(userId()!).child(todo.id).removeValue()
    }
    
    func addDatabase<TodoObserverDelegate: DatabaseObserverDelegate>(observer: TodoObserverDelegate) where TodoObserverDelegate.T == Todo{
        if let uid = userId() {
            let query = self.dataRef.child(uid).queryOrderedByKey()
            //listen for added items
            query.observe(.childAdded, with: { snap in
                if let data = snap.value as? [String: String],
                    let json = try? JSONEncoder().encode(data),
                    let todo = try? JSONDecoder().decode(Todo.self, from: json){
                    observer.add(element: todo)
                }
            })
            //listen for removed items
            query.observe(.childRemoved, with: { snap in
                if let data = snap.value as? [String: String],
                    let json = try? JSONEncoder().encode(data),
                    let todo = try? JSONDecoder().decode(Todo.self, from: json){
                    observer.delete(element: todo)
                }
            })
            //load all items once
            query.observeSingleEvent(of: .value, with: {(snap) in
                if let data = snap.value as? [String: String],
                    let json = try? JSONEncoder().encode(data),
                    let todo = try? JSONDecoder().decode(Todo.self, from: json){
                    observer.add(element: todo)
                }
            
            })
        }
    }
    
    func removeTableListener(){
        if let uid = userId() {
            let query = self.dataRef.child(uid).queryOrderedByKey()
            query.removeAllObservers()
        }
    }
    
}
