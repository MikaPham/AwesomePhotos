//
//  ProfileViewController.swift
//  ProfilePage
//
//  Created by Minh Kha Pham on 29/4/19.
//  Copyright © 2019 RMIT. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import Charts

class ProfileViewController: GenericViewController<ProfileView> {
    
    // MARK: - Properties
    var docRef: DocumentReference?
    var currentUID: String!
    var profileListener: ListenerRegistration!
    var photosStorage = PieChartDataEntry(value: 150)
    var videosStorage = PieChartDataEntry(value : 100)
    var availStorage: PieChartDataEntry?
    var availableStorage = PieChartDataEntry(value: 0)
    var numberOfStorage = [PieChartDataEntry]()

    
    // MARK: - LifeCycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentUID = Auth.auth().currentUser?.uid
        docRef = Firestore.firestore().collection("users").document(currentUID!)
        
        // Add listener for any changes to Profile.
        profileListener = docRef?.addSnapshotListener { [unowned self] (snapshot, error) in
            if let error = error {
                print("Oh no! Got an error! \(error.localizedDescription)")
                return
            }
            guard let snapshot = snapshot else { return }
            let myData = snapshot.data()
            let myEmail = Auth.auth().currentUser?.email
            let totalPhotos = (myData?["ownedPhotos"] as? [String] ?? [""]).count
            let totalVideos = (myData?["ownedVideos"] as? [String] ?? [""]).count
            let totalShared = (myData?["sharedPhotos"] as? [String] ?? [""]).count + (myData?["sharedPhotos"] as? [String] ?? [""]).count
            self.updateProfileContentView(userEmail: myEmail!, totalPhotos: totalPhotos, totalVideos: totalVideos, totalShared: totalShared)
        }
        
        
        //To lock screen in portrait mode
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.shouldSupportOrientation = .portrait // set desired orientation
        let value = UIInterfaceOrientation.portrait.rawValue // set desired orientation
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        availableStorage.value = 300 - (photosStorage.value + videosStorage.value)

        contentView.storagePieChart.chartDescription?.text = "So Cool"
        photosStorage.label = "Photos"
        videosStorage.label = "Videos"
        numberOfStorage = [photosStorage,videosStorage,availableStorage]
        updateChartData()

        setupNavBar()
        fetchCurrentUserData()
    }
    
    func updateChartData(){
        let chartDataSet = PieChartDataSet(entries: numberOfStorage, label: "nil")
        let chartData = PieChartData(dataSet: chartDataSet)
        let colors = [UIColor.mainRed(), UIColor.mainBlue(), UIColor.mainGray()]
        chartDataSet.colors = colors
        contentView.storagePieChart.data = chartData
    }
    
    func setupNavBar(){
        
        // Set up navigation bar
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor.mainRed()]
        navigationItem.title = "Profile"
        setupNavigationBarItems()
    }

    func setupNavigationBarItems(){
        
        // Configure and assign settingsButton into Nav bar
        let settingsButton = UIButton(type: .system)
        settingsButton.setImage(#imageLiteral(resourceName: "Settings").withRenderingMode(.alwaysTemplate), for: .normal)
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.anchor(width: 28, height: 28)
        settingsButton.tintColor = .mainRed()

        // Add action to the button
        settingsButton.addTarget(self, action: #selector(ProfileViewController.moveToSettings), for: .touchUpInside)
        
        let editProfileButton = UIButton(type: .system)
        editProfileButton.setImage(#imageLiteral(resourceName: "Edit").withRenderingMode(.alwaysTemplate), for: .normal)
        editProfileButton.anchor(width: 28, height: 28)
        editProfileButton.tintColor = .mainRed()
        
        editProfileButton.addTarget(self, action: #selector(ProfileViewController.moveToEditProfile), for: .touchUpInside)
        
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: settingsButton),
                                              UIBarButtonItem(customView: editProfileButton)]
        
    }

    // Add action to settings button
    @objc func moveToSettings(){
        let navController = UINavigationController(rootViewController: SettingsViewController())
        profileListener.remove()
        self.present(navController, animated: true, completion: nil)
    }
    

    @objc func moveToEditProfile(){
        let editProfileVC = UINavigationController(rootViewController: EditProfileViewController())
        profileListener.remove()
        self.present(editProfileVC, animated: true, completion: nil)
    }
    
    @objc func showAllPhotos(){
        print ("Move to all Photos")
    }
    @objc func showAllVideos(){
        print ("Move to all Videos")
    }
    @objc func showAllShared(){
        print ("Move to all Shared")
    }
    
    
    // MARK: - API
    // Fetch user data.
    func fetchCurrentUserData() {
        // Create reference
        docRef?.getDocument{ [unowned self] (snapshot, error) in
            if let error = error {
                print("Oh no! Got an error! \(error.localizedDescription)")
                return
            }
            guard let snapshot = snapshot else { return }
            let myData = snapshot.data()
            let myEmail = myData?["email"] as? String ?? ""
            let totalPhotos = (myData?["ownedPhotos"] as? [String] ?? [""]).count
            let totalVideos = (myData?["ownedVideos"] as? [String] ?? [""]).count
            let totalShared = (myData?["sharedPhotos"] as? [String] ?? [""]).count + (myData?["sharedPhotos"] as? [String] ?? [""]).count
            self.updateProfileContentView(userEmail: myEmail, totalPhotos: totalPhotos, totalVideos: totalVideos, totalShared: totalShared)
        }
    }
    
    func updateProfileContentView( userEmail: String,totalPhotos: Int, totalVideos: Int, totalShared: Int) {
        contentView.emailLabel.text = Auth.auth().currentUser?.email
        setTotalPhotosLabel(totalPhotos: totalPhotos)
        setTotalVideosLabel(totalVideos: totalVideos)
        setTotalSharedLabel(totalShared: totalShared)
    }
    // Update totalPhotosButton
    func setTotalPhotosLabel(totalPhotos: Int) {
        let attributedTitle = NSMutableAttributedString(string: "\(totalPhotos)", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18), NSAttributedString.Key.foregroundColor: UIColor.black])
        attributedTitle.append(NSAttributedString(string: "\nPhotos", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: UIColor.gray]))
        contentView.totalPhotosButton.setAttributedTitle(attributedTitle, for: .normal)
    }
    
    // Update totalVideosButton
    func setTotalVideosLabel(totalVideos: Int) {
        let attributedTitle = NSMutableAttributedString(string: "\(totalVideos)", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18), NSAttributedString.Key.foregroundColor: UIColor.black])
        attributedTitle.append(NSAttributedString(string: "\nVideos", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: UIColor.gray]))
        contentView.totalVidesButton.setAttributedTitle(attributedTitle, for: .normal)
    }
    
    // Update totalSharedButton
    func setTotalSharedLabel(totalShared: Int) {
        let attributedTitle = NSMutableAttributedString(string: "\(totalShared)", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18), NSAttributedString.Key.foregroundColor: UIColor.black])
        attributedTitle.append(NSAttributedString(string: "\nShared", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: UIColor.gray]))
        contentView.totalSharedButton.setAttributedTitle(attributedTitle, for: .normal)
    }
}

