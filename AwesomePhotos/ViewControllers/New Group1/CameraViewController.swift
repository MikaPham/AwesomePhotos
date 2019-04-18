import UIKit
import AVFoundation

class CameraViewController : UIViewController, SwitchBackAndForth
{
    // MARK: - Properties
    var captureSession = AVCaptureSession()
    
    let frontCamera : AVCaptureDevice?
    let backCamera : AVCaptureDevice?
    let currentCamera : AVCaptureDevice?
    let photoOutPut : AVCapturePhotoOutput?
    let cameraPreviewLayer : AVCaptureVideoPreviewLayer?
    var image : UIImage?
    
    @IBOutlet weak var cameraBtn: RoundedButton!
    
    //MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createCaptureSession()
        configureInputOutput()
        configurePreviewLayer()
        startRunningSession()
    }
    
    //MARK: - Methods
    
    
    // 1. Creating a capture session.
    func createCaptureSession()
    {
        captureSession.sessionPreset = .photo
    }
    
    // 2. Identifying the necessary capture devices.
    func configureCaptureDevices(position: AVCaptureDevice.Position) -> AVCaptureDevice?
    {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession( deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: position)
        
        if let device = deviceDiscoverySession.devices.first
        {
            return device
        }
        return nil
    }
    
    // 3. Creating inputs using the capture devices.
    // and outputs the photo to be shown later in the previewLayer
    func configureInputOutput()
    {
        currentCamera = AVCaptureDevice.default(for: AVMediaType.video)
        do
        {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            captureSession.addInput(captureDeviceInput)
            photoOutPut = AVCapturePhotoOutput()
            //Specifies the settings for the photo, and which format it should be
            photoOutPut?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession.addOutput(photoOutPut!)
        } catch{
            print("No device input or output devices found")
        }
    }
    
    // 4. Configures the image to fit the preview layer
    func configurePreviewLayer()
    {
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        cameraPreviewLayer?.frame = self.view.frame
        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
    }
    
    // 5. Starting the camera session
    func startRunningSession()
    {
        captureSession.startRunning()
    }
    
    
    //6. Taking photo when button is pressed
    @IBAction func cameraButtonPressed(_ sender: Any) {
        let setting = AVCapturePhotoSettings()
        photoOutPut?.capturePhoto(with: setting, delegate: self)
    }
    
    //7. Transitions from CameraVC to PreviewVC and pass the taken image to the preview layer
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToShowPhoto"{
            let previewVC = segue.destination as! PreviewmageViewController
            previewVC.image = self.image
        }
    }
    
    //8. Goes back to the home screen
    @IBAction func backButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "segueToHome", sender: self)
    }
    
    //9. Go to video view to record video
    @IBAction func switchToVideoModeButtonPressed(_ sender: UIButton) {
        captureSession.stopRunning()
        performSegue(withIdentifier: "segueToVideo", sender: self)
    }
    
    //10. Preview latest file taken
    //    @IBAction previewLatestFileButtonPressed(){
    //
    //    }
}

extension CameraViewController : AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation(){
            image = UIImage(data: imageData)!
            performSegue(withIdentifier: "segueToShowPhoto", sender: nil)
        }
    }
}