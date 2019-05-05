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
            switchControl.isHidden = !sectionType.containsSwitch
        }
    }
    
    // Creates the SwitchUI
    lazy var switchControl: UISwitch = {
        let switchControl = UISwitch()
        switchControl.isOn = true
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        switchControl.addTarget(self, action: #selector(handleSwitchAction), for: .valueChanged)
        return  switchControl
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(switchControl)
        switchControl.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        switchControl.rightAnchor.constraint(equalTo: rightAnchor, constant: -15).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    @objc func handleSwitchAction(sender: UISwitch){
        if sender.isOn {
            print("Turned on")
        } else {
            print("Turned off")
        }
    }
    
}
