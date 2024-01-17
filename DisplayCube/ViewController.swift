//
//  ViewController.swift
//  DisplayCube
//
//  Created by Robin Konijnendijk on 16/01/2024.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    var dotNodes = [SCNNode]()
    var width = ""
    var height = ""
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Set the scene to the view
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        sceneView.scene = SCNScene()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .vertical
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if dotNodes.count >= 3 {
            for dot in dotNodes {
                dot.removeFromParentNode()
            }
            dotNodes = [SCNNode]()
        }
        
        guard let location = touches.first?.location(in: sceneView) else {
            print("No location found")
            return
        }
        
        guard let query = sceneView.raycastQuery(from: location, allowing: .estimatedPlane, alignment: .vertical) else {
            print("No query found")
            return
        }
        
        if let result = sceneView.session.raycast(query).first {
            let position = SCNVector3(result.worldTransform.columns.3.x, result.worldTransform.columns.3.y, result.worldTransform.columns.3.z)
            print("Position: \(position)")
            addDots(at: position)
        } else {
            print("No result found")
            return
        }
        
    }
    
    func addDots(at position: SCNVector3) {
        let dotGeometry = SCNSphere(radius: 0.010)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        dotGeometry.materials = [material]
        
        let dotNode = SCNNode(geometry: dotGeometry)
        dotNode.position = position
        
        dotNodes.append(dotNode)
        sceneView.scene.rootNode.addChildNode(dotNode)
        
        if dotNodes.count >= 3 {
            distanceDots()
        }
    }
    

    func distanceDots() {
            let start = dotNodes[0].position
            let middle = dotNodes[1].position
            let end = dotNodes[2].position

            let widthDistance = distanceBetween(first: start, second: middle)
            let heightDistance = distanceBetween(first: middle, second: end)

            let widthCG = CGFloat(widthDistance) / 100.0 // Convert to meters
            let heightCG = CGFloat(heightDistance) / 100.0 // Convert to meters

            // Calculate the position for the cube
            let cubeX = (start.x + middle.x) / 2
            let cubeY = (middle.y + end.y) / 2
            let cubeZ = (start.z + middle.z + end.z) / 3
            let cubePosition = SCNVector3(cubeX, cubeY, cubeZ)

            addCube(width: widthCG, height: heightCG, position: cubePosition)
        }
    
    
    func distanceBetween(first: SCNVector3, second: SCNVector3) -> Float {
        let distance = sqrt(
            pow(second.x - first.x, 2) +
            pow(second.y - first.y, 2) +
            pow(second.z - first.z, 2)
        )
        return distance * 100
    }
    
    func addCube(width: CGFloat, height: CGFloat, position: SCNVector3) {
            let boxGeometry = SCNBox(width: width, height: height, length: 0.06, chamferRadius: 0)
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.red
            boxGeometry.materials = [material]

            let boxNode = SCNNode(geometry: boxGeometry)
            boxNode.position = position

            boxNode.eulerAngles = SCNVector3(0, 0, 0) // Modify if needed to align with dots

            sceneView.scene.rootNode.addChildNode(boxNode)
        }
    
    
}


