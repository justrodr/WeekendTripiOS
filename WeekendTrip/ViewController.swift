//
//  ViewController.swift
//  WeekendTrip
//
//  Created by Justin Rodriguez on 6/9/19.
//  Copyright © 2019 Justin Rodriguez. All rights reserved.
//

import UIKit
import Alamofire
import SafariServices


class ViewController: UIViewController {
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var originInputField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var originLabel: UILabel!
    @IBOutlet weak var toSymbolLabel: UILabel!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var bookNowButton: UIButton!
    
    var resultRoundTrip: OneWayTrip?
    var bookNowLink: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        toSymbolLabel.text = "\u{21C6}"
        searchButton.setTitle("\u{2192}", for: .normal)
        priceLabel.text = "Enter Origin"
        originInputField.layer.borderWidth = 3
        originInputField.layer.borderColor = UIColor.init(red: 42/255, green: 140/255, blue: 122/255, alpha: 1).cgColor
        originInputField.layer.cornerRadius = 8
        bookNowButton.layer.borderColor = UIColor.init(red: 169/255, green: 215/255, blue: 217/255, alpha: 1).cgColor
        bookNowButton.layer.borderWidth = 3
        bookNowButton.layer.cornerRadius = 20
        
        
        toSymbolLabel.isHidden = true
        originLabel.isHidden = true
        destinationLabel.isHidden = true
        errorMessageLabel.isHidden = true
        configureTapGesture()
        originInputField.delegate = self
        bookNowButton.isHidden = true
    }
    
    func startSearch(origin: String) {
        print("Starting search")
        DispatchQueue.global(qos: .background).async {
            let sessionResults = self.getRoundTripsToAllDestinations(origin: origin)
            DispatchQueue.main.async {
                let sortedTrips = self.getCheapestTrips(sessionResults: sessionResults)
                print(sortedTrips[0].destination)
                self.setResultScreen(trip: sortedTrips[0])
            }
        }
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
                let newRoundTrip = RoundTrip.init(origin: destination.origin, destination: destination.Destination, cost: pricingOption.Price, link: pricingOption.DeeplinkUrl)
                roundTrips.append(newRoundTrip)
                print(roundTrips)
            }
        }
        roundTrips.sort(by: {$0.cost < $1.cost})
        if roundTrips.count <= 0 {
            return RoundTrip(origin: "---", destination: "---", cost: 10000, link: "https://www.skyscanner.com/uh")
        }
        return roundTrips[0]
    }
    
    
    
    func getRoundTripsToAllDestinations(origin: String) -> [ResultWithOriginAndDestination] {
        let nextWeekendDates = getNearestWeekendDates()
        var sessions = [String]()
        var results = [ResultWithOriginAndDestination]()
        for destination in possibleDestinations {
            sessions.append(createSession(origin: origin, destination: destination, inboundDate: nextWeekendDates[1], outboundDate: nextWeekendDates[0]))
        }
        for key in sessions {
            if key != ""{
                let sessionResult = pollSessionResults(sessionKey: key)
                let destination = nameOfDestination(sessionResult: sessionResult)
                results.append(ResultWithOriginAndDestination(sessionResults: sessionResult, origin: origin, Destination: destination))
            }
        }
        return results
    }
    
    func nameOfDestination(sessionResult: SessionResults) -> String {
        print("Finding place code")
        let destinationID = Int(sessionResult.Query.DestinationPlace)
        let places = sessionResult.Places
        print("target: " + sessionResult.Query.DestinationPlace)
        for place in places {
            print(place.Id)
            if place.Id == destinationID {
                return place.Code
            }
        }
        print("couldn't find place code")
        return ""
    }
    
    func setResultScreen(trip: RoundTrip) {
        searchButton.isEnabled = true
        self.priceLabel.text = "$" + String(trip.cost)
        self.destinationLabel.text = trip.destination
        self.originLabel.text = trip.origin
        toSymbolLabel.isHidden = false
        originLabel.isHidden = false
        destinationLabel.isHidden = false
        bookNowButton.isHidden = false
        bookNowLink = trip.link
    }
    
    func getRoundTrip(origin: String, destination: String, dates: [String]) -> OneWayTrip {
        let outboundLeg = getOneWayTrip(origin: origin, destination: destination, date: dates[0])
        let inboundLeg = getOneWayTrip(origin: destination, destination: origin, date: dates[1])
        let roundTrip = OneWayTrip.init(origin: origin, destination: destination, cost: outboundLeg.cost + inboundLeg.cost)
        return roundTrip
    }
    
    func getOneWayTrip(origin: String, destination: String, date: String) -> OneWayTrip {
        
        var cheapestPrice: Int = -1
        do {
            var quotes: [Quote] = []
            let routeData = try searchRouteData(origin: origin, destination: destination, date: date)
            for quote in routeData?.Quotes ?? [] {
                quotes.append(quote)
            }
            quotes.sort(by: { $0.MinPrice < $1.MinPrice })
            if quotes.count <= 0 {
                cheapestPrice = 10000
            } else {
                cheapestPrice = quotes[0].MinPrice
            }
            
        } catch {
            print("failed to find flights from " + origin + " to " + destination)
        }
        
        let trip = OneWayTrip.init(origin: origin, destination: destination, cost: cheapestPrice)
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
        searchButton.isEnabled = false
        errorMessageLabel.isHidden = true
        originInputField.resignFirstResponder()
        let textFieldInput = self.originInputField.text
        self.originInputField.text = textFieldInput
        if stringIsAnAirportCode(input: textFieldInput ?? "") {
            self.originLabel.text = textFieldInput
            self.priceLabel.text = "Searching..."
            startSearch(origin: textFieldInput ?? "")
        } else {
            if textFieldInput?.count ?? 0 <= 3 {
                errorMessageLabel.text = "Sorry, this airport is not supported"
            } else {
                errorMessageLabel.text = "Please enter a 3-letter airport code"
            }
            errorMessageLabel.isHidden = false
        }
        
    }
    
    @IBAction func bookNowButtonPressed(_ sender: Any) {
        let url = URL(string: bookNowLink ?? "https://www.skyscanner.com/uh")
        let safariVC = SFSafariViewController(url: url!)
        present(safariVC, animated: true)
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
