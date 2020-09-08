//
//  AddressDetailViewController.swift
//  Project
//
//  Created by MIS@NSYSU on 2020/7/17.
//  Copyright © 2020年 huihuiteam. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore

class AddressDetailViewController: UIViewController {
    var dataTask: URLSessionDataTask?
    var userData = UserDefaults.standard.dictionary(forKey: "userData")
    var fireUploadDic: [String:Any]?
    
    @IBOutlet weak var photoImg: UIImageView!
  
    var id: String?
    var SelectedtList:[String] = []
    var typelist:[String] = ["username","email","phone number"]
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var phone: UILabel!
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        readData()
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
                                self.photoImg.image = UIImage(data: data)
                            }
                        }
                    }
                }
            })
        }
        dataTask?.resume()
    }
    
    func readData(){
        
        db.collection("alluserdata").document(id!).getDocument { (document, error) in
            if let document = document, document.exists {
                self.name.text = document.data()?["username"] as? String
                self.email.text = document.data()?["email"] as? String
                self.phone.text = document.data()?["phone"] as? String
                self.setPhoto(document.data()?["photo"] as! String)
                //print(document.documentID, document.data())
                
            } else {
                print("Document does not exist")
            }
        }
    }
    
    
}
