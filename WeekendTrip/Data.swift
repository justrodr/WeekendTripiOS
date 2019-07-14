//
//  DataTypes.swift
//  WeekendTrip
//
//  Created by Justin Rodriguez on 7/13/19.
//  Copyright © 2019 Justin Rodriguez. All rights reserved.
//

import Foundation

class Trip {
    var origin: String
    var destination: String
    var cost: Int
    
    init(origin: String, destination: String, cost: Int) {
        self.origin = origin
        self.destination = destination
        self.cost = cost
    }
}

let possibleDestinations: [String] = ["IAH", "JFK", "SFO", "ATL", "ABQ", "AUS", "CLT", "ORD", "CVG", "DFW", "DEN", "LAX", "SEA", "MCO", "PHX", "MIA", "BOS", "MSP", "DTW", "FLL", "PHL", "BWI", "SLC", "DCA", "IAD", "SAN", "MDW", "TPA", "HNL", "PDX", "MEX"] //removed EWR, LGA
