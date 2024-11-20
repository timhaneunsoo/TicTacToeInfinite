//
//  GameViewController.swift
//  TicTacToeInfinite
//
//  Created by Tim Han on 11/20/24.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ensure the view is an SKView
        if let view = self.view as! SKView? {
            // Load the GameScene directly
            let scene = GameScene(size: CGSize(width: 390, height: 844)) // iPhone dimensions
            scene.scaleMode = .aspectFill
            view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
