//
//  FirebaseBrain.swift
//  ProjectOxfordFace_Example
//
//  Created by Neha Nish on 6/1/18.
//  Copyright © 2018 David Porter. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseCore
import FirebaseStorage

class FirebaseBrain: NSObject {
    
    //var groupNames: [NSString] = []
    var groupName: NSString = ""
    var personNames: [NSString] = []
    var faces: [UIImage] = []
    //var count: Integer = 0
    var email: NSString = ""
    var userArray = Array<Dictionary<String, Any>>()
    var personDictionary = Dictionary<NSString, [String]>()
    
    var ref: DatabaseReference!
    
    //LAST THING: LOAD FIREBASE SAVED DATA AT THE BEGINNING OF EACH APP
    
    override init(){
        ref = Database.database().reference().child("users")
        print("hey")
    }
    func ssave(){ //call firebase each time because a new brain is created with each new group
        print ("before saving to firebase database \(personDictionary)")
        var groupDictionary = Dictionary<NSString, Any>()
        //personDictionary = ["neha": ["link1","link2"], "tanvi" : ["link3","link4"]]
        //groupDictionary = ["Group Name": groupName, "person": personDictionary["PersonsName"]]
        groupDictionary = ["Group Name": groupName, "person": personDictionary]
        ref.child(email as String).child(groupName as String).setValue(groupDictionary)
        //ref.child(groupName as String).setValue(groupDictionary)
    }
    
    func saveEmailName(_ eN: NSString){
        email=eN
        print("email\(email)")
        var arr = email.components(separatedBy: ".")
        print(arr[0])
        email = arr[0] as NSString
        ///ref.child(arr[0])
    }
    
    func saveGroupName(_ gN: NSString){
        groupName=gN
    }
    
    func deleteFace(){
        print("address")
    }
    
    func retrieveGroupNames(_ m: NSString) -> Array<Any>{
        print("inside group names")
        var names: [Any] = []
        print (userArray)
        for dictionary in userArray{
            print(dictionary)
            if let test = dictionary["Group Name"] {
                print (test)
                names.append(test)
                print ("inside")
            } else {
                print("error")
            }
        }
        print (names)
        return names
    }
    
    func retrieve(_ m: NSString) {
        let appDelegate = UIApplication.shared.delegate as! MPOAppDelegate
        //appDelegate.groups
        
        
        
        ref.child(m as String).observeSingleEvent(of: .value, with: { (snapshot) in
            if let address = snapshot.value{
                print("address")
                let enumerator = snapshot.children
                while let listObject = enumerator.nextObject() as? DataSnapshot {
                    //print(listObject)
                    //print(listObject.value)
                    
                    var groupDictionary = Dictionary<String, Any>()
                    groupDictionary["Group Name"] = listObject.key
                    var pg: PersonGroup = PersonGroup()
                    pg.groupName=listObject.key
                    var ppl: NSMutableArray = []
                    //print(pg.groupName)
                    
                    
                    
                    groupDictionary["person"] = listObject.childSnapshot(forPath: "person").value
                    //var pD: NSArray = listObject.childSnapshot(forPath: "person").value as! NSArray
                    let pD: DataSnapshot = listObject.childSnapshot(forPath: "person")
                    
                    let iterator=pD.children
                   // print(iterator);
                    while let p = iterator.nextObject() as? DataSnapshot{
                        
                        var peron: GroupPerson = GroupPerson()
                        peron.personName = p.key
                        var facees: NSMutableArray = []
                        let arre: NSArray = p.value as! NSArray
                        let length: Int = arre.count
                        print("length\(length)")
                        for img in (p.value as? NSArray)!{
                            // download images for one face set to pface
                            //pFace.set //img is the link
                            let preUrl = NSURL(string: img as! String)
                            let url = URLRequest(url: preUrl! as URL)
                            //URLSession.shared session.dataTask
                            var count: Int = 0;
                            URLSession.shared.dataTask(with: url,   completionHandler:{(data,response,error) in
                               if error != nil {
                                    print ("error")
                                }
                                
                                /*if let image: UIImage = UIImage(data: data!){
                                    facees.add(image)
                                    count = count+1
                                    print(count)//litty
                                } else {print ("error with image")}
                                if (count==length){
                                    peron.faces=facees
                                    ppl.add(peron)
                                    print("i like you")
                                    print("this is peron\(peron.faces)")
                                    //print(appDelegate.groups)
                                } else {print("i hate you count \(count)")}*/
                                DispatchQueue.main.async{
                                    print("can someone pls define dispatch")
                                    if let image: UIImage = UIImage(data: data!){
                                        var pf: PersonFace = PersonFace()
                                        pf.image=image
                                        facees.add(pf)
                                        count = count+1
                                        print(count)//litty
                                    } else {print ("error with image")}
                                    if (count==length){
                                        peron.faces=facees
                                        
                                        ppl.add(peron)
                                        print("i like you")
                                        print("this is peron\(peron.faces)")
                                        //print(appDelegate.groups)
                                    } else {print("i hate you count \(count)")}
                                    
                                }
                            }).resume()
                        }
                    }
                    pg.people=ppl
                    appDelegate.groups.add(pg)
                    //print(listObject.childrenCount)
                    self.userArray.append(groupDictionary)
                    
                    //print(e)
                    //print(e.allObjects)
                    //print(self.userArray)
                    
                }
                
            } else {print ("error")}
            //print(groupDictionary)
            
            //for group in address!{
                //group.group
            //}
            //let user = User(username: username)
            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
        
        print (appDelegate.groups)
        
        print("after retrieved")
    }
    
    /*func returnGroupName(_ m: NSString) -> [String] {
        var myArray : [String] = [];
        ref.child(m as String).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value != nil{
                let enumerator = snapshot.children
                while let listObject = enumerator.nextObject() as? DataSnapshot {
                    print(listObject.key)
                    myArray.append(listObject.key)
                    print(myArray)
                }
            } else {print ("error")}
        }) { (error) in
            print(error.localizedDescription)
        }
        //print(myArray)
        return myArray
    }
    func returnPeople(_ m: NSString) -> [String] {
        var userArray: [String] = [];
        ref.child(m as String).observeSingleEvent(of: .value, with: { (snapshot) in
            if let address = snapshot.value{
                let enumerator = snapshot.children
                while let listObject = enumerator.nextObject() as? DataSnapshot {
                    userArray.append(listObject.key)
                }
            } else {print ("error")}
        }) { (error) in
            print(error.localizedDescription)
        }
        return userArray
    }*/
    
    func deletePerson(_ pN: NSString){
        //personDictionary=
        //print(email)
        //saveEmailName(email)
        var arr = email.components(separatedBy: ".")
        print(arr[0])
        email = arr[0] as NSString
        ref.child(email as String).child(groupName as String).child(pN as String).removeValue() { error in
            if error != nil {
                print("error \(error)")
            }
        }
        print("deletion attempted")
    }
    
    func deleteGroup(){
        
    }
    
    func savePersonName(_ personName: NSString){
        personNames.append(personName)
    }
    
    func savePersonFace(_ personFace: UIImage){ //use firebase storage to save images
        faces.append(personFace)
        //print ("each face \(faces)")
        //print ("hey\(faces)")
    }
    func saveURL(_ url : String){
        
    }
    func clearPersonFaces(_ personName: NSString){
        let imageName = NSUUID().uuidString
        let storageRef=Storage.storage().reference().child("\(imageName).png") // I am not sure if this creates another storage ref
        var urls: [String] = []
        var count: Int = 0;
        var temp: Int = 0;
        temp = faces.count
        for (image) in faces {
            if let uploadData = UIImagePNGRepresentation(image){
                storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    if (error != nil) {
                        print(error)
                        return
                    }
                    //print(metadata)
                    count = count + 1;
                    if let imageURL = metadata?.downloadURL()?.absoluteString {
                        urls.append(imageURL)
                        self.personDictionary[personName] = urls
                        //print ("AfterSaved\(self.personDictionary[personName]!)")
                        
                    }
                    print("\(count)","\(temp)")
                    if (count == temp){
                        print("before ssvae done")
                        self.ssave();
                        print("after ssvae done")
                    }
                }) //WHAT THE FREAK IS METADATA?????????
            }
        }
        faces=[]
    }

}



//self.ref.child("Group").setValue("Name", [groupNames[0])//"Person" : personNames[0]])

//self.ref.child(groupName as String)

//self.ref.child("Group").setValue(["GroupName": groupNames[0], "Person" : personNames[0]]) //creates group/groupname reference and assigns groupname value
//self.ref.child("Group").child("GroupName").child("People").child("PersonName").setValue(personNames[0]) //rewrites a new group/groupName/People/PersonName refererence with value over the original group/groupname reference from the line above, so the original reference obsolete (thus groupName doesn't save)- find out how to add info and access existing info instead of rewriting info
