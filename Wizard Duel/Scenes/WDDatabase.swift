//
//  Database.swift
//  WizardDuel
//
//  Created by Cobey Hollier on 2018-08-16.
//  Copyright © 2018 Gary Kerr. All rights reserved.
//

#if os(iOS)
import Firebase
#elseif os(OSX)
import FirebaseDatabase
#endif

class WDDatabase {
    let database = Database.database().reference()
    var playerNumber = 0
    var gameScene: GameScene?
    var gameGraphics = GameGraphics()
    let players: DatabaseReference
    
    
    init() {
        self.players = database.child("players")
    }
    
    func setup(gameScene: GameScene, gameGraphics: GameGraphics) {
        self.gameScene = gameScene
        self.gameGraphics = gameGraphics
    }
    
    //Adds the player to the database when they join the game
    func addToDatabase(_ player: String) -> DatabaseReference {
        //Creates a new child database to store the players names.
        let databaseRef = Database.database().reference()
        let playerUpdate = databaseRef.child("players")
        //Accesses the database a sigle time to retrieve the players names.
        playerUpdate.observeSingleEvent(of: .value, with: { (snapshot) in
            self.playerNumber = Int(snapshot.childrenCount)
            let playerDictonary = ["player": player, "playNumber": String(self.playerNumber), "lifeTotal": "40"]
            let databaseRef = playerUpdate.childByAutoId()
            databaseRef.setValue(playerDictonary) {
                (error, reference) in
                if error != nil {
                    print(error!)
                }
                else {
                    print("Player Saved")
                    for player in snapshot.children.allObjects as! [DataSnapshot] {
                        self.processPlayerUpdate(snapshot: player)
                    }
                }
            }
            self.retrieveUpdates()
        }) { (error) in
            print(error.localizedDescription)
        }
        databaseRef.child("Updates").removeValue()
        return databaseRef
    }
    
    
    //Sends a card and location to the database when a card is moved
    func updateDatabase(playingCard: PlayingCard) {
        let cardUpdate = Database.database().reference().child("Updates")
        var value = 0
        //This takes the location that the sender dropped the card.
        
        if let location = gameScene?.game.location(from: playingCard.card) {
            if case .battlefield(let field, let stack) = location {
                if playingCard.children.count != 0 {
                    let dice = playingCard.childNode(withName: "dice") as! PlayingDice
                    value = dice.dice.value
                }
                //Checks if the playingcard has an ID, and if not, assigns it a new ID.
                let databaseRef = playingCard.databaseRef ?? cardUpdate.childByAutoId().key
                var updateDictionary = ["Sender": String(playerNumber), "Card": playingCard.card.name, "Field": String(field), "Stack": String(stack), "Tapped": String(playingCard.tapped), "DiceValue": String(value)]
                if playingCard.databaseRef == nil {
                    playingCard.databaseRef = databaseRef
                    updateDictionary["Owner"] = String(self.playerNumber)
                    cardUpdate.child(databaseRef).setValue(updateDictionary)
                }
                else {
                    cardUpdate.child(databaseRef).updateChildValues(updateDictionary)
                }
            }
        }
    }
    
    //Retrieves an update or addition of a card from the database. Can fetch new dice, dice updates, card taps, and new cards.
    func retrieveUpdates() {
        let cardUpdate = Database.database().reference().child("Updates")
        cardUpdate.observe(.childAdded) { (snapshot) in
            if snapshot.childrenCount != 0 {
                self.processUpdate(snapshot: snapshot)
            }
        }
        cardUpdate.observe(.childChanged, with: { (snapshot) in
            self.processUpdate(snapshot: snapshot)
        })
        
        //Deletes a card from the database if the card is removed from the battlefield
        cardUpdate.observe(.childRemoved, with: { (snapshot) in
            if let snapshotValue = snapshot.value as? Dictionary<String,String> {
                let owner = Int(snapshotValue["Owner"]!)
                let sender = Int(snapshotValue["Sender"]!)
                let stack = Int(snapshotValue["Stack"]!)
                let relativeField = Int(snapshotValue["Field"]!)
                if owner != self.playerNumber {
                    let fieldNumber = self.findField(sender: sender!, relativeField: relativeField!)
                    for playingCard in self.gameGraphics.cards.reversed() {
                        if playingCard.databaseRef == snapshot.key {
                            self.gameScene?.game.allBattlefields[fieldNumber][stack!].removeCard(card: playingCard.card)
                            self.gameGraphics.delete(playingCard: playingCard)
                        }
                    }
                }
            }
        })
        let playerUpdate = Database.database().reference().child("players")
        
        playerUpdate.observe(.childAdded) { (snapshot) in
            if snapshot.childrenCount != 0 {
                self.processPlayerUpdate(snapshot: snapshot)
            }
        }
        
        playerUpdate.observe(.childChanged, with: { (snapshot) in
            self.processPlayerUpdate(snapshot: snapshot)
        })
    }
    
    //Processes the update of card on the local game to unsure that all version of the game are up to date with each other.
    func processUpdate(snapshot: DataSnapshot) {
        //Retrieves all the information from the snapshot.
        if let snapshotValue = snapshot.value as? Dictionary<String,String> {
            if let cardName = snapshotValue["Card"],
                let sender = Int(snapshotValue["Sender"]!),
                let stack = Int(snapshotValue["Stack"]!),
                let relativeField = Int(snapshotValue["Field"]!),
                let cardTapped = Bool(snapshotValue["Tapped"]!),
                let diceValue = Int(snapshotValue["DiceValue"]!) {
                
                let fieldNumber = findField(sender: sender, relativeField: relativeField)
                //Prevents updates from the sender to be recieved by the sender again.
                if sender != self.playerNumber {
                    //Finds the playing card with the correct ID
                    var playingCard = gameGraphics.cards.filter({
                        let databaseRef = $0.databaseRef
                        return databaseRef == snapshot.key
                    }).first
                    
                    var location = Location.dataExtract()
                    
                    //Updates the playing card if one is found other wise creates a new card locally.
                    if let playingCard = playingCard {
                        if let previousLocation = self.gameGraphics.dropLocation(from: playingCard.position, playingCard: playingCard, game: (gameScene?.game)!) {
                            location = previousLocation
                            if diceValue > 0 && playingCard.children.count == 0 {
                                let newPlayingDice = gameGraphics.addDice(to: gameScene!)
                                gameGraphics.drop(playingDice: newPlayingDice, on: playingCard)
                            }
                            else if playingCard.children.count != 0 && diceValue == 0{
                                playingCard.removeAllChildren()
                            }
                            else {
                                if let playingDice = gameGraphics.findDice(from: playingCard) {
                                    playingDice.dice.value = diceValue
                                    playingDice.setTexture()
                                }
                            }
                        }
                    } else {
                        let newPlayingCard = gameGraphics.addFromDatabase(name: cardName, field: fieldNumber, stack: stack, scene: gameScene!)
                        newPlayingCard.databaseRef = snapshot.key
                        playingCard = newPlayingCard
                    }
                    
                    if let playingCard = playingCard {
                        let currentPlayingCard = CurrentPlayingCard(playingCard: playingCard, startPosition: playingCard.position, touchPoint: playingCard.position, location: location)
                        if currentPlayingCard.playingCard.tapped != cardTapped {
                            self.gameGraphics.tap(card: currentPlayingCard.playingCard)
                            return
                        }
                        
                        let battlefieldLocation = Location.battlefield(fieldNumber, stack)
                        gameScene?.moveLocation(currentPlayingCard: currentPlayingCard, location:  battlefieldLocation)
                        
                        
                    } else {
                        print("Error: Card not found or created")
                    }
                }
            }
        }
    }
    
    
    
    //Processes an update when a new player is added to the database or life is changed. Creates a player info label or updates the existing one.
    private func processPlayerUpdate(snapshot: DataSnapshot) {
        if let snapshotValue = snapshot.value as? Dictionary<String,String> {
            if let playerName = snapshotValue["player"],
                let playerNumber = Int(snapshotValue["playNumber"]!),
                let lifeTotal = Int(snapshotValue["lifeTotal"]!) {
                if let player = gameGraphics.findPlayer(with: playerNumber) {
                    player.lifeTotal = lifeTotal
                    player.updateLife()
                    
                } else {
                    gameGraphics.addPlayer(playerName: playerName, playerNumber: playerNumber, lifeTotal: lifeTotal, to: gameScene!, playerNumberSelf: self.playerNumber, databaseKey: snapshot.key)
                }
            }
        }
    }
    
    //Removes a playing card from the database.
    func deleteFromDatabase(playingCard: PlayingCard) {
        if playingCard.databaseRef != nil {
            Database.database().reference().child("Updates").child((playingCard.databaseRef)!).removeValue()
        }
        else {
            print("Failed to remove playing card from database")
        }
        
    }
    
    //Determines what field to place a card on relative to the local user to ensure consistant player order.
    private func findField(sender: Int, relativeField: Int) -> Int {
        return (4 + sender - self.playerNumber + relativeField) % 4
    }
    
}
