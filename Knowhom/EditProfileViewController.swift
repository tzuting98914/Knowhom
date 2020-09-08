//
//  EditProfileViewController.swift
//  Knowhom
//
//  Created by MIS@NSYSU on 2020/8/27.
//  Copyright © 2020年 knowhom. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore

class EditProfileViewController: UIViewController {
    var dataTask: URLSessionDataTask?
    var userData = UserDefaults.standard.dictionary(forKey: "userData")
    var fireUploadDic: [String:Any]?
    
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var changePhotoBtn: UIButton!
    @IBOutlet weak var editTable: UITableView!
    
    var typelist:[String] = ["username","email","phone number","position"]
    var profileList:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(CancelEdit))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Finish", style: .done, target: self, action: #selector(FinishEdit))
        readData()
        // Do any additional setup after loading the view.
    }
    
    func readData(){
        let userID = Auth.auth().currentUser?.uid
        db.collection("user").document(userID!).collection("account").getDocuments { (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                for document in querySnapshot.documents {
                    self.profileList.append(document.data()["username"] as! String)
                    self.profileList.append(document.data()["email"] as! String)
                    self.profileList.append(document.data()["phone"] as! String)
                    self.setPhoto(document.data()["photo"] as! String)
                    //self.userPhoto.image = UIImage(data: document.data()["photo"] as! Data)
                    print(self.profileList)
                }
                DispatchQueue.main.async {
                    self.editTable.reloadData()
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
    @objc func FinishEdit(){
        //儲存資料，並回到上一頁
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

extension EditProfileViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profileList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "editcell", for: indexPath) as? EditProfileTableViewCell
        cell?.type.text = "sss"
        cell?.nameField.text = profileList[indexPath.row]
        return cell!
    }
}
