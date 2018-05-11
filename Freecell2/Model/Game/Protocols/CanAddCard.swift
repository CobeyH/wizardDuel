//
//  CanAddCard.swift
//  Freecell2
//
//  Created by gary on 19/08/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

protocol CanAddCard {
    func canAdd(card: Card) -> Bool
    func add(card: Card) throws
}
