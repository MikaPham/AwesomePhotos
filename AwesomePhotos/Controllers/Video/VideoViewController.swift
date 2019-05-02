import Foundation
import UIKit
import AVKit
import CoreMedia
import AVFoundation
import FirebaseStorage
import MobileCoreServices

class VideoViewController : UIViewController, AVCaptureFileOutputRecordingDelegate
{
    //MARK: - Properties
    let videoStorageReference : StorageReference = {
        return Storage.storage().reference(forURL : "gs://awesomephotos-b794e.appspot.com").child("movieFolder")
    }()
    var captureSession = AVCaptureSession()
    var movieFileOutput = AVCaptureMovieFileOutput()
    var videoCaptureDevice : AVCaptureDevice?
    var myPreviewLayer : AVCaptureVideoPreviewLayer?
    var stopWatch = VideoStopwatch()
    @IBOutlet weak var previewWiew: UIView!
    @IBOutlet weak var timeRecordedLbl: UILabel!
    @IBOutlet weak var switchToCameraButton: UIButton!
    @IBOutlet weak var switchBetweenCameraDevices: UIButton!
    @IBOutlet weak var fileStorage: UIButton!
    @IBOutlet weak var darkButtomView: UIView!
    @IBOutlet weak var recordingButton: UIButton!
    @IBOutlet weak var darkBottomView: UIView!
    
    //MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        clearTmpDir()
        configureSession()
        configureVideoInput()
        configureVideoOutPut()
        configurePreviewLayer()
        startSession()
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
    func startSession()
    {
        self.captureSession.startRunning()
    }
    
    //6. Recording video is pressed and when pressed again, it will stop and upload to firebase storage
    @IBAction func recordVideoButtonPressed(_ sender: UIButton) {
        
        if movieFileOutput.isRecording {
            
            movieFileOutput.stopRecording()
            displayButtonsWhileNotRecording()
            stopWatch.stop()
            
            //Upload video to firestorage
            let uploadRef = videoStorageReference.child("getit.mp4")
            //let uploadVideoTask = uploadRef.putFile(from: URL(fileURLWithPath: self.videoLocation()), metadata: nil)
            let uploadVideoTask = uploadRef.putFile(from: self.videoLocation()!, metadata: nil)
            uploadVideoTask.observe(.progress) { (snapshot) in
                print(snapshot.progress ?? "Progress cancelled")
            }
            uploadVideoTask.resume()
        }
        else { //Starts the recording
            Timer.scheduledTimer(timeInterval: 0.1, target: self,
                                 selector: #selector(updateElapsedTimeLabel(_:)),
                                 userInfo: nil,
                                 repeats: true)
            modifyButtonsWhileRecording()
            stopWatch.start()
            movieFileOutput.connection(with: .video)?.videoOrientation = self.videoOrientation()
            movieFileOutput.maxRecordedDuration = maxRecordedDuration()
            movieFileOutput.startRecording(to: videoLocation()!, recordingDelegate: self)
        }
    }
    
    //7. Stores the video in this temporary directory in the cache
    func videoLocation() -> URL?{
        let directory = NSTemporaryDirectory().appending("getit.mp4")
        return URL(fileURLWithPath: directory)
        
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
    
    //9. Clears the cache so no videos is stored in the cache
    func clearTmpDir(){
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
    func setVideoOrientation()
    {
        if let connection = self.myPreviewLayer?.connection
        {
            if connection.isVideoOrientationSupported{
                connection.videoOrientation = self.videoOrientation()
                self.myPreviewLayer?.frame = self.view.bounds
            }
        }
    }
    
    //12. The different positions the phone can be in, is used in the setVideoOrientation
    func videoOrientation() -> AVCaptureVideoOrientation
    {
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
        switchToCameraButton.isHidden = true
        fileStorage.isHidden = true
        darkBottomView.alpha = 0.2
    }
    
    // Shows the buttons when recording is stopped
    func displayButtonsWhileNotRecording()
    {
        recordingButton.setImage(UIImage(named: "RedRecord"), for: .normal)
        switchToCameraButton.isHidden = false
        fileStorage.isHidden = false
        darkBottomView.alpha = 0.7
    }
    
    //Sets the according position to the screen
    override func viewWillLayoutSubviews() {
        self.setVideoOrientation()
    }
    
    //returns to camera mode
    @IBAction func switchToCameraButtonPressed(_ sender: UIButton) {
        captureSession.stopRunning()
        dismiss(animated: true, completion: nil)
        //performSegue(withIdentifier: "segueToCameraMode", sender: self)
    }
    
    @IBAction func previewLatestFileButtonPressed(_ sender: UIButton) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let previewVideoVC = segue.destination as! PreviewVideoViewController
        previewVideoVC.videoURL = sender as? URL
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
