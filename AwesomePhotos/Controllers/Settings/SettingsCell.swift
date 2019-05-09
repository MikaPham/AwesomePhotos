//
//  SettingsCell.swift
//  AwesomePhotos
//
//  Created by Kha, Pham Minh on 4/24/19.
//

import UIKit

class SettingsCell: UITableViewCell {
    
    // MARK: - Properties
    // When a section's sectionType is set, it will retrieve that each section's description and determine whether to add a switch to that section or not.
    var sectionType: SectionType? {
        didSet {
            guard let sectionType = sectionType else { return }
            textLabel?.text = sectionType.description
        }
    }
}
