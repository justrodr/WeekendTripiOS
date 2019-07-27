//
//  DataTypes.swift
//  WeekendTrip
//
//  Created by Justin Rodriguez on 7/13/19.
//  Copyright © 2019 Justin Rodriguez. All rights reserved.
//

import Foundation

class OneWayTrip {
    var origin: String
    var destination: String
    var cost: Int
    
    init(origin: String, destination: String, cost: Int) {
        self.origin = origin
        self.destination = destination
        self.cost = cost
    }
}

class RoundTrip {
    var origin: String
    var destination: String
    var cost: Float
    var link: String
    
    init(origin: String, destination: String, cost: Float, link: String) {
        self.origin = origin
        self.destination = destination
        self.cost = cost
        self.link = link
    }
}

struct ResultWithOriginAndDestination {
    let sessionResults: SessionResults
    let origin: String
    let Destination: String
}

//let possibleDestinations: [String] = ["IAH", "JFK", "SFO", "ATL", "ABQ", "AUS", "CLT", "ORD", "CVG", "DFW", "DEN", "EWR", "LAX", "LGA", "MDW", "SEA", "MCO", "PHX", "MIA", "BOS", "MSP", "DTW", "FLL", "PHL", "BWI", "SLC", "DCA", "IAD", "SAN", "TPA", "HNL", "PDX", "MEX", "YVR", "YUL", "YYZ", "HNL", "OAK", "SJC"]

//let possibleDestinations: [String] = ["ATL", "ABQ", "AUS"] //Short list

//let possibleDestinations: [String] = ["IAH", "HOU", "AUS", "DFW", "SAT", "CLL", "MCO", "MIA", "LGA", "JFK", "EWR", "SEA", "LAX", "DEN", "ORD", "PHL", "MSY", "ATL", "DCA", "IAD", "SAN", "FLL", "TPA", "DTW", "CLT", "SFO", "SJC", "OAK"] //For Texans

let possibleDestinations: [String] = ["SJC", "OAK", "SFO", "LAX", "SEA", "PDX", "LAS"] //West coast
