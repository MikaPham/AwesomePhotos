import Foundation
import UIKit
import AVKit
import CoreMedia
import AVFoundation
import FirebaseStorage
import Firebase
import MobileCoreServices

class VideoViewController : UIViewController, AVCaptureFileOutputRecordingDelegate
{
    //MARK: - Properties
    
    var captureSession = AVCaptureSession()
    var movieFileOutput = AVCaptureMovieFileOutput()
    var videoCaptureDevice : AVCaptureDevice?
    var myPreviewLayer : AVCaptureVideoPreviewLayer?
    var stopWatch = VideoStopwatch()
    @IBOutlet weak var previewWiew: UIView!
    @IBOutlet weak var timeRecordedLbl: UILabel!
    @IBOutlet weak var switchToCameraBtn: UIButton!
    @IBOutlet weak var fileStorage: UIButton!
    @IBOutlet weak var darkButtomView: UIView!
    @IBOutlet weak var recordingButton: UIButton!
    @IBOutlet weak var darkBottomView: UIView!
    
    //MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        //clearTmpDir()
        configureSession()
        configureVideoInput()
        configureVideoOutPut()
        configurePreviewLayer()
        startSession()
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    //MARK: - Methods
    
    //1. Configures a capture session
    func configureSession(){
        self.captureSession.sessionPreset = .high
    }
    
    //2. Configures the video input
    func configureVideoInput()
    {
        let captureDevice = AVCaptureDevice.default(for: .video)
        
        do{
            let deviceInput = try AVCaptureDeviceInput(device: captureDevice!)
            captureSession.beginConfiguration()
            
            if captureSession.canAddInput(deviceInput) == true
            {
                captureSession.addInput(deviceInput)
            }
        }catch{
            print("No input found")
        }
    }
    
    //3. Configures the video output
    func configureVideoOutPut(){
        
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
    func configurePreviewLayer(){
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
    
    //6. Recording video is pressed and when pressed again, it will stop and upload to firebase storage
    @IBAction func recordVideoButtonPressed(_ sender: UIButton) {
        let id = UUID()
        let videoName = id.uuidString
        
        if movieFileOutput.isRecording {
            movieFileOutput.stopRecording()
            displayButtonsWhileNotRecording()
            stopWatch.stop()
            
            //Upload video to firestorage
            let data = ["name": videoName + ".mov"]
            
            reference = db.collection("medias").addDocument(data: data) {(error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("Upload to Firestore finished")
                }}
            
            for (_ , value) in PhotoTypesConstants{
                let videoStorageReference : StorageReference = {
                    return Storage.storage().reference(forURL : "gs://awesomephotos-b794e.appspot.com/").child("User/doc12/Uploads/Video/\((reference?.documentID)!)/\(value)")
                }()
                
                let uploadImageRef = videoStorageReference.child(id.uuidString + "-\(value).mov")
                
                //let uploadRef = videoStorageReference.child("workplease.mp4")
                let storageMetaData = StorageMetadata()
                storageMetaData.contentType = "video/mov"
                
                
                let uploadVideoTask = uploadImageRef.putFile(from: videoLocation()!, metadata: storageMetaData) { (metadata, error) in
                    if (error != nil) {
                        print("Error here")
                        print(error?.localizedDescription as Any)
                    }
                    else {
                        print("Upload completed! Metadata: \(metadata!)")
                        print("Contenttype : \(metadata?.contentType ?? "No contenttype found")")
                    }}
                
                uploadVideoTask.observe(.progress) { (snapshot) in print("Hello",snapshot.progress ?? "Progress cancelled")  }
                uploadVideoTask.resume()
            }
        }
            
        else{ //Starts the recording and the timer
            Timer.scheduledTimer(timeInterval: 0.1, target: self,
                                 selector: #selector(updateElapsedTimeLabel(_:)),
                                 userInfo: nil,
                                 repeats: true)
            modifyButtonsWhileRecording()
            stopWatch.start()
            movieFileOutput.connection(with: .video)?.videoOrientation = self.videoOrientation()
            movieFileOutput.maxRecordedDuration = maxRecordedDuration()
            movieFileOutput.startRecording(to: self.videoLocation()!, recordingDelegate: self)
            //            print(movieFileOutput.metadata?., "Description here")
        }
    }
    
    //7. Stores the video in this temporary directory in the cache
    func videoLocation() -> URL?{
        let directory = NSTemporaryDirectory().appending("work")
        let videoURL = URL(fileURLWithPath: directory).appendingPathExtension("mov")
        print(videoURL)
        return videoURL
    }
    
    //MARK: - Helper Methods
    
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
                try FileManager.default.removeItem(at: url)
            }
            print("\(removed) temporary files removed")
        } catch {
            print(error)
            print("\(removed) temporary files removed")
        }
    }
    
    //10. Sets the duration time to the maximum of 5 min
    func maxRecordedDuration() -> CMTime{
        let recordtime : Int64 = 300
        let preferedTimescale : Int32 = 1
        return CMTimeMake(value: recordtime, timescale: preferedTimescale)
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
//        switchToCameraBtn.isHidden = true
        fileStorage.isHidden = true
        darkBottomView.alpha = 0.2
    }
    
    // Shows the buttons when recording is stopped
    func displayButtonsWhileNotRecording(){
        recordingButton.setImage(UIImage(named: "RedRecord"), for: .normal)
        fileStorage.isHidden = true
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
        }
    }
    
    //Protocol for AVCaptureFileOutputRecordingDelegate.. Needed for it to work
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if (error != nil){
            print("Error found : Could not record video")
        }
        else{
            let videoRecorded = videoLocation()! as URL
            performSegue(withIdentifier: "segueToPreviewVideo", sender: videoRecorded)
        }
    }
}
