//
//  Card.swift
//  Freegraveyard2
//
//  Created by gary on 15/08/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

import Foundation

struct Card {
    var name: String
    var cardID: Int
    
    static func deck() -> [Card] {
        var cards: [Card] = []
        //creates a bundle with all the lines of text from a passed in file.
        if let fileURL = Bundle.main.url(forResource: "testDeck", withExtension: "txt") {
            do {
                //Content is a string containing the contents of the file. Each line seperated by /n.
                let content = try String(contentsOf: fileURL, encoding: String.Encoding.utf8)
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
            }
                //Catches any errors with the file URL
            catch {
                print("Error: \(error.localizedDescription)")
            }
        }
        else {
            print("No such file URL.")
        }
        
        return cards
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
