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
    var photoList:[String] = []
    var uidList:[String] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        readData()
        documentId = []
        nameList = []
        idList = []
        photoList = []
    }
    
   
    
    func readData(){
        let userID = Auth.auth().currentUser?.uid
        db.collection("user").document(userID!).collection("contact").order(by: "uid", descending: true).getDocuments { (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                for document in querySnapshot.documents {
                    self.documentId.append(document.documentID)
                    self.idList.append(document.data()["uid"] as! String)
                }
                let max = self.idList.count
                var i = max - 1
                while(i >= 0){
                    db.collection("alluserdata").document(self.idList[i]).getDocument { (document, error) in
                        if let document = document, document.exists {
                            self.uidList.append(document.data()?["uid"] as! String)
                            self.nameList.append(document.data()?["username"] as! String)
                            self.photoList.append(document.data()?["photo"] as! String)
//                            print(self.uidList)
//                            print(self.nameList)
//                            print(self.photoList)
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        } else {
                            print("Document does not exist")
                        }
                    }
                    i -= 1
                }
                
            }
        }
    }
}


extension AddressViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return idList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addresscell", for: indexPath) as? CellTableViewCell
        //cell?.lbl.text = "111"
        cell?.lbl.text = nameList[indexPath.row]
        cell?.setPhoto(photoList[indexPath.row])
        
        return cell!
    }
    
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //        if let controller = segue.destination as? AddressDetailViewController, let _ = tableView.indexPathForSelectedRow?.section, let row = tableView.indexPathForSelectedRow?.row {
    //            controller.id = idList[row]
    //        }
    //    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "transfer", sender: uidList[indexPath.row])
        
        //        let vc = storyboard?.instantiateViewController(withIdentifier: "AddressDetailViewController") as? AddressDetailViewController
        //        vc!.id = idList[indexPath.row]
        //        navigationController?.pushViewController(vc!, animated: true)
        //
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let svc = segue.destination as! AddressDetailViewController
        svc.id = sender as? String
    }
    
}
