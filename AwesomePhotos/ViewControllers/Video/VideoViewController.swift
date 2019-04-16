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
        return Storage.storage().reference(forURL : "gs://awesomephotos-b794e.appspot.com").child("movieFolder")
    }()
    @IBOutlet weak var previewWiew: UIView!
    let captureSession = AVCaptureSession()
    let movieFileOutput = AVCaptureMovieFileOutput()
    let videoCaptureDevice : AVCaptureDevice?
    let myPreviewLayer : AVCaptureVideoPreviewLayer?
    @IBOutlet weak var viewToSpin: UIView!
    @IBOutlet weak var timeRecoredLbl: UILabel!
    @IBOutlet weak var recordingBtn: UIButton!
    
    var stopWatch = Stopwatch()
    var rotating = false
    let startShapeLayer = CAShapeLayer()
    let endShapeLayer = CAShapeLayer()
    
    //MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeRecordingBtn()
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
        }catch  let error{
            print(error)
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
    
    //6. Sets up a custom recording button with animation
    func configureRecordingBtn(){
        let btnCenter = CGPoint(x: 190, y: 600)
        
        
        //Create tracklayer to show if you are recording or not
        let trackLayer = CAShapeLayer()
        let circularPath = UIBezierPath(arcCenter: btnCenter, radius: 40, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi, clockwise: true)
        trackLayer.path = circularPath.cgPath
        
        let colorForTrackLayer =  UIColor(red: (127/255.0), green: (55/255.0), blue: (44/255.0), alpha: 0.6)
        trackLayer.strokeColor = colorForTrackLayer.cgColor
        trackLayer.lineWidth = 10
        trackLayer.fillColor = UIColor.clear.cgColor
        view.layer.addSublayer(trackLayer)
        
        //Create animation spinning around the recording button
        startShapeLayer.path = circularPath.cgPath
        
        let colorForAnimation = UIColor(red: (180/255.0), green: (55/255.0), blue: (44/255.0), alpha: 0.6)
        startShapeLayer.strokeColor = colorForAnimation.cgColor
        startShapeLayer.fillColor = UIColor.clear.cgColor
        startShapeLayer.lineWidth = 10
        startShapeLayer.lineCap = CAShapeLayerLineCap.round
        startShapeLayer.strokeEnd = 0
        view.layer.addSublayer(startShapeLayer)
        
        endShapeLayer.path = circularPath.cgPath
        
        let colorForTailLayer =  UIColor(red: (127/255.0), green: (55/255.0), blue: (44/255.0), alpha: 0.6)
        endShapeLayer.strokeColor = colorForTailLayer.cgColor
        endShapeLayer.fillColor = UIColor.clear.cgColor
        endShapeLayer.lineWidth = 10
        endShapeLayer.lineCap = CAShapeLayerLineCap.round
        endShapeLayer.strokeEnd = 0
        view.layer.addSublayer(endShapeLayer)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleRecordingButtonPressed)))
    }
    
    //7. Tap recogniser which handles if video is recording or not
    @objc private func handleRecordingButtonPressed(){
        
        let spinAnimation = CABasicAnimation(keyPath: "strokeEnd")
        let tailSpinAnimation = CABasicAnimation(keyPath: "strokeEnd")
        
        if !rotating{
            
            spinAnimation.toValue = 1
            spinAnimation.duration = 2
            spinAnimation.repeatCount = .greatestFiniteMagnitude
            spinAnimation.fillMode = CAMediaTimingFillMode.backwards
            spinAnimation.isRemovedOnCompletion = true
            
            tailSpinAnimation.toValue = 1
            tailSpinAnimation.duration = 2
            tailSpinAnimation.beginTime = CACurrentMediaTime() + 0.3
            tailSpinAnimation.repeatCount = .greatestFiniteMagnitude
            tailSpinAnimation.fillMode = CAMediaTimingFillMode.backwards
            tailSpinAnimation.isRemovedOnCompletion = false
            
            startShapeLayer.add(spinAnimation, forKey: "GoAround")
            endShapeLayer.add(tailSpinAnimation, forKey: "Comes around")
        }
        
        if movieFileOutput.isRecording {
            
            movieFileOutput.stopRecording()
            rotating = true //Stops the animation
            view.layer.transform = CATransform3DIdentity
            startShapeLayer.removeAllAnimations()
            stopWatch.stop()
            
            //Upload video to firestorage
            let uploadRef = videoStorageReference.child("comeonFile.mov")
            let uploadVideoTask = uploadRef.putFile(from: URL(fileURLWithPath: self.videoLocation()), metadata: nil)
            uploadVideoTask.observe(.progress) { (snapshot) in
                print(snapshot.progress ?? "Progress cancelled")
            }
            uploadVideoTask.resume()
        }
        else {
            rotating = false
            Timer.scheduledTimer(timeInterval: 0.1, target: self,
                                 selector: #selector(updateElapsedTimeLabel(_:)), userInfo: nil, repeats: true)
            stopWatch.start()//Start recoding
            movieFileOutput.connection(with: .video)?.videoOrientation = self.videoOrientation()
            movieFileOutput.maxRecordedDuration = maxRecordedDuration()
            movieFileOutput.startRecording(to: URL(fileURLWithPath: self.videoLocation()), recordingDelegate: self)
        }
    }
    
    //8. Stores the video in this temporary directory in the cache
    func videoLocation() -> String{
        return NSTemporaryDirectory().appending("comeonFile.mov")
    }
    
    //9. Updates the time recorded and resets it, if video stopped recording
    @objc func updateElapsedTimeLabel(_ timer: Timer) {
        if stopWatch.isRunning {
            timeRecoredLbl.text = stopWatch.elapsedTimeAsString
        } else {
            timeRecoredLbl.text = "00:00"
            timer.invalidate()
        }
    }
    
    //10. Clears the cache so no videos is stored in the cache
    func clearTmpDir(){
        var removed: Int = 0
        do {
            let tmpDirURL = URL(string: NSTemporaryDirectory())!
            let tmpFiles = try FileManager.default.contentsOfDirectory(at: tmpDirURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            print("\(tmpFiles.count) temporary files found
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
    
    //11. Sets the duration time to the maximum of 5 min
    func maxRecordedDuration() -> CMTime{
        let recordtime : Int64 = 300
        let preferedTimescale : Int32 = 1
        return CMTimeMake(value: recordtime, timescale: preferedTimescale)
    }
    
    //12. Sets the current rotation of the phone
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
    
    //MARK: - Helper
    
    //13. The different positions the phone can be in, is used in the setVideoOrientation
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
    
    //Sets the according position to the screen
    override func viewWillLayoutSubviews() {
        self.setVideoOrientation()
    }
    
    //Protocol for AVCaptureFileOutputRecordingDelegate.. Needed for it to work
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print("Finished recording")
    }
}
