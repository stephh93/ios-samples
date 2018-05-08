//
//  TableViewController.swift
//  ios18
//
//  Created by Stephan on 18.04.18.
//  Copyright © 2018 mobile. All rights reserved.
//

import UIKit

class ToDoTableViewController: UITableViewController  {
    
    var name : String!
    var database = Database<Todo>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //hide seperators of empty cells in tableview
        self.tableView.tableFooterView = UIView()
        
        self.setupNavigationItems()
        self.registerObservers()
        self.database.add(element: Todo(with: "Demo"))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .add, object: nil)
        NotificationCenter.default.removeObserver(self, name: .delete, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupNavigationItems() {
        //set title in Navigationbar
        self.navigationItem.title = name + "'s Todos"
        
        self.navigationItem.hidesBackButton = true
        //add '+'imagebutton to top right corner
        let addImage = UIImage(named: "ic_add")?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: addImage , style: .done, target: self, action: #selector(addTodoTapped))
        
        //add logoutbutton to top left corner
        let logoutButton = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.plain, target: self, action: #selector(logout))
        self.navigationItem.leftBarButtonItem = logoutButton
        
    }
    
    @objc func logout() {
        _ = navigationController?.popViewController(animated: true)
    }
  
    //TableviewDelegate set section count
    override func numberOfSections(in tableView: UITableView) -> Int{
        return 1
    }
    
    //TableviewDelegate set row count
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.database.table.count
    }
    
    //TableviewDelegate set cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath) as? TodoTableViewCell  else {
            fatalError("The dequeued cell is not an instance of TodoTableViewCell.")
        }
        cell.todoName.text = self.database.table[indexPath.row].name
        cell.deleteButton.tag = indexPath.row
        cell.deleteButton.addTarget(self, action: #selector(deleteIndex), for: .touchUpInside)
        return cell
    }
    
     //TableviewDelegate enable editing
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
     //TableviewDelegate enable  swipe to delete
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            self.database.delete(at: indexPath.row)
        }
    }
    
    @objc func deleteIndex(_ sender: AnyObject){
        let index = sender.tag!
        self.database.delete(at: index)
    }
    
    //open AlertController to add a new Todo
    @objc func addTodoTapped(){
        let alert = UIAlertController(title: "Neue Aufgabe", message: "Neue Aufgabe hinzufügen", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = ""
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0]
            self.database.add(element: Todo(with: textField.text!))
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func registerObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(addItem(_:)), name: .add, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deleteItem(_:)), name: .delete, object: nil)
    }
    
    @objc func addItem(_ notfication: NSNotification){
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [IndexPath(row: database.table.count-1, section: 0)], with: .automatic)
            self.tableView.endUpdates()
        
    }
    
    @objc func deleteItem(_ notfication: NSNotification){
        if let index = notfication.object as? Int {
            self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
    }
   
}
