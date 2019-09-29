//
//  DestinationCell.swift
//  WeekendTrip
//
//  Created by Justin Rodriguez on 9/28/19.
//  Copyright © 2019 Justin Rodriguez. All rights reserved.
//

import UIKit

class DestinationCell: UITableViewCell {

    @IBOutlet weak var DestinationCodeLabel: UILabel!
    @IBOutlet weak var DestinationNameLabel: UILabel!
    @IBOutlet weak var DestinationCellArrow: UILabel!
    @IBOutlet weak var DestinationPriceLabel: UILabel!
    
    func setDestinationCell(roundTrip: RoundTrip) {
        DestinationCodeLabel.text = roundTrip.destinationCode
        DestinationNameLabel.text = roundTrip.destinationName
        DestinationPriceLabel.text = "$" + String(roundTrip.cost)
        DestinationCellArrow.text = "\u{21e8}"
    }
}
