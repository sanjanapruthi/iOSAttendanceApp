//
//  
//  This is the welcome view controller - the first thign the user sees
//

import UIKit
import FirebaseStorage



class WelcomeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

   
    override func viewDidLoad() {
        super.viewDidLoad()

    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func uploadImage(_ sender: UIButton) {
        let image = UIImagePickerController()
        image.delegate = self
        
        image.sourceType = UIImagePickerControllerSourceType.photoLibrary
        image.allowsEditing = true
        self.present(image, animated: true) {
            //when completed
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            var data = Data()
            data = UIImagePNGRepresentation(image)! //(image,0.8)!
            let storage = Storage.storage()
            
            // Create a storage reference from our storage service
            let imageRef = storage.reference().child("images/2");
            let uploadTask = imageRef.putData(data, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    return
                }
                // Metadata contains file metadata such as size, content-type.
                let size = metadata.size
                // You can also access to download URL after upload.
                imageRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        // Uh-oh, an error occurred!
                        return
                    }
                }
            }
            //let mountainsRef = storageRef.child("mountains.jpg")
        }else{
            ///crash?
        }
         dismiss(animated: true, completion: nil)
    }
}
