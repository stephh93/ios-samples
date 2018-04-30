//
//  ViewController.swift
//  ios18
//
//  Created by Stephan on 18.04.18.
//  Copyright © 2018 mobile. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var nickText: UITextField!
    @IBOutlet weak var pwValText: UITextField!
    @IBOutlet weak var pwText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardOnTapOutside()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    @IBAction func tryRegister(_ sender: Any) {
        if let pw = self.pwText.text , let pwVal = self.pwValText.text {
            if (pwVal.isEmpty || pw != pwVal){
                self.pwValText.error(shakeCount: 4)
            }else{
                tryLogin(_: sender)
            }
        }
    }
    
    @IBAction func tryLogin(_ sender: Any) {
        if let pw = self.pwText.text ,let nick = self.nickText.text {
            if(nick.isEmpty){
                self.nickText.error(shakeCount: 4)
            } else if(pw.isEmpty){
                self.pwText.error(shakeCount: 4)
            }else{
                performSegue(withIdentifier: "login", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "login" {
            if let tableVC = segue.destination as? ToDoTableViewController {
                tableVC.name = nickText.text
            }
            nickText.text = ""
            pwValText.text = ""
            pwText.text = ""
        }
    }
    
}


