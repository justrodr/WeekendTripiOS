//
//  ViewController.swift
//  WeekendTrip
//
//  Created by Justin Rodriguez on 6/9/19.
//  Copyright © 2019 Justin Rodriguez. All rights reserved.
//

import UIKit
import Alamofire


class ViewController: UIViewController {
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var originInputField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTapGesture()
        originInputField.delegate = self
        getNearestWeekendDates()
    }
    
    func setResultTripLabel(trip: Trip) {
        self.priceLabel.text = "Go to " + trip.destination + " for $" + String(trip.cost) + "!"
    }
    
    func findCheapestRoundTrip(origin: String) -> Trip {
        var roundTripsToAllDestinations: [Trip] = getRoundTripsToAllDestinations(origin: origin)
        return roundTripsToAllDestinations[0]
    }
    
    func getRoundTripsToAllDestinations(origin: String) -> [Trip] {
        
        var trips: [Trip] = []
        let nextWeekendDates = getNearestWeekendDates()
        for destination in possibleDestinations {
            if origin != destination {
                let trip = getRoundTrip(origin: origin, destination: destination, dates: nextWeekendDates)
                let tripCost = String(trip.cost)
                print("Round Trip from " + origin + " to " + destination + " costs " + tripCost)
                trips.append(trip)
            }
        }
        trips.sort(by: { $0.cost < $1.cost })
        return trips
    }
    
    func getRoundTrip(origin: String, destination: String, dates: [String]) -> Trip {
        let outboundLeg = getOneWayTrip(origin: origin, destination: destination, date: dates[0])
        let inboundLeg = getOneWayTrip(origin: destination, destination: origin, date: dates[1])
        let roundTrip = Trip.init(origin: origin, destination: destination, cost: outboundLeg.cost + inboundLeg.cost)
        return roundTrip
    }
    
    func getOneWayTrip(origin: String, destination: String, date: String) -> Trip {
        
        var cheapestPrice: Int = -1
        do {
            var quotes: [Int] = []
            let routeData = try searchRouteData(origin: origin, destination: destination, date: date)
            for quote in routeData?.Quotes ?? [] {
                quotes.append(quote.MinPrice)
            }
            quotes.sort()
            cheapestPrice = quotes[0]
            
        } catch {
            print("failed to find flights from " + origin + " to " + destination)
        }
        
        let trip = Trip.init(origin: origin, destination: destination, cost: cheapestPrice)
        return trip
    }

    private func configureTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap() {
        view.endEditing(true)
    }
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        let textFieldInput = self.originInputField.text
        self.originInputField.text = textFieldInput
        if stringIsAnAirportCode(input: textFieldInput ?? "") {
            let trip = findCheapestRoundTrip(origin: textFieldInput ?? "")
            setResultTripLabel(trip: trip)
        } else {
            self.priceLabel.text = "Couldn't find that airport..."
        }
        
    }
    
    private func stringIsAnAirportCode(input: String) -> Bool {
        for destination in possibleDestinations {
            if input == destination {
                return true
            }
        }
        return false
    }
    
}

extension ViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
