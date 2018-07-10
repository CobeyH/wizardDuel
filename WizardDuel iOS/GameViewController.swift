//
//  GameViewController.swift
//  WizardDuel iOS
//
//  Created by Adrian Ruigrok on 2018-07-02.
//  Copyright © 2018 Gary Kerr. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    weak var delegate: ViewControllerDelegate?
    @IBOutlet var skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureScene()
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private func configureScene() {
        let skView = view as! SKView

            var screenFrame = UIScreen.main.bounds
            screenFrame.size.height += 30
            view.frame = screenFrame
            
            if let scene = SKScene(fileNamed: "GameScene") as? GameScene {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFit
                scene.viewDelegate = self
                skView.presentScene(scene)
                delegate = scene
                
                let doubleTapGR = UITapGestureRecognizer(target: self, action: #selector(doubleTap))
                doubleTapGR.numberOfTapsRequired = 2
                let tapGR = UITapGestureRecognizer(target: self, action: #selector(tap))
                let longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(longPress))

                view.addGestureRecognizer(tapGR)
                view.addGestureRecognizer(doubleTapGR)
                view.addGestureRecognizer(longPressGR)
            }
            skView.ignoresSiblingOrder = true
            skView.showsFPS = true
            skView.showsNodeCount = true
        }
    
        @objc func tap(sender: UITapGestureRecognizer) {
            let scene = self.delegate as! GameScene
            scene.tap(sender: sender)
        }
    
        @objc func doubleTap(sender: UITapGestureRecognizer) {
            let scene = self.delegate as! GameScene
    
            scene.doubleTap(sender: sender)
        }
    
    @objc func longPress(sender: UILongPressGestureRecognizer) {
        let scene = self.delegate as! GameScene
        scene.longPress(sender: sender)
        
    }
    

    
    private func newGame(gameScene: GameScene) -> Bool {
        // create the alert
        let alertController = UIAlertController(title: "Add New Name", message: "", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { alert -> Void in
            let textField = alertController.textFields![0] as UITextField
            print(textField.text ?? "")
            let newName = textField.text
            if newName!.count > 0 {
                UserDefaults.standard.set(newName, forKey: "PlayerName")
            }
            gameScene.newGame()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (action : UIAlertAction!) -> Void in })
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter First Name"
        }
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
        return false
    }
    
}

extension GameViewController: GameSceneDelegate {
    
    func newGame(currentGameState: Game.State, gameScene: GameScene) -> Bool {
        if newGame(gameScene: gameScene) {
            return true
        }
        return false
    }
}
