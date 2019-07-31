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
    var responseLinks: [String] = []
    var sessionResultsArray: [ResultWithOriginAndDestination] = []
    let dispatchGroupCreateSession = DispatchGroup()
    let dispatchGroupPollSession = DispatchGroup()

    
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
        let weekendDates = getNearestWeekendDates()
        requestForAllDestinations(origin: origin, outboundDate: weekendDates[0], inboundDate: weekendDates[1])
    }
    
    func sortThroughResults() {
        let sortedTrips = self.getCheapestTrips(sessionResults: sessionResultsArray)
        if sortedTrips.count <= 0 {
            handleError()
        } else {
            print(sortedTrips[0].destination)
            self.setResultScreen(trip: sortedTrips[0])
        }
    }
    
    func handleError() {
        self.priceLabel.text = "😭👩‍💻⏸"
        self.errorMessageLabel.text = "Oops something went wrong. Check your internet connection and try again."
        self.errorMessageLabel.isHidden = false
        self.searchButton.isEnabled = true
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
//                print(roundTrips)
            }
        }
        roundTrips.sort(by: {$0.cost < $1.cost})
        if roundTrips.count <= 0 {
            return RoundTrip(origin: "---", destination: "---", cost: 10000, link: "https://www.skyscanner.com/uh")
        }
        return roundTrips[0]
    }
    
    
    
//    func getRoundTripsToAllDestinations(origin: String) -> [ResultWithOriginAndDestination] { //I want two dispatch groups to speed up this process
//        let nextWeekendDates = getNearestWeekendDates()
//        var sessions = [String]()
//        var results = [ResultWithOriginAndDestination]()
//        for destination in possibleDestinations {
//            if originAndDestinationisValid(origin: origin, destination: destination) {
//                sessions.append(createSession(origin: origin, destination: destination, inboundDate: nextWeekendDates[1], outboundDate: nextWeekendDates[0]))
//            }
//        }
//        for key in sessions {
//            if key != ""{
//                let sessionResult = pollSessionResults(sessionKey: key)
//                let destination = nameOfDestination(sessionResult: sessionResult)
//                results.append(ResultWithOriginAndDestination(sessionResults: sessionResult, origin: origin, Destination: destination))
//            }
//        }
//        return results
//    }
    
    func originAndDestinationisValid(origin: String, destination: String) -> Bool {
        if origin == "HOU" || origin == "AUS" || origin == "DFW" || origin == "SAT" || origin == "CLL" {
            if destination == "HOU" || destination == "AUS" || destination == "DFW" || destination == "SAT" || destination == "CLL" {
                return false
            }
        }
        if origin == "SFO" || origin == "OAK" || origin == "SJC" {
            if destination == "SFO" || destination == "OAK" || destination == "SJC" {
                return false
            }
        }
        return true
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
        print("Searching for: " + textFieldInput!)
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
            searchButton.isEnabled = true
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
