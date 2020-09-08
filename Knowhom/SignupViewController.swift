//
//  SignupViewController.swift
//  Project
//
//  Created by MIS@NSYSU on 2020/5/6.
//  Copyright © 2020年 huihuiteam. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore

let db = Firestore.firestore()

class SignupViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    @IBOutlet weak var phoneNumberinput: UITextField!
    @IBOutlet weak var emailinput: UITextField!
    @IBOutlet weak var passwordinput: UITextField!
    @IBOutlet weak var usernameinput: UITextField!
    @IBOutlet weak var signupbtm: UIButton!
    @IBOutlet weak var takephotobtm: UIButton!
    
    var imagepicker = UIImagePickerController()
    var uniqueName = UUID().uuidString
    var selectedimage: UIImage!
    
    var urlString: String!

    var index: Int!
    var docList:Array<String> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagepicker.delegate = self

        phoneNumberinput.delegate = self
        emailinput.delegate = self
        passwordinput.delegate = self
        usernameinput.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        self.view.addGestureRecognizer(tap)
    }
    
    @IBAction func opencamera(_ sender: Any) {
        
        if selectedimage == nil{
            let controller = UIAlertController(title: "請注意", message:"請拍攝清楚的正面照", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "好", style: .default){ (_) in
                self.imagepicker.sourceType = .camera
                self.imagepicker.cameraDevice = UIImagePickerController.CameraDevice.front
                self.present(self.imagepicker, animated: true, completion: nil)
            }
            controller.addAction(yesAction)
            present(controller, animated: true, completion: nil)
        }
        else{
            let controller = UIAlertController(title: "Error", message:"要重新拍攝嗎？", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: .default){ (_) in
                self.imagepicker.sourceType = .camera
                self.imagepicker.cameraDevice = UIImagePickerController.CameraDevice.front
                self.present(self.imagepicker, animated: true, completion: nil)
            }
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            controller.addAction(cancelAction)
            controller.addAction(yesAction)
            present(controller, animated: true, completion: nil)
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage]
        selectedimage = image as! UIImage
        let imageToUpload = selectedimage?.jpegData(compressionQuality: 0.1)
        
        let imageReference = Storage.storage().reference().child("userphoto").child("\(uniqueName).jpg")
        
        imageReference.putData(imageToUpload!, metadata: nil){ (metadata, error) in
            if let error = error{
                print(error.localizedDescription)
                return
            }
            imageReference.downloadURL(completion: { (url, error) in
                if let error = error{
                    print(error.localizedDescription)
                    return
                }
                guard let url = url else{
                    print("Wrong")
                    return
                }
                self.urlString = url.absoluteString
                print(self.urlString)
            })
        }
        imagepicker.dismiss(animated: true, completion: nil)
    }
    
    @objc func dismissKeyBoard(){
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
//    func isPasswordValid(_ Password : String) -> Bool{
//        let Password = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[A-Z](?=.*[0-9].{>8}$")
//        return Password.evaluate(with: Password)
//    }
    
    // check the fields and validate that the data is correct.
    //If is correct, it return nil.If not, return the error message
    func validateFields() -> String? {
        
        //check is empty
        if phoneNumberinput.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || emailinput.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordinput.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || usernameinput.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            return "請填寫所有資料"
            
        }
        if selectedimage == nil{
            return "請拍攝照片"
        }
        //check is password secure
//        let cleanedPassword = passwordinput.text!.trimmingCharacters(in: .whitespacesAndNewlines)
//
//        if isPasswordValid(cleanedPassword) == false{
//            //password isn't secure
//            return "Your password is not secure.Please make sure your password is at least 8 characters, contains a special character and a number"
//        }
        
        return nil
    }

    func showerror(_ message:String){
        let controller = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        controller.addAction(okAction)
        present(controller, animated: true, completion: nil)
    }
    

    
    @IBAction func signbutton(_ sender: Any) {

        //validate the fields
        let error = validateFields()
  
        let email = emailinput.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let phonenumber = phoneNumberinput.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordinput.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let username = usernameinput.text!.trimmingCharacters(in: .whitespacesAndNewlines)
    
        if error != nil {
            showerror(error!)
        }
        
        else{
            //create the user
            Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
                //check error
                if err != nil{
                    //an error
                    print(err!.localizedDescription)
                    self.showerror("error creating user")
                }
                else{
                    //create successfully
                 
                    
                    db.collection("user").document(result!.user.uid).collection("account").addDocument(data: ["uid":result!.user.uid,"username":username,"phone":phonenumber, "email": email,"photo": self.urlString,"CreationDate":Auth.auth().currentUser?.metadata.creationDate as Any]){
                    (error) in
                        if error != nil{
                           self.showerror("error!!!!!!!!!")
                        }
                    }
                db.collection("alluserdata").document(result!.user.uid).setData(["uid":result!.user.uid,"username":username,"phone":phonenumber, "email": email,"photo": self.urlString,"CreationDate":Auth.auth().currentUser?.metadata.creationDate as Any], merge: true)
                    //Go to the HomeViewController if the login is sucessful
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "home")
                    self.present(vc!, animated: true, completion: nil)

 
                }
            }
        }
        
        
    }
}
