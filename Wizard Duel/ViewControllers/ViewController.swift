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

class ViewController: NSViewController {

    var statisticsStore: StatisticsStore!
    var statistics: Statistics!
    weak var delegate: ViewControllerDelegate?
    @IBOutlet var skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureScene()
        configureStatistics()
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
            if delegate.gameState == .playing { updateStatistics(with: .playing) }
            delegate.newGame()
        }
    }

    // MARK: - Private

    private func configureScene() {
        if let view = self.skView {
            let mainScreen = NSScreen.main
            var screenFrame = mainScreen!.visibleFrame
            screenFrame.size.height += 30
            view.frame = screenFrame
            
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

    private func configureStatistics() {
        let userDefaults = UserDefaults.standard
        statisticsStore = StatisticsStore(userDefaults: userDefaults)
        statistics = statisticsStore.load()
    }

    private func newGame() -> Bool {
        let alert = NSAlert()
        alert.alertStyle = .informational
        alert.messageText = "New Game?"
        alert.informativeText = "Do you want to start a new game?"
        alert.addButton(withTitle: "Yes")
        alert.addButton(withTitle: "No")
        switch alert.runModal() {
        case .alertFirstButtonReturn: return true
        default: return false
        }
    }
}

// MARK: - GameSceneDelegate

extension ViewController: GameSceneDelegate {
    func newGame(currentGameState: Game.State) -> Bool {
        if newGame() {
            if currentGameState == .playing { updateStatistics(with: .playing) }
            return true
        } else {
            return false
        }
    }


    func gameDone() {
        updateStatistics(with: .done)
    }


    private func updateStatistics(with gameState: Game.State) {
        statistics.update(with: gameState)
        statisticsStore.save(statistics: statistics)
    }
}
