//
//  DataTypes.swift
//  WeekendTrip
//
//  Created by Justin Rodriguez on 7/13/19.
//  Copyright © 2019 Justin Rodriguez. All rights reserved.
//

import Foundation

class ViewModel : NSObject {
    
    var requestHandler : RequestHandler = RequestHandler()
    
    func startSearch(origin: String) -> [RoundTrip] {
        print("Starting search")
        let weekendDates = getNearestWeekendDatesForSearch()
        let sessionResultsArray = requestHandler.search(origin: origin, outboundDate: weekendDates[0], inboundDate: weekendDates[1])
        print("Finished polling")
        print(requestHandler.sessionResultsArray.count)
        var cheapTripsArr = getCheapestTrips(sessionResults: sessionResultsArray)
        cheapTripsArr.removeAll(where: { $0.destinationCode == "---" })
        return cheapTripsArr
    }
    
    func getCheapestTrips(sessionResults: [ResultWithOriginAndDestination]) -> [RoundTrip] {
        var cheapestTrips = [RoundTrip]()
        for destination in sessionResults {
            cheapestTrips.append(getCheapestTrip(destination: destination))
        }
        cheapestTrips.sort(by: { $0.cost < $1.cost })
        return cheapestTrips
    }
    
    func getCheapestTrip(destination: ResultWithOriginAndDestination) -> RoundTrip {
        var roundTrips = [RoundTrip]()
        for itinerary in destination.sessionResults.Itineraries {
            for pricingOption in itinerary.PricingOptions{
                let newRoundTrip = RoundTrip.init(originCode: destination.originCode, destinationCode: destination.destinationCode, originName: destination.originName, destinationName: destination.destinationName, cost: pricingOption.Price, link: pricingOption.DeeplinkUrl)
                roundTrips.append(newRoundTrip)
            }
        }
        roundTrips.sort(by: {$0.cost < $1.cost})
        if roundTrips.count <= 0 {
            return RoundTrip(originCode: "---", destinationCode: "---", originName: "", destinationName: "", cost: 10000, link: "https://www.skyscanner.com/uh")
        }
        return roundTrips[0]
    }
    
    func stringIsAnAirportCode(input: String) -> Bool {
        for destination in possibleDestinations {
            if input == destination.key {
                return true
            }
        }
        return false
    }
    
    func getRawNearestDates() -> [Date] {
        let today = Date()
        let calendar = Calendar.current
        let todayComponents = calendar.dateComponents([.year, .month, .day, .weekday], from: today)
        var daysUntilNextFriday: Int = 0
        switch todayComponents.weekday {
        case 1:
            daysUntilNextFriday = 5
            print("it's sunday")
            break
        case 2:
            daysUntilNextFriday = 4
            print("it's monday")
            break
        case 3:
            daysUntilNextFriday = 3
            print("it's tuesday")
            break
        case 4:
            daysUntilNextFriday = 2
            print("it's wednesday")
            break
        case 5:
            daysUntilNextFriday = 1
            print("it's thursday")
            break
        case 6:
            daysUntilNextFriday = 7
            print("it's friday")
            break
        case 7:
            daysUntilNextFriday = 6
            print("it's saturday")
            break
        default:
            break
        }
        
        var nextWeekendDates: [Date] = []

        if let nextFridayDate = calendar.date(byAdding: .day, value: daysUntilNextFriday, to: today) {
            nextWeekendDates.append(nextFridayDate)
        }
        
        if let nextSundayDate = calendar.date(byAdding: .day, value: daysUntilNextFriday + 2, to: today) {
            nextWeekendDates.append(nextSundayDate)
        }
        
        return nextWeekendDates
    }

    func getNearestWeekendDatesForSearch() -> [String] {
        let dates = getRawNearestDates()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        var nextWeekendDates: [String] = []
        
        var nextFriday: String
        nextFriday = formatter.string(from: dates[0])
        print(nextFriday)
        nextWeekendDates.append(nextFriday)
        
        var nextSunday: String
        nextSunday = formatter.string(from: dates[1])
        print(nextSunday)
        nextWeekendDates.append(nextSunday)
        
        return nextWeekendDates
        
    }
    
    func getNearestWeekendDatesForDisplay() -> String {
        let dates = getRawNearestDates()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        var nextWeekendDates: String
        
        var nextFriday: String
        nextFriday = formatter.string(from: dates[0])
        
        var nextSunday: String
        nextSunday = formatter.string(from: dates[1])
        
        nextWeekendDates = "Fri " + nextFriday + " - " + "Sun " + nextSunday
        
        return nextWeekendDates
        
    }
}

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

let possibleDestinations: [String: [String]] = ["IAH": IAH, "JFK": JFK, "SFO": SFO, "ATL": ATL, "ABQ": ABQ, "AUS": AUS, "CLT": CLT, "ORD": ORD, "CVG": CVG, "DFW": DFW, "DEN": DEN, "EWR": EWR, "LAX": LAX, "LGA": LGA, "SEA": SEA, "MCO": MCO, "PHX": PHX, "MIA": MIA, "BOS": BOS, "MSP": MSP, "DTW": DTW, "FLL": FLL, "PHL": PHL, "BWI": BWI, "SLC": SLC, "DCA": DCA, "IAD": IAD, "SAN": SAN, "TPA": TPA, "HNL": HNL, "PDX": PDX, "OAK": OAK, "SJC": SJC, "PIT": PIT, "BNA": BNA]

let IAH: [String] = ["LAS","LAX","SFO","OAK","SEA","MSY","MCO","IAD","SAN","MTY","TPA","FLL","DTW","MSP","CLT","MEX","CUN"]
let JFK: [String] = ["BOS","IAD","CLT","PIT","SYR","CLE","JAX","BTV","RDU","ORF","PHL","MCO","ORD","SFO","ATL","MEX","CUN"]
let SFO: [String] = ["LAX","JFK","EWR","LAS","SAN","SEA","PDX","ORD","SNA","DEN","RNO","DFW","PHX","AUS","SLC","MEX","CUN"]
let ATL: [String] = ["EWR","JFK","MIA","LAS","MCO","LAX","ORD","IAD","CLT","DEN","IAH","MSY","FLL","TPA","BOS","MEX","CUN"]
let ABQ: [String] = ["DEN","LAS","PHX","LAX","DFW","EWR","JFK","AUS","IAH","SAN","SLC","ORD","SEA","SFO","PDX","MEX","CUN"]
let AUS: [String] = ["LAS","LAX","DEN","ORD","MTY","ATL","SFO","MCO","SEA","IAD","DFW","SAN","PHL","DET","SJC","OAK","CUN"]
let CLT: [String] = ["EWR","JFK","MCO","IAD","ATL","BNA","ORD","DEN","PHL","BOS","MYR","DFW","FLL","TPA","CVG","MEX","CUN"]
let ORD: [String] = ["EWR","JFK","LAS","ATL","DFW","BOS","IAD","MSP","DTW","STL","IAH","TPA","AUS","OAK","FLL","MEX","CUN"]
let CVG: [String] = ["EWR","JFK","ORD","MCO","ATL","PHL","TPA","MSP","STL","SRQ","YYZ","YUL","CLE","PIT","MCI","MEX","CUN"]
let DFW: [String] = ["LAS","LAX","FLL","DEN","ORD","ATL","MSP","MCO","MTY","SEA","SFO","PHX","IAD","PHL","DTW","MEX","CUN"]
let DEN: [String] = ["LAX","ORD","DFW","SLC","SEA","IAH","MSP","IAD","DTW","STL","FLL","SAT","MKE","LAS","SFO","MEX","CUN"]
let EWR: [String] = ["MCO","BOS","FLL","IAD","CLT","IAH","PIT","CLE","ROC","SYR","DAY","MIA","TPA","ORD","ATL","MEX","CUN"]
let LAX: [String] = ["LAS","SFO","SEA","DFW","SJC","PHX","DEN","PDX","SMF","IAH","IAD","OAK","AUS","SLC","DTW","MEX","CUN"]
let LGA: [String] = ["ORD","MCO","ATL","BOS","FLL","DEN","IAD","CLT","DTW","RDU","MYR","PIT","CLE","JAX","YYZ","MEX","CUN"]
let SEA: [String] = ["LAX","SFO","SAN","DEN","PDX","SLC","SJC","BOI","SMF","MSP","OAK","RNO","YVR","LAS","AUS","MEX","CUN"]
let MCO: [String] = ["EWR","JFK","ATL","IAD","PHL","DEN","BOS","BNA","IAH","CLT","FLL","DTW","CLE","MSP","PIT","MEX","CUN"]
let PHX: [String] = ["LAS","LAX","DEN","SEA","DFW","SLC","PDX","MSP","ELP","OAK","COS","PGA","GCN","SFO","PDX","MEX","CUN"]
let MIA: [String] = ["EWR","JFK","ATL","MCO","HAV","IAH","MSY","DFW","JAX","DEN","CLT","DTW","CLE","CVG","RDU","MEX","CUN"]
let BOS: [String] = ["EWR","JFL","LGA","IAD","ORD","PHL","MCO","ATL","DEN","BUF","FLL","TPA","DTW","RDU","PIT","MEX","CUN"]
let MSP: [String] = ["DEN","SEA","DFW","MKE","TPA","PDX","IAH","STL","DSM","YYZ","YUL","CLT","MCO","CVG","PHL","MEX","CUN"]
let DTW: [String] = ["EWR","JFK","LGA","ORD","MCO","LAX","ATL","DEN","BOS","FLL","IAD","DFW","TPA","AUS","PHL","MEX","CUN"]
let FLL: [String] = ["EWR","JFK","LGA","ATL","TPA","LAX","ORD","MCO","BOS","DEN","EYW","PHL","IAD","JAX","CLT","MEX","CUN"]
let PHL: [String] = ["MCO","BOS","FLL","DEN","CLT","RDU","IAH","MYR","DTW","JAX","RSW","MSP","CVG","LAS","AUS","MEX","CUN"]
let BWI: [String] = ["BOS","ATL","MCO","ORD","DEN","FLL","CLT","IAH","TPA","RDU","DTW","PIT","MSP","JAX","IAH","MEX","CUN"]
let SLC: [String] = ["DEN","SEA","SFO","AUS","SJC","OAK","CDC","EKO","PIH","LAS","PHX","SAN","MSY","IAH","MCO","MEX","CUN"]
let DCA: [String] = ["BOS","JFK","EWR","LGA","DEN","CLT","YYZ","RDU","DTW","MSP","CLE","SYR","MCO","ORD","DFW","MEX","CUN"]
let IAD: [String] = ["BOS","JFK","LGA","EWR","DEN","CLT","YYZ","RDU","DTW","ORF","CLE","CSG","MCO","IAH","AUS","MEX","CUN"]
let SAN: [String] = ["SFO","LAS","SEA","SJC","PHX","ORD","DEN","SMF","LAX","PDX","ABQ","AUS","OAK","RNO","SLC","MEX","CUN"]
let TPA: [String] = ["ATL","ORD","FLL","DEN","BOS","IAD","DFW","PHL","BDL","DTW","CLT","CLE","PIT","MSP","CVG","MEX","CUN"]
let HNL: [String] = ["LAX","LIH","SEA","KOA","SYD","ITO","SAN","PDX","PHX","YVR","SLC","SJC","OAK","SMP","OGG","MEX","CUN"]
let PDX: [String] = ["LAX","SFO","SEA","DEN","SAN","SMP","GEG","BOI","RNO","SJC","MSP","AUS","IAH","OAK","LAS","MEX","CUN"]
let OAK: [String] = ["LAX","LAS","SAN","SEA","PHX","IAH","DFW","SLC","AUS","DTW","MSP","FLL","ORD","PIT","MCO","MEX","CUN"]
let SJC: [String] = ["LAX","SAN","SEA","PDX","RNO","DEN","BUR","SLC","LGB","BOI","GEG","ELP","EUG","AUS","IAH","MEX","CUN"]
let PIT: [String] = ["JFK","EWR","LGA","BOS","ORD","MYR","LAX","IAD","DCA","ATL","TPA","FLL","RDU","STL","JAX","MEX","CUN"]
let BNA: [String] = ["ATL","ORD","MCO","LAS","DEN","IAD","DCA","MSY","BOS","RDU","FLL","MSP","ORF","RIC","SAC","MEX","CUN"]


