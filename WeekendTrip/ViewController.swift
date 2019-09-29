//
//  ViewController.swift
//  WeekendTrip
//
//  Created by Justin Rodriguez on 6/9/19.
//  Copyright © 2019 Justin Rodriguez. All rights reserved.
//

import UIKit
import SafariServices


class ViewController: UIViewController {
    
    @IBOutlet weak var originInputField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var searchMessage: UILabel!
    @IBOutlet weak var resultsTableView: UITableView!
    
    var bookNowLink: String?
    var sessionResultsArray: [ResultWithOriginAndDestination] = []
    var weekendDates: [String] = []
    var viewModel: ViewModel = ViewModel()
    var resultTrips: [RoundTrip] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        toSymbolLabel.text = "\u{21C6}"
//        self.originInputField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters
        searchButton.setTitle("\u{26B2}", for: .normal)
        originInputField.layer.borderWidth = 5
        originInputField.layer.borderColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 1).cgColor
        originInputField.layer.cornerRadius = 20
        resultsTableView.backgroundColor = UIColor.init(red: 175/255, green: 193/255, blue: 216/255, alpha: 1)
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        resultsTableView.rowHeight = 200
        
        configureTapGesture()
        originInputField.delegate = self
        errorMessageLabel.isHidden = true
        resultsTableView.isHidden = true
        
    }
    
    func startSearch(origin: String) {
        print("Starting search")
        resultTrips = viewModel.startSearch(origin: origin)
        sortThroughResults(sortedTrips: resultTrips)
    }
    
    func sortThroughResults(sortedTrips: [RoundTrip]) {
        print("Starting sorting")
        if sortedTrips.count <= 0 {
               handleError()
        } else {
            print(sortedTrips[0].destinationCode)
            self.setResultScreen(trip: sortedTrips[0])
        }
    }
    
    func handleError() {
        self.errorMessageLabel.text = "Oops something went wrong. Check your internet connection and try again."
        self.errorMessageLabel.isHidden = false
        self.searchButton.isEnabled = true
    }
    
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
//        self.priceLabel.text = "$" + String(trip.cost)
//        self.destinationLabel.text = trip.destinationCode
//        self.originLabel.text = trip.originCode
//        self.destinationFullName.text = trip.destinationName
//        self.originFullName.text = trip.originName
//        self.tripDateLabel.text = viewModel.getNearestWeekendDatesForDisplay()
//        flightCard.isHidden = false
//        searchAgainButton.isHidden = false
        self.resultsTableView.reloadData()
        resultsTableView.isHidden = false
        bookNowLink = trip.link
        originInputField.isHidden = true
        searchMessage.isHidden = true
        searchButton.isHidden = true
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
        let code = textFieldInput?.uppercased()
        print("Searching for: " + code!)
        self.originInputField.text = code
        if stringIsAnAirportCode(input: code ?? "") {
//            self.originLabel.text = code
            self.searchMessage.text = "Searching for trips from " + code! + "..."
            self.originInputField.isHidden = true
            self.searchButton.isHidden = true
            print("now searching")
            startSearch(origin: code ?? "")
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
    
    @IBAction func searchAgainButtonPressed(_ sender: Any) {
        resultsTableView.isHidden = true
//        searchAgainButton.isHidden = true
        searchMessage.isHidden = false
        originInputField.isHidden = false
        searchButton.isHidden = false
        searchMessage.text = "Wanna travel this weekend? Lookup the cheapest trip from your city"
    }
    
    private func stringIsAnAirportCode(input: String) -> Bool {
        for destination in possibleDestinations {
            if input == destination.key {
                return true
            }
        }
        return false
    }
    
}

extension ViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultTrips.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let destination = resultTrips[indexPath.row]
        let cell = resultsTableView.dequeueReusableCell(withIdentifier: "DestinationCell") as! DestinationCell
        cell.setDestinationCell(roundTrip: destination)
        return cell
    }
    
    
}

extension ViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
