//
//  StatisticsStore.swift
//  Freecell2
//
//  Created by gary on 31/08/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

import Foundation

protocol StatisticsStoreProtocol {
    func load() -> Statistics
    func save(statistics: Statistics)
}

struct StatisticsStore: StatisticsStoreProtocol {
    let userDefaults: UserDefaults
    let key = "freecellstatistics"


    func load() -> Statistics {
        guard let data = userDefaults.data(forKey: key) else {
            return Statistics()
        }
        return try! JSONDecoder().decode(Statistics.self, from: data)
    }


    func save(statistics: Statistics) {
        let json = try! JSONEncoder().encode(statistics)
        userDefaults.set(json, forKey: key)
    }
}
