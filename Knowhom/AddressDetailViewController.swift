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
    var cellData: String?
    
    var id: String?
    var SelectedtList:[String] = []
    var typelist:[String] = ["username","email","phone number","position"]
    
    @IBOutlet weak var addressdetail: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        readData()
    }
    
    func readData(){
        
        db.collection("user").document(id!).collection("account").getDocuments { (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                for document in querySnapshot.documents {
                    self.SelectedtList.append(document.data()["username"] as! String)
                    self.SelectedtList.append(document.data()["email"] as! String)
                    self.SelectedtList.append(document.data()["phone"] as! String)
                    //print(self.SelectedtList)
                }
                DispatchQueue.main.async {
                    self.addressdetail.reloadData()
                }
            }else{
                print("not exist")
            }
        }
        
//        let userID = Auth.auth().currentUser?.uid
//    db.collection("user").document(userID!).collection("contact").document(id!).getDocument { (document, error) in
//            if let document = document, document.exists{
//                self.SelectedtList.append(document.data()!["username"] as! String)
//                self.SelectedtList.append(document.data()!["email"] as! String)
//                self.SelectedtList.append(document.data()!["phone"] as! String)
//                //print(self.SelectedtList)
//
//                DispatchQueue.main.async {
//                    self.addressdetail.reloadData()
//                }
//            }else{
//                print("not exist")
//            }
//        }
        
    }
}



extension AddressDetailViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SelectedtList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addressdetailcell", for: indexPath) as? AddressDetailTableViewCell
        cell?.value.text = SelectedtList[indexPath.row]
        cell?.type.text = typelist[indexPath.row]
        return cell!
    }
}
