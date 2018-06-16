//
//  Card.swift
//  Freegraveyard2
//
//  Created by gary on 15/08/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

import Foundation
import SpriteKit

struct Card {
    var name: String
    var cardID: Int
    
    static func deck() -> [Card] {
        var deckURL : URL?
        
        // Uncomment the next line for debugging to load the deck file of your choice
//        deckURL = Bundle.main.url(forResource: "kittenDeck", withExtension: "txt")
        
        if deckURL == nil {
            //Adds a popup window when the app is launched to ask the player to select a deck
            let dialog = NSOpenPanel()
            dialog.title = "Choose a deck"
            dialog.showsResizeIndicator = true
            dialog.showsHiddenFiles = false
            dialog.canChooseDirectories = false
            dialog.allowedFileTypes = ["txt"]
            if dialog.runModal() == NSApplication.ModalResponse.OK {
                deckURL = dialog.url
            }
        }
        
        return cardsFromFile(url: deckURL)
    }
    
}

func cardsFromFile(url: URL?) -> [Card] {
    var cards: [Card] = []
    if let url = url {
        do {
            //Initializes the path to the file
            let content = try String(contentsOf: url, encoding: String.Encoding.utf8)
            //Creates an array of strings with each index in the array holding one line of the file.
            let cardInfos: [String] = content.components(separatedBy: CharacterSet.newlines)
            
            //Loops through the array of text lines and splits them after the number of cards. Then splits the number of cards and card name
            //into two variables.
            var i = 0
            for (cardInfo) in cardInfos {
                if cardInfo.count > 3 {
                    let cardInfoArray = cardInfo.split(separator: " ", maxSplits: 1)
                    if let numberOfCards = Int(String((cardInfoArray.first)!)) {
                        let cardName = String(cardInfoArray.last!)
                        
                        //Appends each card to the deck x times where x is the numberOfCards specified.
                        for _ in 0..<numberOfCards {
                            cards.append(Card(name: cardName, cardID: i))
                            i = i + 1
                        }
                    }
                }
            }
        } catch {
            print("Unknown Error Occured while opening file")
        }
    } else {
        print("Could not find file")
    }
    
    return cards
}

extension Card: Equatable {
    static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.cardID == rhs.cardID
    }
}


extension Card: CustomDebugStringConvertible {
    var debugDescription: String {
        return name
    }
}
