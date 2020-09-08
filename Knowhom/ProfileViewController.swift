//
//  ProfileViewController.swift
//  Knowhom
//
//  Created by MIS@NSYSU on 2020/8/25.
//  Copyright © 2020年 knowhom. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore

class ProfileViewController: UIViewController {
    var dataTask: URLSessionDataTask?
    var userData = UserDefaults.standard.dictionary(forKey: "userData")
    var fireUploadDic: [String:Any]?
    
   
    @IBOutlet weak var userPhoto: UIImageView!
    var profileList:[String] = []
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var phone: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        readData()

//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .done, target: self, action: #selector(editTapped))

        // Do any additional setup after loading the view.
    }
    
//    @objc func editTapped(){
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "editProfilePage")
//        self.navigationController?.pushViewController(EditViewController, animated: true)
//    }

    func readData(){
        let userID = Auth.auth().currentUser?.uid
        db.collection("user").document(userID!).collection("account").addSnapshotListener { (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                for document in querySnapshot.documents {
                    self.setPhoto(document.data()["photo"] as! String)
                    //self.userPhoto.image = UIImage(data: document.data()["photo"] as! Data)
                    self.name.text = document.data()["username"] as? String
                    self.email.text = document.data()["email"] as? String
                    self.phone.text = document.data()["phone"] as? String
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
                                self.userPhoto.image = UIImage(data: data)
                            }
                        }
                    }
                }
            })
        }
        dataTask?.resume()
    }
}
