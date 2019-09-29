//
//  DestinationCell.swift
//  WeekendTrip
//
//  Created by Justin Rodriguez on 9/28/19.
//  Copyright © 2019 Justin Rodriguez. All rights reserved.
//

import UIKit
import SafariServices

class DestinationCell: UITableViewCell {

    @IBOutlet weak var DestinationCodeLabel: UILabel!
    @IBOutlet weak var DestinationNameLabel: UILabel!
    @IBOutlet weak var DestinationPriceLabel: UILabel!
    @IBOutlet weak var DestinationCellArrow: UILabel!
    var link: String = ""
    
    func setDestinationCell(roundTrip: RoundTrip) {
        DestinationCodeLabel.text = roundTrip.destinationCode
        DestinationNameLabel.text = roundTrip.destinationName
        DestinationPriceLabel.text = "$" + String(roundTrip.cost)
        DestinationCellArrow.text = "\u{21e8}"
        link = roundTrip.link
    }
    
}
