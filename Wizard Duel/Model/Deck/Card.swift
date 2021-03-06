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
    var cardID: String
    
    init(name: String) {
        self.cardID = NSUUID().uuidString
        self.name = name
    }
    
    static func pickDeck() -> URL? {
         var deckURL : URL?
        
        // Uncomment the next line for debugging to load the deck file of your choice
//        deckURL = Bundle.main.url(forResource: "kittenDeck", withExtension: "txt")
        
        #if os(iOS)
        
        deckURL = Bundle.main.url(forResource: "Muldrotha", withExtension: "txt")
        #elseif os(OSX)
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
        #endif
        if deckURL != nil {
            return deckURL!
        } else {
            return nil
        }
    }
    
    static func parseDeck(strings: [String]) -> ([Card],String) {
        var commander: String?
        var cards: [Card] = []
        //Loops through the array of text lines and splits them after the number of cards. Then splits the number of cards and card name into two variables.
        for cardInfo in strings {
            if cardInfo.count > 3 {
                let cardInfoArray = cardInfo.split(separator: " ", maxSplits: 1)
                if let numberOfCards = Int(String((cardInfoArray.first)!)) {
                    var cardName = String(cardInfoArray.last!)
                    if cardName.hasPrefix("*") {
                        cardName.remove(at: cardName.startIndex)
                        commander = cardName
                    }
                    
                    //Appends each card to the deck x times where x is the numberOfCards specified.
                    for _ in 0..<numberOfCards {
                        cards.append(Card(name: cardName))
                    }
                }
            }
        }
        if commander != nil {
            return (cards, commander!)
        }
        else {
            return(cards, "nil")
        }
    }

    static func cardsFromFile(url: URL?) -> [String] {
        if let url = url {
            do {
                //Initializes the path to the file
                let content = try String(contentsOf: url, encoding: String.Encoding.utf8)
                //Creates an array of strings with each index in the array holding one line of the file.
                let cardInfos: [String] = content.components(separatedBy: CharacterSet.newlines)
                return cardInfos
                
            } catch {
                print("Unknown Error Occured while opening file")
            }
        } else {
            print("Could not find file")
        }
        return []
    }
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
