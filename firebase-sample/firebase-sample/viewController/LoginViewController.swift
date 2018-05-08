//
//  ViewController.swift
//  ios18
//
//  Created by Stephan on 18.04.18.
//  Copyright © 2018 mobile. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var pwText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    
    var spinner : UIView?
    
    let firebaseService = FirebaseService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardOnTapOutside()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleLoginCallback), name: .login, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleErrorCallback), name: .authError, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @objc func handleLoginCallback (_ notification: Notification){
        performSegue(withIdentifier: "login", sender: self)
        if spinner != nil {
            self.removeSpinner(spinner: spinner!)
        }
    }
    
    @objc func handleErrorCallback (_ notification: Notification){
        if let error = notification.object as? NSError {
            if let errCode = AuthErrorCode(rawValue: error._code) {
                switch errCode {
                case .invalidEmail: emailText.error(shakeCount: 4); break;
                case .invalidRecipientEmail: emailText.error(shakeCount: 4); break;
                case .wrongPassword: pwText.error(shakeCount: 4); break;
                default:
                    print("Create User Error: \(error)")
                }
            }
        }
        if spinner != nil {
            self.removeSpinner(spinner: spinner!)
        }
    }
    
 
    @IBAction func tryLogin(_ sender: Any) {
        if let email = emailText.text , let pw = pwText.text{
            if email.isEmpty{
                emailText.error(shakeCount: 4)
            }else if pw.isEmpty {
                pwText.error(shakeCount: 4)
            }else {
                self.firebaseService.tryLogin(with: email, and: pw)
                self.spinner = self.displaySpinner(onView: self.view)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "login" {
            pwText.text = ""
            emailText.text = ""
        }
    }
    
}


