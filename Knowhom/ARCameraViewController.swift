//
//  ARCameraViewController.swift
//  Knowhom
//
//  Created by MIS@NSYSU on 2020/9/17.
//  Copyright © 2020年 knowhom. All rights reserved.
//

import UIKit
import ARKit

@available(iOS 11.0, *)
class ARCameraViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    override func viewDidLoad() {
        super.viewDidLoad()
        addBox()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        sceneView.session.pause()
        
    }
    
    func addBox() {
        
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        
        let boxNode = SCNNode()
        boxNode.geometry = box
        boxNode.position = SCNVector3(0, 0, -0.2)
        
        let scene = SCNScene()
        scene.rootNode.addChildNode(boxNode)
        sceneView.scene = scene
        
    }
}
