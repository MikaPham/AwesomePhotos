import Foundation
import UIKit
import AVKit
import CoreMedia
import AVFoundation
import FirebaseStorage
import Firebase
import FirebaseFirestore
import MobileCoreServices
import MediaWatermark

class VideoViewController : UIViewController, AVCaptureFileOutputRecordingDelegate, UploadVideoDelegate
{
    //MARK: - Properties
    
    var captureSession = AVCaptureSession()
    var movieFileOutput = AVCaptureMovieFileOutput()
    var videoCaptureDevice : AVCaptureDevice?
    var myPreviewLayer : AVCaptureVideoPreviewLayer?
    var stopWatch = VideoStopwatch()
    @IBOutlet weak var timeRecordedLbl: UILabel!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var switchToCameraBtn: UIButton!
    @IBOutlet weak var fileStorage: UIButton!
    @IBOutlet weak var recordingButton: UIButton!
    @IBOutlet weak var darkBottomView: UIView!
    
    let db = Firestore.firestore()
    let userUid = Auth.auth().currentUser?.uid
    let userEmail = Auth.auth().currentUser?.email
    
    //MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSession()
        configureVideoInput()
        configureVideoOutPut()
        configurePreviewLayer()
        clearTmpDir()
        startSession()
        navigationController?.hidesBarsOnTap = true

    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    //MARK: - Methods
    
    /// RECORDING VIDEO
    //1. Configures a capture session
    func configureSession(){
        self.captureSession.sessionPreset = .high
    }
    
    //2. Configures the video input
    func configureVideoInput() {
        let videoCaptureDevice = AVCaptureDevice.default(for: .video)
        let audioCaptureDevice = AVCaptureDevice.default(for: .audio)
        do{
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoCaptureDevice!)
            let audioDeviceInput = try AVCaptureDeviceInput(device: audioCaptureDevice!)
            captureSession.beginConfiguration()
            
            if captureSession.canAddInput(videoDeviceInput) == true  && captureSession.canAddInput(audioDeviceInput) == true
            {
                captureSession.addInput(videoDeviceInput)
                captureSession.addInput(audioDeviceInput)
            }
        }catch{
            print("No input found")
        }
    }
    
    //3. Configures the video output
    func configureVideoOutPut() {
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange as UInt32)] as [String : Any]
        dataOutput.alwaysDiscardsLateVideoFrames = true
        
        if captureSession.canAddOutput(dataOutput) == true
        {
            captureSession.addOutput(dataOutput)
        }
        captureSession.commitConfiguration()
        setVideoOrientation()
        self.captureSession.addOutput(self.movieFileOutput)
    }
    
    //4. Configures the preview layer
    func configurePreviewLayer() {
        myPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        myPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        myPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        myPreviewLayer?.frame = self.view.frame
        self.view.layer.insertSublayer(myPreviewLayer!, at: 0)
    }
    
    //5. Starts the capture session
    func startSession() {
        self.captureSession.startRunning()
    }
    
    var reference : DocumentReference? = nil
    
    func videoName() -> String{
        let id = UUID()
        let videoName = id.uuidString
        return videoName
    }
    
    func prepareWatermark() -> MediaItem {
        let video = MediaItem(url: self.videoLocation()!)
        let logoImage = UIImage(named: "AwesomeLogo")
        let firstElement = MediaElement(image: logoImage!)
        firstElement.frame = CGRect(x: 10, y: video!.size.height-200, width: logoImage!.size.width/3, height: logoImage!.size.height/3)
        video!.add(elements: [firstElement])
        return video!
    }
    
    //6. Recording video is pressed and when pressed again, it will stop and upload to firebase storage
    @IBAction func recordVideoButtonPressed(_ sender: UIButton) {
        
       
        print(movieFileOutput.isRecording)
       
        if movieFileOutput.isRecording {
            movieFileOutput.stopRecording()
            displayButtonsWhileNotRecording()
            stopWatch.stop()
        }
            
        else {
            // Start Recording
            Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateElapsedTimeLabel(_:)), userInfo: nil, repeats: true)
            modifyButtonsWhileRecording()
            stopWatch.start()
            movieFileOutput.connection(with: .video)?.videoOrientation = self.videoOrientation()
            movieFileOutput.startRecording(to: self.videoLocation()!, recordingDelegate: self)
        }
    }
    
    func uploadVideo() {
        //Upload video to firestorage
        let id = UUID()
        let videoName = id.uuidString
        let data: [String:Any] = ["name": videoName + ".mov","owners":[userUid],"sharedWith":[], "sharedWM":[]]
        reference = db.collection("medias").addDocument(data: data) {(error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Upload to Firestore finished")
                
                // Create FireStore path
                for (key , value) in PhotoTypesConstants{
                    let videoStorageReference : StorageReference = {
                        return Storage.storage().reference(forURL : "gs://awesomephotos-b794e.appspot.com/").child("User/\(self.userUid!)/Uploads/Medias/\((self.reference?.documentID)!)/\(value)")  }()
                    
                    let storageMetaData = StorageMetadata()
                    storageMetaData.contentType = "video/quicktime"
                    
                    // Upload to Storage
                    if key == "WatermarkPhoto" {
                        let video = self.prepareWatermark()
                        let mediaProcessor = MediaProcessor()
                        mediaProcessor.processElements(item: video){(result, error) -> () in
                            if let error = error {
                                print(error.localizedDescription)
                            } else {
                                let uploadVideoPath = videoStorageReference.child(videoName + "-\(value).mov")
                                _ = uploadVideoPath.putFile(from: result.processedUrl!, metadata: storageMetaData){metadata, error in
                                    if (error != nil) {
                                        print("Error is", error as Any)
                                    } else {
                                        print("Upload to storage finished")
                                        
                                        let uploadPath: [String:Any] = ["pathTo\(value.uppercased())":uploadVideoPath.fullPath]
                                        self.db.collection("medias").document(self.reference!.documentID).updateData(uploadPath) {
                                            err in
                                            if let err = err {
                                                print("Error writing document: \(err)")
                                            } else {
                                                print("Path to storage sucessfully set. ")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        let uploadVideoPath = videoStorageReference.child(videoName + "-\(value).mov")
                        _ = uploadVideoPath.putFile(from: self.videoLocation()!, metadata: storageMetaData){metadata, error in
                            if (error != nil) {
                                print("Error is", error as Any)
                            } else {
                                print("Upload to storage finished")
                                
                                let uploadPath: [String:Any] = ["pathTo\(value.uppercased())":uploadVideoPath.fullPath]
                                self.db.collection("medias").document(self.reference!.documentID).updateData(uploadPath) {
                                    err in
                                    if let err = err {
                                        print("Error writing document: \(err)")
                                    } else {
                                        print("Path to storage sucessfully set. ")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        self.db.collection("users").document(userUid!).updateData(
            ["ownedVideos":FieldValue.arrayUnion([reference!.documentID])])
    }
    
   
    
    //7. Stores the video in this temporary directory in the cache
    func videoLocation() -> URL? {
        let directory = NSTemporaryDirectory().appending("tempWork")
        let videoURL = URL(fileURLWithPath: directory).appendingPathExtension("mov")
        do {
            let data = try Data(contentsOf: videoURL)
            print("data is", data)
        } catch  _ { }
        return videoURL
    }
    
    //8. Updates the time recorded and resets it, if video stopped recording
    @objc func updateElapsedTimeLabel(_ timer: Timer) {
        if stopWatch.isRunning {
            timeRecordedLbl.text = stopWatch.elapsedTimeAsString
        } else {
            timeRecordedLbl.text = "00:00"
            timer.invalidate()
        }
    }
    
    // Handle BackButtonPressed
    @IBAction func backButtonPressed(_ sender: UIButton) {
        let customBtnStoryboard: UIStoryboard = UIStoryboard(name: "TabBar", bundle: nil)
        let customBtnController: CustomButton = customBtnStoryboard.instantiateViewController(withIdentifier: "CustomButton") as! CustomButton
        let navController = UINavigationController(rootViewController: customBtnController)
        self.present(navController, animated: true, completion: nil)
    }
    
    //9. Clears the cache so no videos is stored in the cache
    func clearTmpDir() {
        var removed: Int = 0
        do {
            let tmpDirURL = URL(string: NSTemporaryDirectory())!
            let tmpFiles = try FileManager.default.contentsOfDirectory(at: tmpDirURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            // print("\(tmpFiles.count") temporary files found")
            for url in tmpFiles {
                removed += 1
                print(url.absoluteString)
                try FileManager.default.removeItem(at: url)
            }
            print("\(removed) temporary files removed")
        } catch {
            print(error)
            print("\(removed) temporary files removed")
        }
    }
    
    //11. Sets the current rotation of the phone
    func setVideoOrientation() {
        if let connection = self.myPreviewLayer?.connection
        {
            if connection.isVideoOrientationSupported{
                connection.videoOrientation = self.videoOrientation()
                self.myPreviewLayer?.frame = self.view.bounds
            }
        }
    }
    
    //12. The different positions the phone can be in, is used in the setVideoOrientation
    func videoOrientation() -> AVCaptureVideoOrientation {
        var videoOrientation : AVCaptureVideoOrientation!
        
        let orientation : UIDeviceOrientation = UIDevice.current.orientation
        
        switch orientation {
        case .portrait:
            videoOrientation = .portrait
            break
        case .landscapeRight:
            videoOrientation = .landscapeLeft
            break
        case .landscapeLeft:
            videoOrientation = .landscapeRight
            break
        case .portraitUpsideDown:
            videoOrientation = .portrait
            break
        default:
            videoOrientation = .portrait
        }
        return videoOrientation
    }
    
    // Hides the buttons of the interface to make it more clean while recording
    func modifyButtonsWhileRecording(){
        recordingButton.setImage(UIImage(named: "shutter"), for: .normal)
        switchToCameraBtn.isHidden = true
        fileStorage.isHidden = true
        closeBtn.isHidden = true
        darkBottomView.alpha = 0.2
    }
    
    // Shows the buttons when recording is stopped
    func displayButtonsWhileNotRecording(){
        recordingButton.setImage(UIImage(named: "RedRecord"), for: .normal)
        switchToCameraBtn.isHidden = false
        fileStorage.isHidden = false
        closeBtn.isHidden = false
        darkBottomView.alpha = 0.7
    }
    
    //Sets the according position to the screen
    override func viewWillLayoutSubviews() {
        self.setVideoOrientation()
    }
    
    //returns to camera mode
    @IBAction func switchToCameraButtonPressed(_ sender: UIButton) {
        captureSession.stopRunning()
        performSegue(withIdentifier: "segueToCamera", sender: self)
    }
    
    
    @IBAction func previewLatestFileButtonPressed(_ sender: UIButton) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueToPreviewVideo" {
            let previewVideoVC = segue.destination as! PreviewVideoViewController
            previewVideoVC.videoURL = sender as? URL
            previewVideoVC.delegate = self
        }
    }
    
    //Protocol for AVCaptureFileOutputRecordingDelegate.. Needed for it to work
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if (error != nil){
            print("Error found : Could not record video")
        }
        else{
            let videoRecorded = videoLocation()! as URL
            
            let autoUpload = defaults.bool(forKey: keys.autoUpload)
            let autoSave = defaults.bool(forKey: keys.autoSave)
            
            if autoSave == true && autoUpload == true {
                uploadVideo()
                print("Video Saved and Uploaded")
            } else if autoUpload == true && autoSave == false {
                uploadVideo()
                print("Video Uploaded")
            } else {
                performSegue(withIdentifier: "segueToPreviewVideo", sender: videoRecorded)
                print("Going To Preview")
            }
            
            
        }
    }
}
