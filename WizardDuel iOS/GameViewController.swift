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
                
                //                let doubleTapGR = NSClickGestureRecognizer(target: self, action: #selector(doubleTap))
                //                doubleTapGR.numberOfClicksRequired = 2
                //                let tapGR = NSClickGestureRecognizer(target: self, action: #selector(tap))
                
                //                tapGR.canBePrevented(by: doubleTapGR)
                //                view.addGestureRecognizer(tapGR)
                //                view.addGestureRecognizer(doubleTapGR)
            }
            skView.ignoresSiblingOrder = true
            skView.showsFPS = true
            skView.showsNodeCount = true
        }
    
    //    @objc func tap(sender: NSClickGestureRecognizer) {
    //        let scene = self.delegate as! GameScene
    //        scene.tap(sender: sender)
    //    }
    
    //    @objc func doubleTap(sender: NSClickGestureRecognizer) {
    //        let scene = self.delegate as! GameScene
    //
    //        scene.doubleTap(sender: sender)
    //    }
    
    private func newGame() -> Bool {
        //        let alert = NSAlert()
        //        alert.alertStyle = .informational
        //        alert.messageText = "New Game?"
        //        alert.informativeText = "Do you want to start a new game?"
        //        alert.addButton(withTitle: "Yes")
        //        alert.addButton(withTitle: "No")
        //        let textField = NSTextField(frame:NSMakeRect(0,0,200,20))
        //        let defaultName = UserDefaults.standard.string(forKey: "PlayerName")
        //        if let defaultName = defaultName {
        //            textField.stringValue = defaultName
        //        }
        //        textField.placeholderString = "Player Name"
        //        alert.accessoryView = textField
        //        switch alert.runModal() {
        //        case .alertFirstButtonReturn:
        //            let newName = textField.stringValue
        //            if newName.count > 0 {
        //                UserDefaults.standard.set(newName, forKey: "PlayerName")
        //            }
        return true
        //        default: return false
        //        }
    }
}

extension GameViewController: GameSceneDelegate {
    
    func newGame(currentGameState: Game.State) -> Bool {
        if newGame() {
            
            return true
            
        }
        return false
    }
}
