//
//  SettingsViewController.swift
//  AwesomePhotos
//
//  Created by Kha, Pham Minh on 4/24/19.
//

import UIKit
import Firebase

private let reuseIdentifier = "SettingsCell"

class SettingsViewController: UIViewController{
    
    //  MARK: - Properties
    var settingsTableView: UITableView!
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        setupSettingsUI()
    }
    
    // MARK: - Functions
    // Configures Tableview
    func configureSettingsTableView(){
        settingsTableView = UITableView()
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
//        settingsTableView.estimatedRowHeight = 100
        settingsTableView.rowHeight = UITableView.automaticDimension
        settingsTableView.separatorStyle = .none
        settingsTableView.tableFooterView = UIView()
        settingsTableView.register(SettingsCell.self, forCellReuseIdentifier: reuseIdentifier)

        view.addSubview(settingsTableView)
        
        // Configure constraint
        settingsTableView.translatesAutoresizingMaskIntoConstraints = false
        settingsTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        settingsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        settingsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        settingsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
    }
    
    func setupSettingsUI(){
        // Sets up Settings navigation bar
        navigationController?.navigationBar.isHidden = false
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = UIColor(red:0.97, green:0.97, blue:0.97, alpha:1.0)
        navigationController?.navigationBar.tintColor = .mainRed()
        navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor(red:0.85, green:0.22, blue:0.17, alpha:1.0)]
        navigationController?.navigationBar.largeTitleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor(red:0.85, green:0.22, blue:0.17, alpha:1.0)]
        // Set up navigation bar back button
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backHome))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.mainRed()
        
    
        navigationItem.title = "Settings"
        configureSettingsTableView()
    }

}
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource{
    
    // Uses SettingsSectionHeader to count total number of SectionHeader
    func numberOfSections(in tableView: UITableView) -> Int {
        let numOfSec = SettingsSection.allCases.count
        return numOfSec
    }
    
    // Defines number of rows per section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let section = SettingsSection(rawValue: section) else { return 0 }
        
        switch section {
        case .Option: return OptionOptions.allCases.count
        case .Login: return LoginOptions.allCases.count
        case .More: return MoreOptions.allCases.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        // Setting up the sections
        let view = UIView()
        view.backgroundColor = UIColor.white
        
        let sectionHeader = UILabel()
        sectionHeader.font = UIFont.boldSystemFont(ofSize: 13)
        sectionHeader.textColor = UIColor(red: 0.56, green: 0.56, blue: 0.58, alpha: 1)
        sectionHeader.text = SettingsSection(rawValue: section)?.description
        
        
        view.addSubview(sectionHeader)
        
        // Creates autolayout constraints
        sectionHeader.translatesAutoresizingMaskIntoConstraints = false
        sectionHeader.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        sectionHeader.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 19).isActive = true
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?{
        // UIView with darkGray background for section-separators as Section Footer
        let v = UIView(frame: CGRect(x: 0, y:0, width: tableView.frame.width, height: 0.05))
        v.backgroundColor = .white
        return v
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = settingsTableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SettingsCell
        cell.selectionStyle = .default
        cell.isHighlighted = false


        guard let section = SettingsSection(rawValue: indexPath.section) else { return UITableViewCell() }
        
        switch section {
        case .Option:
            let option = OptionOptions(rawValue: indexPath.row)
            cell.sectionType = option

            // "Option" section
            switch option{
            case .cameraUploadSubtitle?, .saveToPhotosSubtitle?:
                cell.textLabel?.textColor = .lightGray
            case .spacing1?, .spacing2?:
                cell.anchor(height: 10)
            default : cell.textLabel?.textColor = .black
            }
        
        case .Login:
            let login = LoginOptions(rawValue: indexPath.row)
            cell.sectionType = login
            
            // "More" section.
        case .More:
            let more = MoreOptions(rawValue: indexPath.row)
            cell.sectionType = more
            
            switch more {
            case .spacing?:
                cell.heightAnchor.constraint(equalToConstant: 10)
            case .deleteAccount?, .signOut?:
                cell.textLabel?.textColor = .red
            default :
                cell.textLabel?.textColor = .black
                cell.textLabel!.lineBreakMode = .byWordWrapping
                cell.textLabel!.numberOfLines = 2
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let section = SettingsSection(rawValue: indexPath.section)
        
        // Add functions to specific rows.
        switch section {

        case .More?:
            let more = MoreOptions(rawValue: indexPath.row)
            switch more{
            case .deleteAccount?:
                navigationController?.pushViewController( DeleteAccountController(), animated: true)
                
            case .signOut?:
                handleSignOut()
            default: break
            }


        case .Login?:
            let login = LoginOptions(rawValue: indexPath.row)
            switch login{
            case .resetPassword?:
                navigationController?.pushViewController( ForgotPasswordController(), animated: true)
            default: break
            }
        default: break
        }
    }
    
    
    func handleSignOut() {
        let alertController = UIAlertController(title: nil, message: "Are you sure you want to sign out?", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { (_) in
        self.signOut()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func alertClose(gesture: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func backHome(){
        let navController = UINavigationController(rootViewController: TabBarController())
        self.present(navController, animated: true, completion: nil)
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            let navController = UINavigationController(rootViewController: LoginController())
            navController.navigationBar.barStyle = .black
            self.present(navController, animated: true, completion: nil)
        } catch let error as NSError{
            print("Failed to sign out with error", error)
            let alert = UIAlertController(title: "Sign out failed", message: "Failed to sign user out", preferredStyle: .alert)
            self.present(alert, animated: true, completion:{
                alert.view.superview?.isUserInteractionEnabled = true
                alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertClose)))
            })
        }
    }
}



