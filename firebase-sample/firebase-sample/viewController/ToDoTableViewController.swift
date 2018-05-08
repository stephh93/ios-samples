//
//  TableViewController.swift
//  ios18
//
//  Created by Stephan on 18.04.18.
//  Copyright © 2018 mobile. All rights reserved.
//

import UIKit

class ToDoTableViewController: UITableViewController, DatabaseObserverDelegate {
   
    typealias T = Todo
    
    let firbaseService = FirebaseService.shared
    
    var kvObserver : NSKeyValueObservation?
    
    var todos = [Todo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.tableFooterView = UIView()
        self.setupNavigationItems()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        kvObserver?.invalidate()
    }
    
    func registerObservers(){
        //NotificationCenter
        NotificationCenter.default.addObserver(self, selector: #selector(logout), name: .logout, object: nil)
        //Key Value Observation
        kvObserver = firbaseService.observe(\.user, options: [.initial]) { (model, change) in
            self.navigationItem.title = self.firbaseService.user?.name
        }
        //Delegation
        self.firbaseService.addDatabase(observer: self)
    }
    
    //Tableview set section count
    override func numberOfSections(in tableView: UITableView) -> Int{
        return 1
    }
    
    //Tableview set row count
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.todos.count
    }
    
    //Tableview set cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath) as? TodoTableViewCell else {
            fatalError("Class cast excteption")
        }
        cell.todoLabel.text = todos[indexPath.row].name
        return cell
    }

    //Tableview enable editing
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //Tableview enable swipe to delete
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.firbaseService.delete(todo: todos[indexPath.row])
        }
    }
    
  
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupNavigationItems() {
        //set title in Navigationbar
       // self.navigationItem.title = name + "'s Todos"
        
        self.navigationItem.hidesBackButton = true
        //add '+'imagebutton to top right corner
        let addImage = UIImage(named: "ic_add")?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: addImage , style: .done, target: self, action: #selector(addTodoTapped))
        
        //add logoutbutton to top left corner
        let logoutButton = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.plain, target: self, action: #selector(tryLogout))
        self.navigationItem.leftBarButtonItem = logoutButton
        
    }
    
    @objc func tryLogout(){
        self.firbaseService.removeTableListener()
        firbaseService.logout()
    }
    
    @objc func logout() {
        _ = navigationController?.popViewController(animated: true)
    }

    
    //open AlertController to add a new Todo
    @objc func addTodoTapped(){
        let alert = UIAlertController(title: "Neue Aufgabe", message: "Neue Aufgabe hinzufügen", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = ""
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0]
            if let todoName = textField.text {
                if !todoName.isEmpty{
                    self.firbaseService.add(todo: todoName, for: self.firbaseService.userId()!)
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }

    func add(element: Todo){
            self.todos.append(element)
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [IndexPath(row: todos.count-1, section: 0)], with: .automatic)
            self.tableView.endUpdates()
        
    }
    
    func delete(element: Todo){
        if let index = todos.index(of: element) {
            todos.remove(at: index)
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            self.tableView.endUpdates()
        }
    }
   
}
