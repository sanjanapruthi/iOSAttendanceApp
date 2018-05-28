//
//  RegisterViewController.swift
//  
//  This is the View Controller which registers new users with Firebase
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {

    
    //Pre-linked IBOutlets

    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

  
    @IBAction func registerPressed(_ sender: AnyObject) {
        Auth.auth().createUser(withEmail: emailTextfield.text!, password: passwordTextfield.text!) { (user, error) in // inside a closure
            if (error != nil){
                print(error!)
            }else {
                print ("Registration successful")
                //self.performSegue(withIdentifier: "goToChat", sender: self)
            }
        }
        
        
    } 
    
    
}
