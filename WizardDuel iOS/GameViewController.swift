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
import Firebase

class GameViewController: UIViewController {
    
    weak var delegate: ViewControllerDelegate?
    @IBOutlet var skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseApp.configure()
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
    
    @IBAction func importItem(sender: UIBarButtonItem) {
        
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
                let pinchGR = UIPinchGestureRecognizer(target: self, action: #selector(pinch))
                
                view.addGestureRecognizer(tapGR)
                view.addGestureRecognizer(doubleTapGR)
                view.addGestureRecognizer(longPressGR)
                view.addGestureRecognizer(pinchGR)
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
            scene.doubleTap(by: sender)
        }
    
    //Used on IOS to view cards. Long press puts the user into viewing mode and then touch moves changes the currently viewed card.
    @objc func longPress(sender: UILongPressGestureRecognizer) {
        let scene = self.delegate as! GameScene
        scene.longPress(sender: sender)
    }
    
    @objc func pinch(sender: UIPinchGestureRecognizer) {
        let scene = self.delegate as! GameScene
        scene.pinch(sender: sender)
    }
    
    private func newGame(gameScene: GameScene) -> Bool {
        let navigationVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "newPlayerNavigationController") as! UINavigationController
           let viewController =  navigationVC.topViewController as! PlayerDetailsViewController
        navigationVC.modalPresentationStyle = .formSheet
        let scene = self.delegate as! GameScene
        viewController.gameScene = scene
        self.present(navigationVC, animated: true, completion: nil)
        
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
