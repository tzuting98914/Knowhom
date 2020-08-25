//
//  AddressViewController.swift
//  Project
//
//  Created by MIS@NSYSU on 2020/7/17.
//  Copyright © 2020年 huihuiteam. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase
import FirebaseAuth
import FirebaseFirestore



class AddressViewController: UIViewController{
   
    var documentId:[String] = []
    var nameList:[String] = []
    var idList:[String] = []
    var i = 0
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menubutton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        readData()
    }
    

    func readData(){
        let userID = Auth.auth().currentUser?.uid
        db.collection("user").document(userID!).collection("contact").getDocuments { (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                for document in querySnapshot.documents {
                    self.documentId.append(document.documentID)
                    self.idList.append(document.data()["uid"] as! String)
                    print("\(self.idList)123")
                }
                print(self.idList)
                
                

                
//                for i in 0..<self.documentId.count{
//
//                    print("\(self.idList[self.i]):\(self.i)...456")
//
//                    db.collection("user").document(self.idList[self.i]).collection("account").getDocuments { (querySnapshot, error) in
//                        if let querySnapshot = querySnapshot {
//                            for document in querySnapshot.documents {
//                                self.nameList.append(document.data()["username"] as! String)
//                                print(document.data()["username"] as! String)
//                                self.tableView.reloadData()
//
//                            }
//
//                        }
//
//                    }
//                    self.i = self.i + 1
//                }
                
            }
            for i in 0..<self.documentId.count{
                
                print("\(self.idList[self.i]):\(self.i)...456")
                
                db.collection("alluserdata").document(self.idList[self.i]).getDocument { (document, error) in
                    if let document = document, document.exists {
                        self.nameList.append(document.data()?["username"] as! String)
                        print(self.nameList)
                        //print(document.documentID, document.data())
                    } else {
                        print("Document does not exist")
                    }
                }
                self.i = self.i + 1
            }
            print(self.idList)
        }
        print(self.idList)
    }

}


extension AddressViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documentId.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addresscell", for: indexPath) as? CellTableViewCell
        //cell?.lbl.text = "111"
        //cell?.lbl.text = nameList[indexPath.row]
        
//        cell?.img.image = UIImage(named: username[indexPath.row])
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
//        performSegue(withIdentifier: "AddressDetailViewController", sender: self)
        let vc = storyboard?.instantiateViewController(withIdentifier: "AddressDetailViewController") as? AddressDetailViewController
        vc?.id = idList[indexPath.row]
        self.navigationController?.pushViewController(vc!, animated: true)
    }

}
