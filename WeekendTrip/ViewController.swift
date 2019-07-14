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
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var originLabel: UILabel!
    @IBOutlet weak var outboundFlightButton: UIButton!
    @IBOutlet weak var inboundFlightButton: UIButton!
    @IBOutlet weak var toSymbolLabel: UILabel!
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        toSymbolLabel.text = "\u{21C6}"
        searchButton.setTitle("\u{2192}", for: .normal)
        priceLabel.text = "Enter Origin"
        outboundFlightButton.layer.borderWidth = 0.5
        outboundFlightButton.layer.cornerRadius = 8
        outboundFlightButton.setTitle("\u{2708} \u{2192}", for: .normal)
        inboundFlightButton.layer.borderWidth = 0.5
        inboundFlightButton.layer.cornerRadius = 8
        inboundFlightButton.setTitle("\u{2190} \u{2708}", for: .normal)
        toSymbolLabel.isHidden = true
        originLabel.isHidden = true
        destinationLabel.isHidden = true
        outboundFlightButton.isHidden = true
        inboundFlightButton.isHidden = true
        errorMessageLabel.isHidden = true
        configureTapGesture()
        originInputField.delegate = self
        getNearestWeekendDates()
    }
    
    func setResultTripLabel(trip: Trip) {
        self.priceLabel.text = "$" + String(trip.cost)
        self.destinationLabel.text = trip.destination
        self.originLabel.text = trip.origin
        toSymbolLabel.isHidden = false
        originLabel.isHidden = false
        destinationLabel.isHidden = false
//        outboundFlightButton.isHidden = false
//        inboundFlightButton.isHidden = false
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
            if quotes.count <= 0 {
                cheapestPrice = 10000
            } else {
                cheapestPrice = quotes[0]
            }
            
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
        errorMessageLabel.isHidden = true
        originInputField.resignFirstResponder()
        let textFieldInput = self.originInputField.text
        self.originInputField.text = textFieldInput
        if stringIsAnAirportCode(input: textFieldInput ?? "") {
            let trip = findCheapestRoundTrip(origin: textFieldInput ?? "")
            setResultTripLabel(trip: trip)
        } else {
            if textFieldInput?.count ?? 0 <= 3 {
                errorMessageLabel.text = "Sorry, this airport is not supported"
            } else {
                errorMessageLabel.text = "Please enter a 3-letter airport code"
            }
            errorMessageLabel.isHidden = false
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
