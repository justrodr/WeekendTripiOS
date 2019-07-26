//
//  Models.swift
//  WeekendTrip
//
//  Created by Justin Rodriguez on 7/13/19.
//  Copyright © 2019 Justin Rodriguez. All rights reserved.
//

import Foundation

struct RouteSearchData: Decodable {
    
    let Routes: [Route]
    let Quotes: [Quote]
    let Currencies: [Currency]
    let Carriers: [Carrier]
    let Places: [Place]
}

struct Carrier: Decodable {
    let CarrierId: Int
    let Name: String
}

struct Currency: Decodable {
    let Code: String
    let DecimalDigits: Int
    let DecimalSeparator: String
    let RoundingCoefficient: Int
    let SpaceBetweenAmountAndSymbol: Bool
    let Symbol: String
    let SymbolOnLeft: Bool
    let ThousandsSeparator: String
}

//struct Place: Decodable {
//    let CityId: String
//    let CityName: String
//    let CountryName: String
//    let IataCode: String
//    let Name: String
//    let PlaceId: Int
//    let SkyscannerCode: String
//    //    let FlightType: String
//}

struct Quote: Decodable {
    let Direct: Bool
    let MinPrice: Int
    let OutboundLeg: FlightLeg
    let QuoteDateTime: String
    let QuoteId: Int
}

struct FlightLeg: Decodable {
    let CarrierIds: [Int]
    let DepartureDate: String
    let DestinationId: Int
    let OriginId: Int
}

struct Route: Decodable {
}

struct SessionResults: Decodable {
    let SessionKey: String
    let Query: Query
    let Status: String
    let Itineraries: [Itinerary]
    let Places: [Place]
}

struct Query: Decodable {
    let Country: String
    let Currency: String
    let Locale: String
    let Adults: Int
    let Children: Int
    let Infants: Int
    let OriginPlace: String
    let DestinationPlace: String
    let OutboundDate: String
    let InboundDate: String
    let LocationSchema: String
    let CabinClass: String
    let GroupPricing: Bool
}

struct Itinerary: Decodable {
    let OutboundLegId: String
    let InboundLegId: String
    let PricingOptions: [PricingOption]
    let BookingDetailsLink: BookingDetails
}

struct PricingOption: Decodable {
    let Agents: [Int]
    let QuoteAgeInMinutes: Int
    let Price: Float
    let DeeplinkUrl: String
}

struct BookingDetails: Decodable {
    let Uri: String
    let Body: String
    let Method: String
}

struct Place: Decodable {
    let Id: Int
    let Code: String
    let Name: String
}
