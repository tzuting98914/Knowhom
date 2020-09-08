//
//  CameraViewController.swift
//  Project
//
//  Created by MIS@NSYSU on 2020/5/6.
//  Copyright © 2020年 huihuiteam. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore

@available(iOS 10.0, *)

class CameraViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var dataTask: URLSessionDataTask?
    var userData = UserDefaults.standard.dictionary(forKey: "userData")
    var fireUploadDic: [String:Any]?
    
    @IBOutlet weak var camera: UIView!
    @IBOutlet weak var front: UIButton!
    @IBOutlet weak var flash: UIButton!
    
    @IBOutlet weak var outputText: UILabel!
    @IBOutlet weak var addFriend: UIButton!
    @IBOutlet var addFriendView: UIView!
    @IBOutlet weak var friendphoto: UIImageView!
    @IBOutlet weak var cancelbtn: UIButton!
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
    var backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
    var qrCodeFrameView: UIView?
    var getqr = ""
    var addid = ""
    var addname = ""
    var addemail = ""
    var addphoto = ""
    var addphone = ""
    var contactId:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        print(Auth.auth().currentUser?.uid)
        if #available(iOS 12.1, *){
            let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
            do{
                let input = try AVCaptureDeviceInput(device: captureDevice!)
                captureSession = AVCaptureSession()
                captureSession?.addInput(input)
                
                
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
                videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                videoPreviewLayer?.frame = view.layer.bounds
                camera.layer.addSublayer(videoPreviewLayer!)
                
                let output = AVCaptureMetadataOutput()
                captureSession?.addOutput(output)
                output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
                captureSession?.startRunning()
                
                qrCodeFrameView = UIView()
                
                if let qrCodeFrameView = qrCodeFrameView {
                    qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                    qrCodeFrameView.layer.borderWidth = 2
                    view.addSubview(qrCodeFrameView)
                    view.bringSubviewToFront(qrCodeFrameView)
                }
            }
            catch{
                print("error")
            }
        }
    }
    

    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // 檢查  metadataObjects 陣列為非空值，它至少需包含一個物件
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            outputText.text = "No QR code is detected"
            return
        }
        
        // 取得元資料（metadata）物件
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            // 倘若發現的元資料與 QR code 元資料相同，便更新狀態標籤的文字並設定邊界
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            getqr = metadataObj.stringValue as! String
            let id = NSString(string:getqr)
            addid = id.substring(from: 3)
            
            if getqr.hasPrefix("knowhom"){
                
                db.collection("alluserdata").document(addid).getDocument { (document, error) in
                    if let document = document, document.exists {
                        self.addphoto = document.data()?["photo"] as! String
                        self.setPhoto(self.addphoto)
                    }
                    else{
                        print("Document does not exist")
                    }
                }
                outputText.text = metadataObj.stringValue
                self.view.addSubview(addFriendView)
                addFriendView.center = self.view.center
            }
        }
    }
    
    @IBAction func add(_ sender: Any) {
        print("Good job!")
        let userID = Auth.auth().currentUser?.uid
        db.collection("user").document(userID!).collection("contact").addDocument(data: ["uid":addid]){
            (error) in
            if error != nil{
                print("No add QAQ")
            }
        }
        
        self.addFriendView.removeFromSuperview()
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.addFriendView.removeFromSuperview()
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
                                self.friendphoto.image = UIImage(data: data)
                            }
                        }
                    }
                }
            })
        }
        dataTask?.resume()
    }
    
    func switchToFrontCamera() {
        if frontCamera?.isConnected == true {
            captureSession?.stopRunning()
            let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
            do{
                let input = try AVCaptureDeviceInput(device:captureDevice!)
                captureSession = AVCaptureSession()
                captureSession?.addInput(input)
                videoPreviewLayer  = AVCaptureVideoPreviewLayer(session:captureSession!)
                videoPreviewLayer?.frame = view.layer.bounds
                camera.layer.addSublayer(videoPreviewLayer!)
                captureSession?.startRunning()
            }
            catch{
                print("erreor")
            }
        }
    }
    
    func switchToBackCamera() {
        if backCamera?.isConnected == true {
            captureSession?.stopRunning()
            let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
            do{
                let input = try AVCaptureDeviceInput(device:captureDevice!)
                captureSession = AVCaptureSession()
                captureSession?.addInput(input)
                videoPreviewLayer  = AVCaptureVideoPreviewLayer(session:captureSession!)
                videoPreviewLayer?.frame = view.layer.bounds
                camera.layer.addSublayer(videoPreviewLayer!)
                captureSession?.startRunning()
            }
            catch{
                print("erreor")
            }
        }
    }

    @IBAction func change(_ sender: Any) {
        guard let currentCameraInput:AVCaptureInput = captureSession?.inputs.first else{
            return
        }
        
        if let input = currentCameraInput as? AVCaptureDeviceInput{
            if input.device.position == .back{
                switchToFrontCamera()
            }
            if input.device.position == .front{
                switchToBackCamera()
            }
        }
    }
    
    @IBAction func flash(_ sender: Any) {
    }
}
