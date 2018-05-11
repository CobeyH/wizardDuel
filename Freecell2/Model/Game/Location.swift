//
//  Location.swift
//  Freecell2
//
//  Created by gary on 19/08/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

enum Location {
    case cell(Int)
    case foundation(Int)
    case cascade(Int)
}


extension Location: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .cell(let value):
            return "cell(\(value))"
        case .foundation(let value):
            return "foundation(\(value))"
        case .cascade(let value):
            return "cascade(\(value))"
        }
    }
}
