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

class ProfileViewController: UIViewController, UIScrollViewDelegate  {
    
    // MARK: - Properties
    var docRef: DocumentReference?
    var currentUID: String!
    var profileListener: ListenerRegistration!
    var photosStorage = PieChartDataEntry(value: 150)
    var videosStorage = PieChartDataEntry(value : 100)
    var availStorage: PieChartDataEntry?
    var availableStorage = PieChartDataEntry(value: 0)
    var numberOfStorage = [PieChartDataEntry]()

    lazy var contentViewSize = CGSize (width: self.view.frame.width, height: self.view.frame.height + 100)
    // Create top red background for profile
    lazy var contentView : UIView = {
        let contentView = UIView()
        contentView.backgroundColor = .white
        contentView.frame.size = self.contentViewSize
        return contentView
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red:0.85, green:0.22, blue:0.17, alpha:1.0)
        return view
    }()
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.isScrollEnabled = true
        scrollView.autoresizingMask = .flexibleHeight
        scrollView.backgroundColor = .white
        scrollView.frame = view.bounds
        scrollView.isUserInteractionEnabled = true
        scrollView.contentSize = self.contentViewSize
        return scrollView
    }()
    
    let storagePieChart: PieChartView = {
        let storageChart = PieChartView()
        storageChart.centerText = "Total"
        storageChart.usePercentValuesEnabled = true
        return storageChart
    }()
    
    
    // Create UIImageView for profile and configure its attributes
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "SleepFace")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.masksToBounds = true
        iv.layer.borderWidth = 3
        iv.layer.borderColor = UIColor.white.cgColor
        iv.layer.shadowColor = UIColor.black.cgColor
        iv.layer.shadowOpacity = 1
        iv.layer.shadowOffset = CGSize(width: 0, height: 1)
        iv.layer.shadowRadius = 4
        return iv
    }()
    
    // Create emailLabel
    let emailLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = .white
        return label
    }()
    
    // Create Button to display total Photos
    let totalPhotosButton: CustomTotalButton = {
        let button = CustomTotalButton(type: .system)
        
        // Add action to the button
        button.addTarget(self, action: #selector(ProfileViewController.showAllPhotos), for: .touchUpInside)
        return button
    }()
    
    // Create Button to display total Videos
    let totalVidesButton: CustomTotalButton = {
        let button = CustomTotalButton(type: .system)
        
        // Add action to the button
        button.addTarget(self, action: #selector(ProfileViewController.showAllVideos), for: .touchUpInside)
        
        return button
    }()
    
    // Create Button to display total Shared files
    let totalSharedButton: CustomTotalButton = {
        let button = CustomTotalButton(type: .system)
        
        // Add action to the button
        button.addTarget(self, action: #selector(ProfileViewController.showAllShared), for: .touchUpInside)
        
        return button
    }()
    
    // Create Button to display total Photos
    lazy var stackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [totalPhotosButton, totalVidesButton, totalSharedButton])
        sv.axis = .horizontal
        sv.spacing = 28
        sv.distribution = .fillEqually
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
        func configureView() {
        view.backgroundColor = .white
        
        // add the scroll view to self.view
        view.addSubview(scrollView)
        
        
//        // constrain the scroll view
//        scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
//        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
//        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
//        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
//
        // Add container and it's elements into ProfileVC
        scrollView.addSubview(contentView)
        contentView.addSubview(containerView)
        containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        containerView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, height: 300)
        
        // Add ProfileImageView into container + configure constraints
        containerView.addSubview(profileImageView)
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.anchor(top: containerView.topAnchor, paddingTop: 28, width: 120, height: 120)
        profileImageView.layer.cornerRadius = 120/2
        
        // Add EmailLabel into container + configure constraints
        containerView.addSubview(emailLabel)
        emailLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emailLabel.anchor(top: profileImageView.bottomAnchor, paddingTop: 14)
        
        // Add Buttons into container + configure constraints
        containerView.addSubview(stackView)
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackView.anchor(top: emailLabel.bottomAnchor, paddingTop: 20)
        
        contentView.addSubview(storagePieChart)
        storagePieChart.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        storagePieChart.anchor(top: containerView.bottomAnchor, paddingTop: 44,  width: 400, height: 400)
    }
    
    var totalShared : Int = 0
    
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
            self.totalShared = (myData?["sharedPhotos"] as? [String] ?? [""]).count + (myData?["sharedPhotos"] as? [String] ?? [""]).count
            print(totalPhotos)
            self.updateProfileContentView(userEmail: myEmail!, totalPhotos: totalPhotos, totalVideos: totalVideos, totalShared: self.totalShared)
        }
        
        
        //To lock screen in portrait mode
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.shouldSupportOrientation = .portrait // set desired orientation
        let value = UIInterfaceOrientation.portrait.rawValue // set desired orientation
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    override func viewDidLoad() {
        self.view.layoutIfNeeded()
        super.viewDidLoad()
        view.backgroundColor = .white
        scrollView.delegate = self
        availableStorage.value = 300 - (photosStorage.value + videosStorage.value)
        storagePieChart.chartDescription?.text = "So Cool"
        photosStorage.label = "Photos"
        videosStorage.label = "Videos"
        numberOfStorage = [photosStorage,videosStorage,availableStorage]
        updateChartData()
        configureView()
        setupNavBar()
        fetchCurrentUserData()
    }
    
    func updateChartData(){
        let chartDataSet = PieChartDataSet(entries: numberOfStorage, label: "nil")
        let chartData = PieChartData(dataSet: chartDataSet)
        let colors = [UIColor.mainRed(), UIColor.mainBlue(), UIColor.mainGray()]
        chartDataSet.colors = colors
        storagePieChart.data = chartData
    }
    
    func setupNavBar(){
        
        // Set up navigation bar
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.largeTitleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor.mainRed()]
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
        print(totalShared)
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
        emailLabel.text = Auth.auth().currentUser?.email
        setTotalPhotosLabel(totalPhotos: totalPhotos)
        setTotalVideosLabel(totalVideos: totalVideos)
        setTotalSharedLabel(totalShared: totalShared)
    }
    // Update totalPhotosButton
    func setTotalPhotosLabel(totalPhotos: Int) {
        let attributedTitle = NSMutableAttributedString(string: "\(totalPhotos)", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18), NSAttributedString.Key.foregroundColor: UIColor.black])
        attributedTitle.append(NSAttributedString(string: "\nPhotos", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: UIColor.gray]))
       totalPhotosButton.setAttributedTitle(attributedTitle, for: .normal)
    }
    
    // Update totalVideosButton
    func setTotalVideosLabel(totalVideos: Int) {
        let attributedTitle = NSMutableAttributedString(string: "\(totalVideos)", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18), NSAttributedString.Key.foregroundColor: UIColor.black])
        attributedTitle.append(NSAttributedString(string: "\nVideos", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: UIColor.gray]))
        totalVidesButton.setAttributedTitle(attributedTitle, for: .normal)
    }
    
    // Update totalSharedButton
    func setTotalSharedLabel(totalShared: Int) {
        let attributedTitle = NSMutableAttributedString(string: "\(totalShared)", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18), NSAttributedString.Key.foregroundColor: UIColor.black])
        attributedTitle.append(NSAttributedString(string: "\nShared", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: UIColor.gray]))
        totalSharedButton.setAttributedTitle(attributedTitle, for: .normal)
    }
}

