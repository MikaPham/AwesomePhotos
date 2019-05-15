//
//  SharedViewController.swift
//  AwesomePhotos
//
//  Created by Bob on 15/5/19.
//

import UIKit
import MapKit

class SharedViewController: UIViewController {
    
    // - Outlets
    let label: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.mainRed()
        return label
    }()
    
    // - Constants
    private let locationManager = LocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(label)
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        self.setCurrentLocation()
    }
    
    private func setCurrentLocation() {
        
        guard let exposedLocation = self.locationManager.exposedLocation else {
            print("*** Error in \(#function): exposedLocation is nil")
            return
        }
        
        self.locationManager.getPlace(for: exposedLocation) { placemark in
            guard let placemark = placemark else { return }
            print(placemark)
            var output = "Our location is:"
            if let country = placemark.country {
                output = output + "\n1. \(country)"
            }
            if let state = placemark.subLocality {
                output = output + "\n2. \(state)"
            }
            if let town = placemark.locality {
                output = output + "\n3. \(town)"
            }
            self.label.text = output
            print(output)
        }
    }
}
