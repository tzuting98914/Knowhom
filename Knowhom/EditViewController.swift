//
//  EditViewController.swift
//  Knowhom
//
//  Created by MIS@NSYSU on 2020/8/29.
//  Copyright © 2020年 knowhom. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore

let userID = Auth.auth().currentUser?.uid

class EditViewController: UIViewController, UITextFieldDelegate , UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var dataTask: URLSessionDataTask?
    var userData = UserDefaults.standard.dictionary(forKey: "userData")
    var fireUploadDic: [String:Any]?
    var imagepicker = UIImagePickerController()
    var profileList:[String] = []
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    
    var docID = ""
    var selectedimage: UIImage!
    var uniqueName = UUID().uuidString
    var urlString: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameField.delegate = self
        emailField.delegate = self
        phoneField.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        self.view.addGestureRecognizer(tap)
        
        imagepicker.delegate = self
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(CancelEdit))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Finish", style: .done, target: self, action: #selector(FinishEdit))
        readData()
        // Do any additional setup after loading the view.
    }
    // 收鍵盤
    @objc func dismissKeyBoard(){
        self.view.endEditing(true)
    }
    
    // 按Return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
    // 按空白處
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func changePhoto(_ sender: Any) {
        let controller = UIAlertController(title: "請注意", message:"請拍攝清楚的正面照", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "好", style: .default){ (_) in
            self.imagepicker.sourceType = .camera
            self.imagepicker.cameraDevice = UIImagePickerController.CameraDevice.front
            self.present(self.imagepicker, animated: true, completion: nil)
        }
        controller.addAction(yesAction)
        present(controller, animated: true, completion: nil)
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage]
        selectedimage = image as! UIImage
        let imageToUpload = selectedimage?.jpegData(compressionQuality: 0.1)
        
        let imageReference = Storage.storage().reference().child("userphoto").child(userID!).child("\(uniqueName).jpg")
        
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
                db.collection("user").document(userID!).collection("account").document().updateData(["photo": self.urlString])
                db.collection("alluserdata").document(userID!).updateData(["photo": self.urlString])
                self.setPhoto(self.urlString)
            })
        }
        imagepicker.dismiss(animated: true, completion: nil)
    }
    
    func readData(){
        
        db.collection("user").document(userID!).collection("account").getDocuments { (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                for document in querySnapshot.documents {
                    self.nameField.text = document.data()["username"] as? String
                    self.emailField.text = document.data()["email"] as? String
                    self.phoneField.text = document.data()["phone"] as? String
                    self.setPhoto(document.data()["photo"] as! String)
                    self.docID = document.documentID
                }
            }
            else{
                print("not exist")
            }
        }
    }
    
    func setPhoto(_ userImageURL: String) {
        if userImageURL != "none" {
            let session = URLSession.shared
            dataTask = session.dataTask(with: URL(string: userImageURL)!, completionHandler: {
                (data, response, error) in
                if let error = error {
                    print("\(error.localizedDescription)")
                    return
                } else if let httpResponse = response as? HTTPURLResponse {
                    // storage 的權限如果沒有打開的話，會出現 403 的錯誤
                    if httpResponse.statusCode == 200 {
                        DispatchQueue.main.async() {
                            if let data = data {
                                self.photo.image = UIImage(data: data)
                            }
                        }
                    }
                }
            })
        }
        dataTask?.resume()
    }
    
    @objc func FinishEdit(){
        //儲存資料，並回到上一頁
        let usernameInput = nameField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let emailInput = emailField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let phoneInput = phoneField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
    db.collection("user").document(userID!).collection("account").document(docID).updateData(["username":usernameInput,"phone":phoneInput, "email": emailInput])
        
        db.collection("alluserdata").document(userID!).updateData(["username":usernameInput,"phone":phoneInput, "email": emailInput])
        
        self.navigationController?.popViewController(animated: true)
        
        print("Yesss")
        
    }
    
    @objc func CancelEdit(){
        print("Done!")
        //確認要放棄編輯嗎
        let controller = UIAlertController(title: "取消編輯", message: "確定要捨棄更動嗎？", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "確定", style: .default){ (_) in
            self.navigationController?.popViewController(animated: true)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        controller.addAction(cancelAction)
        controller.addAction(yesAction)
        present(controller, animated: true, completion: nil)
    }
   
}
