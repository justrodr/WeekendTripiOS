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

//class RoundTrip {
//    var origin: String
//    var destination: String
//    var cost: Float
//    var link: String
//    var originFullName: String
//    var destinationFullName: String
//
//    init(origin: String, destination: String, cost: Float, link: String, originFullName: String, destinationFullName: String) {
//        self.origin = origin
//        self.destination = destination
//        self.cost = cost
//        self.link = link
//        self.originFullName = originFullName
//        self.destinationFullName = destinationFullName
//    }
//}

class RoundTrip {
    var originCode: String
    var destinationCode: String
    var originName: String
    var destinationName: String
    var cost: Float
    var link: String
    
    init(originCode: String, destinationCode: String, originName: String, destinationName: String, cost: Float, link: String) {
        self.originCode = originCode
        self.destinationCode = destinationCode
        self.destinationName = destinationName
        self.originName = originName
        self.cost = cost
        self.link = link
    }
}

struct ResultWithOriginAndDestination {
    let sessionResults: SessionResults
    let originCode: String
    let destinationCode: String
    let originName: String
    let destinationName: String
}

//let possibleDestinations: [String] = ["IAH", "JFK", "SFO", "ATL", "ABQ", "AUS", "CLT", "ORD", "CVG", "DFW", "DEN", "EWR", "LAX", "LGA", "MDW", "SEA", "MCO", "PHX", "MIA", "BOS", "MSP", "DTW", "FLL", "PHL", "BWI", "SLC", "DCA", "IAD", "SAN", "TPA", "HNL", "PDX", "MEX", "YVR", "YUL", "YYZ", "HNL", "OAK", "SJC"]

let possibleDestinations: [String] = ["ATL", "ABQ", "AUS"] //Short list

//let texasPossibleDestinations: [String] = ["IAH", "HOU", "AUS", "DFW", "SAT", "CLL", "MCO", "MIA", "LGA", "JFK", "EWR", "SEA", "LAX", "DEN", "ORD", "PHL", "MSY", "ATL", "DCA", "IAD", "SAN", "FLL", "TPA", "DTW", "CLT", "SFO", "SJC", "OAK"] //For Texans

//let westCoastPossibleDestinations: [String] = ["SJC", "OAK", "SFO", "LAX", "SEA", "PDX", "LAS"] //West coast
