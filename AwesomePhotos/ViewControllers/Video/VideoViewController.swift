import Foundation
import UIKit
import CoreMedia
import AVFoundation
import FirebaseStorage
import MobileCoreServices

class VideoViewController : UIViewController, AVCaptureFileOutputRecordingDelegate
{
    //MARK: - Properties
    let videoStorageReference : StorageReference = {
        return Storage.storage().reference(forURL : "gs://awesomephotos-b794e.appspot.com/").child("movies")
    }()
    @IBOutlet weak var previewWiew: UIView!
    let captureSession = AVCaptureSession()
    var movieFileOutput = AVCaptureMovieFileOutput()
    var videoCaptureDevice : AVCaptureDevice?
    var myPreviewLayer : AVCaptureVideoPreviewLayer?
    @IBOutlet weak var viewToSpin: UIView!
    @IBOutlet weak var timeRecoredLbl: UILabel!
    
    //MARK: - Initalization
    
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
    
    var rotating = false
    func rotateButton()
    {
        if !rotating {
            // create a spin animation
            let spinAnimation = CABasicAnimation()
            // starts from 0
            spinAnimation.fromValue = 0
            // goes to 360 ( 2 * π )
            spinAnimation.toValue = Double.pi*2
            // define how long it will take to complete a 360
            spinAnimation.duration = 1
            // make it spin infinitely
            spinAnimation.repeatCount = Float.infinity
            // do not remove when completed
            spinAnimation.isRemovedOnCompletion = false
            // specify the fill mode
            spinAnimation.fillMode = CAMediaTimingFillMode.forwards
            // and the animation acceleration
            spinAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
            // add the animation to the button layer
            viewToSpin.layer.add(spinAnimation, forKey: "transform.rotation.z")
            
        } else {
            // remove the animation
            viewToSpin.layer.removeAllAnimations()
        }
    }
    
    //
    @IBAction func recordingButtonPressed(_ sender: UIButton) {
        
        rotateButton()
        if movieFileOutput.isRecording {
            
            movieFileOutput.stopRecording()
            stopWatch.stop()
            
            //Upload video to firestorage
            let uploadRef = videoStorageReference.child("movie.mov")
            let uploadVideoTask = uploadRef.putFile(from: URL(fileURLWithPath: self.videoLocation()), metadata: nil)
            uploadVideoTask.observe(.progress) { (snapshot) in
                print(snapshot.progress ?? "Progress cancelled")
            }
            uploadVideoTask.resume()
        }
        else {
            Timer.scheduledTimer(timeInterval: 0.1, target: self,
                                 selector: #selector(updateElapsedTimeLabel(_:)), userInfo: nil, repeats: true)
            stopWatch.start()//Start recoding
            movieFileOutput.connection(with: .video)?.videoOrientation = self.videoOrientation()
            movieFileOutput.maxRecordedDuration = maxRecordedDuration()
            movieFileOutput.startRecording(to: URL(fileURLWithPath: self.videoLocation()), recordingDelegate: self)
        }
    }
    
    func videoLocation() -> String{
        return NSTemporaryDirectory().appending("movie.mov")
    }
    
    
    var stopWatch = Stopwatch()
    
    @objc func updateElapsedTimeLabel(_ timer: Timer) {
        if stopWatch.isRunning {
            timeRecoredLbl.text = stopWatch.elapsedTimeAsString
        } else {
            timeRecoredLbl.text = "00:00"
            timer.invalidate()
        }
    }
    
    func clearTmpDir(){
        var removed: Int = 0
        do {
            let tmpDirURL = URL(string: NSTemporaryDirectory())!
            let tmpFiles = try FileManager.default.contentsOfDirectory(at: tmpDirURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            print("\(tmpFiles.count) temporary files found")
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
    
    func maxRecordedDuration() -> CMTime{
        let recordtime : Int64 = 300
        let preferedTimescale : Int32 = 1
        return CMTimeMake(value: recordtime, timescale: preferedTimescale)
    }
    
    //Set up video
    func configureSession(){
        self.captureSession.sessionPreset = .high
    }
    
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
        }catch  let error{
            print(error)
        }
    }
    
    func configurePreviewLayer(){
        myPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        myPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        myPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        myPreviewLayer?.frame = self.view.frame
        self.view.layer.insertSublayer(myPreviewLayer!, at: 0)
    }
    
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
    
    func startSession()
    {
        self.captureSession.startRunning()
    }
    
    //    //Func : Main
    
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
    
    //Func : Helpers
    
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
    
    override func viewWillLayoutSubviews() {
        self.setVideoOrientation()
    }
    
    //Protocol for AVCaptureFileOutputRecordingDelegate
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print("Finished recording")
    }
}
