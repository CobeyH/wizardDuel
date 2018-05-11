//
//  ContainsCard.swift
//  Freecell2
//
//  Created by gary on 29/08/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

protocol ContainsCard {
    func contains(card: Card) -> Bool
}


extension ContainsCard where Self: HasState {
    func contains(card: Card) -> Bool {
        switch state {
        case .empty:
            return false
        case .card(let currentCard):
            return card == currentCard
        }
    }
}
