//
//  LogInViewController.swift
//
//  This is the view controller where users login


import UIKit
import FirebaseAuth


class LogInViewController: UIViewController {

    //Textfields pre-linked with IBOutlets
    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC=segue.destination as! MPOMainViewController
        var arr = emailTextfield.text!.components(separatedBy: ".")
        destinationVC.email = arr[0]
        print("hello")
        
    }
    @IBAction func logInPressed(_ sender: AnyObject) {
        //SVProgressHUD.show()
        Auth.auth().signIn(withEmail: emailTextfield.text!, password: passwordTextfield.text!) { (user, error) in
            if (error != nil){
                print (error!)
                let alert = UIAlertController(title: "Error!", message: "Something is wrong please try again!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in alert.dismiss(animated: true, completion: nil)}))
                self.present(alert, animated: true, completion: nil)
            } else{
                print("Login was successful!")
                self.performSegue(withIdentifier: "goToChat", sender: self)
                //SVProgressHUD.dismiss()
            }
        }
        
        //TODO: Log in the user
        
        
    }
    


    
}  
