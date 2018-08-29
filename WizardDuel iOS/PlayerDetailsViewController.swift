//
//  PlayerDetailsViewController.swift
//  WizardDuel iOS
//
//  Created by Cobey Hollier on 2018-08-24.
//  Copyright © 2018 Gary Kerr. All rights reserved.
//

import UIKit
import Firebase

class PlayerDetailsViewController: UITableViewController {
    var deckNames: [DataSnapshot] = []
    var gameScene: GameScene?
    
    @IBAction func done(_ sender: Any) {
        let selectedIndexPath = tableView.indexPathsForSelectedRows?.first
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! PlayerNameCell
        let newName = cell.playerNameField.text
        UserDefaults.standard.set(newName, forKey: "PlayerName")
        if let row = selectedIndexPath?.row {
            newDeck(with: deckNames[row])
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func newDeck(with deck: DataSnapshot) {
        var stringArray = [String]()
        let dictionary = deck.value as? Dictionary<String, AnyObject>
        let cards = dictionary!["Cards"] as! Dictionary<String, AnyObject>
        for card in cards.values {
            let cardDictionary = card as! Dictionary<String, AnyObject>
            let cardName = cardDictionary["Name"]! as! String
            print(cardName)
            stringArray.append(cardName)
        }
        let touple = Card.parseDeck(strings: stringArray)
        gameScene?.game.newDeck(deckTouple: touple)
        gameScene?.newGame()
    }
    
    override func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 1
    }
  
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        Database.database().reference().child("Decks").observeSingleEvent(of: .value, with: { snapshot in
            for deck in snapshot.children {
                let snap = deck as! DataSnapshot
                self.deckNames.append(snap)
            }
            self.tableView.reloadData()
            if self.tableView.numberOfRows(inSection: 1) > 0 {
                self.tableView.selectRow(at: IndexPath(item: 0, section: 1), animated: true, scrollPosition: .top)
            }
        })
    }

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return deckNames.count
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 { return nil }
        
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "playerName") as! PlayerNameCell
            let defaultName = UserDefaults.standard.string(forKey: "PlayerName")
            if let defaultName = defaultName {
                cell.playerNameField.text = defaultName
            }
            cell.selectionStyle = .none
            return cell
        }
        else {
            let cell: DeckCell = tableView.dequeueReusableCell(withIdentifier: "deckName") as! DeckCell
            let deckName = deckNames[indexPath.row].childSnapshot(forPath: "Name").value as! String
            cell.deckName.text = deckName
            cell.selectionStyle = .blue
            return cell
        }
    }
}

class PlayerNameCell: UITableViewCell {
    @IBOutlet weak var playerNameField: UITextField!
}

class DeckCell: UITableViewCell {
    @IBOutlet weak var deckName: UILabel!
}
