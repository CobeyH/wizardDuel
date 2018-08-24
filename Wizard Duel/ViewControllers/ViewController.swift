//
//  ViewController.swift
//  Freegraveyard2
//
//  Created by gary on 16/06/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

import Cocoa
import SpriteKit
import GameplayKit
import FirebaseDatabase

class ViewController: NSViewController {

    weak var delegate: ViewControllerDelegate?
    @IBOutlet var skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureScene()
        
    }
    
    

    
    // MARK: - Actions

    @IBAction func showStatistics(_ sender: NSMenuItem) {
        let mainStoryboard = NSStoryboard.Name("Main")
        let statisticsWindow = NSStoryboard.SceneIdentifier("StatisticsWindowController")
        let storyboard = NSStoryboard(name: mainStoryboard, bundle: nil)
        guard
            let statisticsWindowController = storyboard.instantiateController(withIdentifier: statisticsWindow) as? NSWindowController,
            let window = statisticsWindowController.window
        else {
            return
        }
        let application = NSApplication.shared
        application.runModal(for: window)
    }

    @IBAction func newGame(_ sender: NSMenuItem) {
        if newGame() {
            guard let delegate = delegate else { return }
            
            delegate.newGame()
        }
    }
    
    @IBAction func importDeck(_ sender: NSMenuItem) {
        let URL = Card.deck()
            if let URL = URL {
            let deckRef = Database.database().reference().child("Decks").childByAutoId()
            let cardTouple = Card.cardsFromFile(url: URL)
            deckRef.child("name").setValue(URL.lastPathComponent)
            for card in cardTouple.0 {
                deckRef.child("Cards").childByAutoId().setValue(["card": String(card.name)])
            }
            if cardTouple.1 != "nil" {
                deckRef.child("Commander").setValue(cardTouple.1)
            }
        }
    }

    // MARK: - Private
    private func configureScene() {
        if let view = self.skView {
            let mainScreen = NSScreen.main
            var screenFrame = mainScreen!.visibleFrame
            screenFrame.size.height += 30
            view.frame = screenFrame
            ;
            if let scene = SKScene(fileNamed: "GameScene") as? GameScene {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFit
                scene.viewDelegate = self
                view.presentScene(scene)
                delegate = scene
                
                
                let doubleTapGR = NSClickGestureRecognizer(target: self, action: #selector(doubleTap))
                doubleTapGR.numberOfClicksRequired = 2
                let tapGR = NSClickGestureRecognizer(target: self, action: #selector(tap))
                
                tapGR.canBePrevented(by: doubleTapGR)
                view.addGestureRecognizer(tapGR)
                view.addGestureRecognizer(doubleTapGR)
            }
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    @objc func tap(sender: NSClickGestureRecognizer) {
        let scene = self.delegate as! GameScene
        scene.tap(sender: sender)
    }
    
    @objc func doubleTap(sender: NSClickGestureRecognizer) {
        let scene = self.delegate as! GameScene
        
        scene.doubleTap(sender: sender)
    }

    private func newGame() -> Bool {
        let alert = NSAlert()
        alert.alertStyle = .informational
        alert.messageText = "New Game?"
        alert.informativeText = "Do you want to start a new game?"
        alert.addButton(withTitle: "Yes")
        alert.addButton(withTitle: "No")
        let textField = NSTextField(frame:NSMakeRect(0,0,200,20))
        let defaultName = UserDefaults.standard.string(forKey: "PlayerName")
        if let defaultName = defaultName {
            textField.stringValue = defaultName
        }
        textField.placeholderString = "Player Name"
        alert.accessoryView = textField
        switch alert.runModal() {
        case .alertFirstButtonReturn:
            let newName = textField.stringValue
            if newName.count > 0 {
                UserDefaults.standard.set(newName, forKey: "PlayerName")
            }
            return true
        default: return false
        }
    }
}

// MARK: - GameSceneDelegate

extension ViewController: GameSceneDelegate {
    func importDeck() {
        print("importing deck")
    }
    
    
    func newGame(currentGameState: Game.State, gameScene: GameScene) -> Bool {
        if newGame() {
            
            return true
       
        }
        return false
    }


    
}
