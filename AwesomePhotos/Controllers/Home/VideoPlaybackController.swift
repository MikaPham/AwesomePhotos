import UIKit
import AVKit
import Firebase
import Photos
import FirebaseFirestore


class VideoPlaybackController : UIViewController
{
    //MARK: - Properties
    var videoURL : URL!
    var avPlayer : AVPlayer?
    @IBOutlet weak var centerPlayButton: UIButton!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var totalDurationLabal: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    
    var filePath: String?
    var owned: Bool?
    var shared: Bool?
    var wm: Bool?
    var thumbnail: UIImage?
    var videoUid: String?
    let db = Firestore.firestore()
    let userUid = Auth.auth().currentUser?.uid
    
    //MARK: - UI
    override func handleGoBack() {
        DispatchQueue.main.async {
            let customBtnStoryboard: UIStoryboard = UIStoryboard(name: "TabBar", bundle: nil)
            let customBtnController: CustomButton = customBtnStoryboard.instantiateViewController(withIdentifier: "CustomButton") as! CustomButton
            customBtnController.returnFromShared = self.owned! ? false : true
            let navController = UINavigationController(rootViewController: customBtnController)
            self.present(navController, animated: true, completion: nil)
        }
    }
    
    fileprivate func configureNavBar() {
        configureNavBar(title: "Video")
        navigationItem.largeTitleDisplayMode = .never

        let moreButton = UIButton(type: .system)
        moreButton.setImage(#imageLiteral(resourceName: "MoreOptions"), for: .normal)
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        moreButton.tintColor = .mainRed()
        
        moreButton.addTarget(self, action: #selector(showMoreActionSheet), for: .touchUpInside)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: moreButton)
        navigationItem.rightBarButtonItem?.tintColor = UIColor.mainRed()
    }
    
    func setupNavigationBarItems(){
        // Configure and assign settingsButton into Nav bar
        let backButton = UIButton(type: .system)
        backButton.setTitle("          ", for: .normal)
        backButton.setImage(#imageLiteral(resourceName: "Path"), for: .normal)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.tintColor = .mainRed()
        
        backButton.addTarget(self, action: #selector(OwnedImageViewController.handleGoBack), for: .touchUpInside)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem?.tintColor = UIColor.mainRed()
    }
    
    @objc func goBack(){
        navigationController?.popViewController(animated: true)
        
    }
    
    
    //MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        centerPlayButton.isHidden = true
        configureNavBar()
        configurePreviewView()
        trackTimeProgress()
        setupNavigationBarItems()
    }
    
    //MARK: - Methods
    @objc func showMoreActionSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let sharePhotoAction = UIAlertAction(title: "Share", style: .default) {[unowned self] action in
            self.showShareOptions()
        }
        let deleteAction = UIAlertAction(title: "Delete video", style: .destructive) { action in
            let deleteAlert = UIAlertController(title: "Delete this video?", message: "This will only delete this copy of the video for you. It will still be visible for photo owners and shared users.", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) {[unowned self] action in
                self.deleteVideo()
            }
            deleteAlert.addAction(cancelAction)
            deleteAlert.addAction(deleteAction)
            self.present(deleteAlert, animated: true, completion: nil)
        }
        let infoAction = UIAlertAction(title: "Get info", style: .default) { action in
            self.getInfo()
        }
        let downloadAction = UIAlertAction(title: "Download", style: .default) {[unowned self] action in
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: self.videoURL!)
            }) { saved, error in
                if saved {
                    let fetchOptions = PHFetchOptions()
                    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                    
                    // After uploading we fetch the PHAsset for most recent video and then get its current location url
                    
                    let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions).lastObject
                    PHImageManager().requestAVAsset(forVideo: fetchResult!, options: nil, resultHandler: { (avurlAsset, audioMix, dict) in
                        let newObj = avurlAsset as! AVURLAsset
                        print(newObj.url)
                        // This is the URL we need now to access the video from gallery directly.
                    })
                }
            }
        }
        let cancel = UIAlertAction(title:"Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(cancel)
        if owned! {
            actionSheet.addAction(sharePhotoAction)
        }
        actionSheet.addAction(infoAction)
        actionSheet.addAction(downloadAction)
        actionSheet.addAction(deleteAction)
        present(actionSheet, animated: true, completion: nil)
    }
    
    fileprivate func getInfo() {
        self.db.collection("medias").document(videoUid!).getDocument{document, error in
            if let document = document, document.exists {
                guard let data = document.data() else { return }
                let infoStoryboard: UIStoryboard = UIStoryboard(name: "Info", bundle: nil)
                let infoController: InfoController = infoStoryboard.instantiateViewController(withIdentifier: "InfoController") as! InfoController
                infoController.infoArray.append(data["name"] as! String)
                let size = data["size"] as! Double
                infoController.infoArray.append(NSString(format: "%.2f MB", size/1000000.0) as String)
                infoController.infoArray.append("\(data["height"] ?? 0) x \(data["width"] ?? 0)")
                let location = data["location"] as! [String:String]
                let locationString = "\(location["ward"] ?? ""), \(location["town"] ?? ""), \(location["country"] ?? "")"
                infoController.infoArray.append(locationString)
                infoController.infoArray.append(self.owned! ? "Yes" : "No")
                infoController.selectedImage = self.thumbnail
                self.navigationController?.pushViewController(infoController, animated: true)
            } else {
                print("Document does not exist")
                return
            }
        }
    }
    
    fileprivate func deleteVideo() {
        if self.owned! {
            self.db.collection("medias").document(self.videoUid!).updateData(
                ["owners" : FieldValue.arrayRemove([self.userUid!])]
            )
        } else if self.shared! {
            self.db.collection("medias").document(self.videoUid!).updateData(
                ["sharedWith" : FieldValue.arrayRemove([self.userUid!])]
            )
        } else if self.wm! {
            self.db.collection("medias").document(self.videoUid!).updateData(
                ["sharedWM" : FieldValue.arrayRemove([self.userUid!])]
            )
        }
        self.handleGoBack()
    }
    
    func showShareOptions() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let editPerAction = UIAlertAction(title: "Edit permission", style: .default) {[unowned self] action in
            let editStoryboard: UIStoryboard = UIStoryboard(name: "EditPermission", bundle: nil)
            let editPermissionController: EditPermissionController = editStoryboard.instantiateViewController(withIdentifier: "EditPermissionController") as! EditPermissionController
            editPermissionController.photoUid = self.videoUid!
            editPermissionController.isImage = false
            self.navigationController?.pushViewController(editPermissionController, animated: true)
        }
        let shareInAppAction = UIAlertAction(title: "Share in-app", style: .default) {[unowned self] action in
            let shareStoryboard: UIStoryboard = UIStoryboard(name: "Sharing", bundle: nil)
            let shareController: ShareController = shareStoryboard.instantiateViewController(withIdentifier: "ShareController") as! ShareController
            shareController.isImage = false
            shareController.photoUid = self.videoUid!
            shareController.thumbnail = self.thumbnail
            self.navigationController?.pushViewController(shareController, animated: true)
        }
        let copyLinkAction = UIAlertAction(title: "Copy link", style: .default) {[unowned self] action in
            UIPasteboard.general.url = self.videoURL
            self.present(AlertService.basicAlert(imgName: "SmileFace", title: "Link Copied", message: "Download link for the non-waterarked copy has been copied to clipboard."), animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title:"Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(cancel)
        actionSheet.addAction(shareInAppAction)
        actionSheet.addAction(editPerAction)
        actionSheet.addAction(copyLinkAction)
        present(actionSheet, animated: true, completion: nil)
    }
    
    //1. Sets up the video preview configuration
    fileprivate func configurePreviewView(){
        avPlayer = AVPlayer(url: videoURL)
        
        //Checks to see if video has loaded and is ready to be played
        avPlayer!.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
        
        //View setup
        let avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.frame = view.bounds
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoView.layer.insertSublayer(avPlayerLayer, at: 0)
        
        view.layoutIfNeeded()
        
        let playerItem = AVPlayerItem(url: videoURL as URL)
        avPlayer!.replaceCurrentItem(with: playerItem)
        avPlayer!.pause()
    }
    
    //2. Checks to see if the video has been loaded and is ready to play
        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            if keyPath == "currentItem.loadedTimeRanges"{
                centerPlayButton.isHidden = false
            }
        }
    
    //2. Tracks the duration of time played in the video
    fileprivate func trackTimeProgress(){
        
        //Defines the seconds to increment by 1+
        let interval = CMTime(value: 1, timescale: 1)
        
        //sets a timer that increment with 1 until video is finished
        avPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: nil, using: { (progressTime) in
            
            //Updates the current time label
            let seconds = CMTimeGetSeconds(progressTime)
            let secondsText = String(format: "%02d", Int(seconds) % 60)
            let minutesText = String(format: "%02d", Int(seconds) / 60)
            self.currentTimeLabel.text = "\(minutesText):\(secondsText)"
            
            // Moving the thumb on the slider
            if let duration = self.avPlayer?.currentItem?.duration{
                let durationSeconds = CMTimeGetSeconds(duration)
                
                self.slider.value = Float(seconds / durationSeconds)
                
            }
        })
        let videoPlayed = NSNotification.Name.AVPlayerItemDidPlayToEndTime
        
        //Observes whether the video is done, and sets the video back to 0 and to played again
        NotificationCenter.default.addObserver(forName: videoPlayed, object: nil, queue: nil) { (notification) in
            self.avPlayer?.seek(to: CMTime.zero)
            self.isPlaying = false
            self.avPlayer?.pause()
            self.centerPlayButton.setImage(UIImage(named: "Play"), for: .normal)
        }
    }
    
    var isPlaying = false
    
    //3. Start the video when pressed and stops it again
    @IBAction func playButtonPressed(_ sender: UIButton) {
        
        //Sets the duration of the entire video
        if let duration = avPlayer?.currentItem?.duration{
            let seconds = CMTimeGetSeconds(duration)
            if seconds.isNaN { return }
            let secondsDisplayed = String(format: "%02d", Int(seconds) % 60)
            let minutesDisplayed = String(format: "%02d", Int(seconds) / 60)
            totalDurationLabal.text = "\(minutesDisplayed):\(secondsDisplayed)"
        }
        
        if isPlaying == false{
            avPlayer!.play()
            centerPlayButton.setImage(UIImage(named: "Pause"), for: .normal)
            centerPlayButton.tintColor = .white
            slider.thumbTintColor = .clear
            isPlaying = true
        }
        else{
            avPlayer!.pause()
            centerPlayButton.setImage(UIImage(named: "Play"), for: .normal)
            centerPlayButton.tintColor = .mainRed()
            isPlaying = false
        }
    }
    
    //4. Set new playtime of video with slider
    @IBAction func changeSliderDurationPressed(_ sender: UISlider) {
        slider.addTarget(self, action: #selector(handleSliderChange), for: .valueChanged)
    }
    
    //5. Handles the slider logic to a specific time in the slider
    @objc func handleSliderChange(){
        
        //Gets the total duration of the video
        if let duration = avPlayer?.currentItem?.duration{
            let totalDuration = CMTimeGetSeconds(duration)
            
            let sliderValue = Float64(slider.value) * totalDuration
            let seekTime = CMTime(value: Int64(sliderValue), timescale: 1)
            
            //sets the video to the selected slider value
            avPlayer?.seek(to: seekTime, completionHandler: { (completedSeek) in
            })
        }
    }
    
    //6.  Hides or shows controls depending on touch
    var isDismissed = false
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
//        centerPlayButton.isHidden = false
        if isDismissed == false {
            centerPlayButton.isHidden = true
            slider.isHidden = true
            totalDurationLabal.isHidden = true
            currentTimeLabel.isHidden = true
            slider.thumbTintColor = .clear
            self.navigationController?.navigationBar.isHidden = true
            isDismissed = true
        }
        else{
            centerPlayButton.isHidden = false
            slider.isHidden = false
            totalDurationLabal.isHidden = false
            currentTimeLabel.isHidden = false
            slider.thumbTintColor = .red
            self.navigationController?.navigationBar.isHidden = false
            isDismissed = false
        }
    }
    
   
}
