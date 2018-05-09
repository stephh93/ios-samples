//
//  RegisterViewController.swift
//  firebase-sample
//
//  Created by Stephan on 05.05.18.
//  Copyright © 2018 mobile. All rights reserved.
//
import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var nickText: UITextField!
    @IBOutlet weak var pwValText: UITextField!
    @IBOutlet weak var pwText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    
    var spinner : UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardOnTapOutside()
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleRegisterCallback), name: .login, object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(handleErrorCallback), name: .authError, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @objc func handleRegisterCallback (_ notification: Notification){
        performSegue(withIdentifier: "register", sender: self)
        if spinner != nil {
            self.removeSpinner(spinner: spinner!)
        }
    }
    
    @objc func handleErrorCallback (_ notification: Notification){
        if let error = notification.object as? NSError {
            if let errCode = AuthErrorCode(rawValue: error._code) {
                switch errCode {
                case .invalidEmail: emailText.error(shakeCount: 4); break;
                case .emailAlreadyInUse: emailText.error(shakeCount: 4); break;
                case .weakPassword: pwText.error(shakeCount: 4); break;
                default:
                    emailText.error(shakeCount: 4)
                    pwText.error(shakeCount: 4)
                }
            }
        }
        if spinner != nil {
            self.removeSpinner(spinner: spinner!)
        }
    }

    @IBAction func tryRegister(_ sender: Any) {
        if let email = emailText.text , let pw = pwText.text, let pwVal = pwValText.text, let nick = nickText.text {
            if email.isEmpty{
                emailText.error(shakeCount: 4)
            }else if pw.isEmpty {
                pwText.error(shakeCount: 4)
            }else if pwVal.isEmpty {
                pwValText.error(shakeCount: 4)
            }else if pwVal != pw {
                pwValText.error(shakeCount: 4)
            }else if nick.isEmpty {
                nickText.error(shakeCount: 4)
            }else {
                FirebaseService.shared.tryRegister(with: email, and: pw, nickname: nick)
                self.spinner = self.displaySpinner(onView: self.view)
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "register" {
            pwValText.text = ""
            pwText.text = ""
            emailText.text = ""
            nickText.text = ""
        }
    }
    
}
