//
//  Resetable.swift
//  Freecell2
//
//  Created by gary on 29/08/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

protocol Resetable: HasState {
    func reset()
}


extension Resetable {
    func reset() {
        self.state = .empty
    }
}
