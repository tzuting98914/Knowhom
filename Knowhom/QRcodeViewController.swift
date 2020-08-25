//
//  QRcodeViewController.swift
//  Project
//
//  Created by MIS@NSYSU on 2020/5/6.
//  Copyright © 2020年 huihuiteam. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class QRcodeViewController: UIViewController{

    var dataTask: URLSessionDataTask?
    var userData = UserDefaults.standard.dictionary(forKey: "userData")
    var fireUploadDic: [String:Any]?
    
    @IBOutlet weak var logout: UIButton!
    @IBOutlet weak var qrcodeimgview: UIImageView!
    var qrcodeImage: CIImage!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        generateQRcode()
        
    }
    
    //產生QR code
    func generateQRcode (){
        let userID = Auth.auth().currentUser?.uid
        if qrcodeImage == nil {
            
            if userID == "" {
                return
            }
            
            let qrdata = "abc\(userID!)"
            
            let data = qrdata.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
            
            let filter = CIFilter(name: "CIQRCodeGenerator")
            
            filter?.setValue(data, forKey: "inputMessage")
            filter?.setValue("Q", forKey: "inputCorrectionLevel")
            
            qrcodeImage = filter?.outputImage
            
            qrcodeimgview.image = UIImage(ciImage: qrcodeImage)
            displayQRCodeImage()
        }
    }
    // 顯示QR code
    func displayQRCodeImage() {
        let scaleX = qrcodeimgview.frame.size.width / qrcodeImage.extent.size.width
        let scaleY = qrcodeimgview.frame.size.height / qrcodeImage.extent.size.height
        
        let transformedImage = qrcodeImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        qrcodeimgview.image = UIImage(ciImage: transformedImage)
        
        
    }
    
        
//    func setPhoto(_ userImageURL: String) {
//        if userImageURL != "none" {
//            let session = URLSession.shared
//            dataTask = session.dataTask(with: URL(string: userImageURL)!, completionHandler: {
//                (data, response, error) in
//                if let error = error {
//                    print("\(error.localizedDescription)")
//                    return
//                } else if let httpResponse = response as? HTTPURLResponse {
//                    // storage 的權限如果沒有打開的話，會出現 403 的錯誤
//                    if httpResponse.statusCode == 200 {
//                        DispatchQueue.main.async() {
//                            if let data = data {
//                                self.qrcodeimgview.image = UIImage(data: data)
//                            }
//                        }
//                    }
//                }
//            })
//        }
//        dataTask?.resume()
//    }
    
    
    @IBAction func logoutaction(_ sender: Any) {
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
        let loginViewController = self.storyboard!.instantiateViewController(withIdentifier: "login")
        UIApplication.shared.keyWindow?.rootViewController = loginViewController
    }
    }
