import Foundation
import UIKit
import CoreMedia
import AVFoundation
import FirebaseStorage
import MobileCoreServices


let videoStorageReference : StorageReference = {
    return Storage.storage().reference(forURL : "gs://greenwealth-302e0.appspot.com/").child("movieFolder")
}()

class VideoViewController : UIViewController, AVCaptureFileOutputRecordingDelegate
{
    @IBOutlet weak var previewWiew: UIView!
    let captureSession = AVCaptureSession()
    var movieFileOutput = AVCaptureMovieFileOutput()
    var videoCaptureDevice : AVCaptureDevice?
    var myPreviewLayer : AVCaptureVideoPreviewLayer?
    
    @IBOutlet weak var timeRecordedLbl: UILabel!
    
    
    //TODO : Will not upload video to storage
    @IBAction func recordingBtn(_ sender: UIButton) {
        if movieFileOutput.isRecording {
            movieFileOutput.stopRecording()
            
            //Upload video to firestorage
            let uploadRef = videoStorageReference.child("comoneFile.qt")
            let uploadVideoTask = uploadRef.putFile(from: URL(fileURLWithPath: self.videoLocation()), metadata: nil)
            
            uploadVideoTask.observe(.progress) { (snapshot) in
                print(snapshot.progress ?? "Progress cancelled")
            }
            uploadVideoTask.resume()
        }
        else {
            //Start recoding
            movieFileOutput.connection(with: .video)?.videoOrientation = videoOrientation()
            movieFileOutput.maxRecordedDuration = maxRecordedDuration()
            movieFileOutput.startRecording(to: URL(fileURLWithPath: self.videoLocation()), recordingDelegate: self)
        }
    }
    
    func videoLocation() -> String{
        return NSTemporaryDirectory().appending("comeonFile.qt")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clearTmpDir()
        configureSession()
        configureVideoInput()
        configureVideoOutPut()
        configurePreviewLayer()
        startSession()
    }
    
    //MARK : Custom Methods
    
    /*
     1. Creating a capture session.
     2. Obtaining and configuring the necessary capture devices.
     3. Creating inputs using the capture devices.
     4. Configuring a photo output object to process captured images.*/
    
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
    
   
    func clearTmpDir(){  //Clears the cache so movie files won't be stored on the device
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
    
    
    func maxRecordedDuration() -> CMTime{  //Sets the maximum recorded time to 5 minutes
        let recordtime : Int64 = 300
        let preferedTimescale : Int32 = 1
        return CMTimeMake(value: recordtime, timescale: preferedTimescale)
    }
    
    
    //Protocol for AVCaptureFileOutputRecordingDelegate
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print("Finished recording")
    }
}
