//
//  ViewController.swift
//  WeekendTrip
//
//  Created by Justin Rodriguez on 6/9/19.
//  Copyright © 2019 Justin Rodriguez. All rights reserved.
//

import UIKit
import SafariServices
import Lottie


class ViewController: UIViewController {
    
    @IBOutlet weak var originInputField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var searchMessage: UILabel!
    @IBOutlet weak var resultsTableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var loadingAnimation: AnimationView!
    
    
    var bookNowLink: String?
    var sessionResultsArray: [ResultWithOriginAndDestination] = []
    var weekendDates: [String] = []
    var viewModel: ViewModel = ViewModel()
    var resultTrips: [RoundTrip] = []
    var weekendDateForLabel: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchButton.setTitle("\u{2315}", for: .normal)
        backButton.setTitle("\u{2315}", for: .normal)
        originInputField.layer.borderWidth = 5
        originInputField.layer.borderColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 1).cgColor
        originInputField.layer.cornerRadius = 20
        resultsTableView.backgroundColor = UIColor.init(red: 175/255, green: 193/255, blue: 216/255, alpha: 1)
        resultsTableView.dataSource = self
        resultsTableView.delegate = self
//        originInputField.placeholder = "JFK"
        originInputField.attributedPlaceholder = NSAttributedString(string: "JFK",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(red: 120/255, green: 158/255, blue: 191/255, alpha: 1)])
        
        configureTapGesture()
        originInputField.delegate = self
        errorMessageLabel.isHidden = true
        resultsTableView.isHidden = true
        backButton.isHidden = true
        loadingAnimation.isHidden = true
        weekendDateForLabel = viewModel.getNearestWeekendDatesForDisplay()
        
    }
    
    func startSearch(origin: String) {
        print("Starting search")
        DispatchQueue.global(qos: .background).async {
            self.resultTrips = self.viewModel.startSearch(origin: origin)
            DispatchQueue.main.async {
                self.sortThroughResults(sortedTrips: self.resultTrips)
            }
        }
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
    
    func setResultScreen(trip: RoundTrip) {
        searchButton.isEnabled = true
        self.resultsTableView.reloadData()
        resultsTableView.isHidden = false
        bookNowLink = trip.link
        originInputField.isHidden = true
        searchMessage.isHidden = true
        searchButton.isHidden = true
        backButton.isHidden = false
        loadingAnimation.isHidden = true
    }

    private func configureTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleTap))
        tapGesture.cancelsTouchesInView = false
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
        var code = textFieldInput?.uppercased()
        code = code!.trimmingCharacters(in: .whitespaces)
        print("Searching for: " + code!)
        self.originInputField.text = code
        if viewModel.stringIsAnAirportCode(input: code ?? "") {
            self.searchMessage.text = ""
            self.originInputField.isHidden = true
            self.searchButton.isHidden = true
            print("now searching")
            loadingAnimation.isHidden = false
            startAnimation()
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
    
    @IBAction func searchAgainButtonPressed(_ sender: Any) {
        resultsTableView.isHidden = true
        backButton.isHidden = true
        loadingAnimation.isHidden = true
        searchMessage.isHidden = false
        originInputField.isHidden = false
        searchButton.isHidden = false
        searchMessage.text = "Wanna travel this weekend? Lookup the cheapest trip from your home airport"
    }
    
    func startAnimation() {
        loadingAnimation.animation = Animation.named("lf30_editor_R0bQvy")
        loadingAnimation.loopMode = .loop
        loadingAnimation.play()
    }
    
}

extension ViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultTrips.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let origin = resultTrips[0]
            let date = weekendDateForLabel
            let cell = resultsTableView.dequeueReusableCell(withIdentifier: "OriginTableCell") as! OriginTableCell
            cell.setOriginCell(origin: origin, date: date)
            return cell
        }
        
        let destination = resultTrips[indexPath.row - 1]
        let cell = resultsTableView.dequeueReusableCell(withIdentifier: "DestinationCell") as! DestinationCell
        cell.setDestinationCell(roundTrip: destination)
        return cell

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 0) {
            return 300
        } else {
            return 200
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row > 0) {
            let url = URL(string: resultTrips[indexPath.row - 1].link)
            let safariVC = SFSafariViewController(url: url!)
            present(safariVC, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension ViewController : UITextFieldDelegate {
    
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        return true
//    }
}
