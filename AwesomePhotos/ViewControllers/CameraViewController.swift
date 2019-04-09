import UIKit
import AVFoundation

class CameraViewController : UIViewController
{
    var captureSession = AVCaptureSession()
    
    var frontCamera : AVCaptureDevice?
    var backCamera : AVCaptureDevice?
    var currentCamera : AVCaptureDevice?
    var photoOutPut : AVCapturePhotoOutput?
    var cameraPreviewLayer : AVCaptureVideoPreviewLayer?
    
    var image : UIImage?
    
    @IBOutlet weak var cameraBtn: RoundedButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createCaptureSession()
        configureInputOutput()
        configurePreviewLayer()
        startRunningSession()
    }
    //MARK : Custom Methods
    
    /*
     1. Creating a capture session.
     2. Obtaining and configuring the necessary capture devices.
     3. Creating inputs using the capture devices.
     4. Configuring a photo output object to process captured images.*/
    
    func createCaptureSession()
    {
        captureSession.sessionPreset = .photo
    }
    
    //Selects the back camera pr. default and returns it if a camera exists
    func configureCaptureDevices(position: AVCaptureDevice.Position) -> AVCaptureDevice?
    {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession( deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: position)
        
        if let device = deviceDiscoverySession.devices.first
        {
            return device
        }
        return nil
    }
    
    //Adds input from taken photo to captureSession and outputs the photo to be shown later in the previewImageViewController
    func configureInputOutput()
    {
        currentCamera = AVCaptureDevice.default(for: AVMediaType.video)
        do
        {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            captureSession.addInput(captureDeviceInput)
            photoOutPut = AVCapturePhotoOutput()
            photoOutPut?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession.addOutput(photoOutPut!)
        }catch{
            print("Could not add input or output..")
        }
    }
    
    //Configures the image in the previewLayer so it looks nice and tight
    func configurePreviewLayer()
    {
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        cameraPreviewLayer?.frame = self.view.frame
        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
    }
    
    func startRunningSession()
    {
        captureSession.startRunning()
    }
    
    @IBAction func recordingBtnPressed(_ sender: UIButton) {
        captureSession.stopRunning()
        performSegue(withIdentifier: "segueToVideo", sender: self)
    }
    
    @IBAction func cameraBtnPressed(_ sender: UIButton) {
        let setting = AVCapturePhotoSettings()
        photoOutPut?.capturePhoto(with: setting, delegate: self)
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "segueToHome", sender: self)
    }
    
    @IBAction func switchCameraBtnPressed(_ sender: UIButton) {
        
        let currentCamera : AVCaptureInput = captureSession.inputs[0]
        captureSession.removeInput(currentCamera)
        
        var newCamera : AVCaptureDevice?
        if (currentCamera as! AVCaptureDeviceInput).device.position == .back{
            newCamera = self.configureCaptureDevices(position: .front)!
        }else{
            newCamera = self.configureCaptureDevices(position: .back)!
        }
        var newInput : AVCaptureDeviceInput?
        do
        {
            newInput = try AVCaptureDeviceInput(device: newCamera!)
        }catch{
            print("Error")
        }
        if let newInput = newInput{
            captureSession.addInput(newInput)
        }
    }
    
    //Transfer image from CameraVC to PreviewVC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToShowPhoto"{
            let previewVC = segue.destination as! PreviewmageViewController
            previewVC.image = self.image
        }
    }
}

extension CameraViewController : AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation(){
            image = UIImage(data: imageData)!
            performSegue(withIdentifier: "segueToShowPhoto", sender: nil)
        }
    }
}
