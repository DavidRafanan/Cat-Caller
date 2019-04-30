//
//  LoginViewController.swift
//  Cat Caller
//
//  Created by David Rafanan on 4/25/19.
//  Copyright © 2019 David Rafanan. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {

    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var identityTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var signupButton: UIButton!
    
    var signUpMode =  false //default log in mode
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        errorLabel.isHidden = true
    }
    
    
    @IBAction func loginTapped(_ sender: Any) {
        if signUpMode { //signup
            let user = PFUser()
            
            user.username = identityTextField.text
            user.password = passwordTextField.text
            
            user.signUpInBackground(block: { (success, error) in
                if error != nil {
                    
                    var errorMessage = "Sign Up Failed - Try Again"
                    
                    if let newError = error as? NSError {
                        
                        if let detailError = newError.userInfo["error"] as? String {
                            
                                errorMessage = detailError
                            
                        }
                    }
                    
                    self.errorLabel.isHidden = false
                    self.errorLabel.text = errorMessage
                } else {
                    print("Sign Up Successful")
                    self.performSegue(withIdentifier: "updateSegue", sender: nil)
                }
            })
        } else { //login
            if let identity = identityTextField.text {
                if let password = passwordTextField.text {
                    PFUser.logInWithUsername(inBackground: identity, password: password, block: { (user,error) in
                        if error != nil {
                            
                            var errorMessage = "Login Failed - Try Again"
                            
                            if let newError = error as? NSError {
                                
                                if let detailError = newError.userInfo["error"] as? String {
                                    
                                    errorMessage = detailError
                                    
                                }
                            }
                            
                            self.errorLabel.isHidden = false
                            self.errorLabel.text = errorMessage
                        } else {
                            print("Login Successful")
                            
                            if user?["isFemale"] != nil {  //user is optional
                                self.performSegue(withIdentifier: "loginToCatCallSegue", sender: nil)
                            } else { //has to update info
                                self.performSegue(withIdentifier: "updateSegue", sender: nil)
                            }
                            
                            //self.performSegue(withIdentifier: "updateSegue", sender: nil)
                        }
                    })
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if PFUser.current() != nil {
            
            //someone already logged in (!= nil)
            if PFUser.current()?["isFemale"] != nil {
                self.performSegue(withIdentifier: "loginToCatCallSegue", sender: nil)
            } else { //has to update info
                self.performSegue(withIdentifier: "updateSegue", sender: nil)
            }
            
        }
    }
    
    @IBAction func signupTapped(_ sender: Any) {
        if signUpMode {  //in sign up mode
            loginButton.setTitle("Log In", for: .normal)
            signupButton.setTitle("Sign Up", for: .normal)
            signUpMode = false  //back to log in
        } else {  //in log in mode
            loginButton.setTitle("Sign Up", for: .normal)
            signupButton.setTitle("Log In", for: .normal)
            signUpMode = true   //back to sign up
        }
        
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
