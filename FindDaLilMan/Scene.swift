//
//  Scene.swift
//  FindDaLilMan
//
//  Created by phrank on 2/1/20.
//  Copyright © 2020 phrank. All rights reserved.
//

import SpriteKit
import ARKit

class Scene: SKScene {
    let ghostsLabel = SKLabelNode(text: "dapper little men")
    let numberOfGhostsLabel = SKLabelNode(text: "0")
    var creationTime : TimeInterval = 0
    let killSound = SKAction.playSoundFileNamed("neyo", waitForCompletion: false)
   
    var ghostCount = 0 {
        didSet {
             self.numberOfGhostsLabel.text = "\(ghostCount)"
           }
         }
    
    
    override func didMove(to view: SKView) {
        // Setup your scene here
        ghostsLabel.fontSize = 20
        ghostsLabel.fontName = "DevanagariSangamMN-Bold"
        ghostsLabel.color = .white
        ghostsLabel.position = CGPoint(x: 80, y: 50)
        addChild(ghostsLabel)

        numberOfGhostsLabel.fontSize = 30
        numberOfGhostsLabel.fontName = "DevanagariSangamMN-Bold"
        numberOfGhostsLabel.color = .white
        numberOfGhostsLabel.position = CGPoint(x: 80, y: 10)
        addChild(numberOfGhostsLabel)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if currentTime > creationTime {
          createManAnchor()
          creationTime = currentTime + TimeInterval(randomFloat(min: 3.0, max: 9.0))
        }
    }
    func randomFloat(min: Float, max: Float) -> Float {
         return (Float(arc4random()) / 0xFFFFFFFF) * (max - min) + min
       }
    func createManAnchor(){
      guard let sceneView = self.view as? ARSKView else {
        return
      }
        let _360degrees = 2.0 * Float.pi
        let rotateX = simd_float4x4(SCNMatrix4MakeRotation(_360degrees * randomFloat(min: 0.0, max: 1.0), 1, 0, 0))

        let rotateY = simd_float4x4(SCNMatrix4MakeRotation(_360degrees * randomFloat(min: 0.0, max: 1.0), 0, 1, 0))
        
        let rotation = simd_mul(rotateX, rotateY)
        
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -6 - randomFloat(min: 0.0, max: 1.0)
        
        let transform = simd_mul(rotation, translation)
        
        let anchor = ARAnchor(transform: transform)
        sceneView.session.add(anchor: anchor)
        
        ghostCount += 1


    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
          return
        }
         let location = touch.location(in: self)
         let hit = nodes(at: location)
        
        if let node = hit.first {
               if node.name == "lilman" {
                
                let fadeOut = SKAction.fadeOut(withDuration: 0.5)
                let remove = SKAction.removeFromParent()
                
                // Group the fade out and sound actions
                let groupKillingActions = SKAction.group([fadeOut, killSound])
                // Create an action sequence
                let sequenceAction = SKAction.sequence([groupKillingActions, remove])
                
                // Excecute the actions
                node.run(sequenceAction)
                node.run(killSound)
                // Update the counter
                ghostCount -= 1

               }
             }
    }
        
}
