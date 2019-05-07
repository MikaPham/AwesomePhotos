import UIKit
import AVFoundation

class CameraViewController : UIViewController
{
    // MARK: - Properties
    var captureSession = AVCaptureSession()
    
    var frontCamera : AVCaptureDevice?
    var backCamera : AVCaptureDevice?
    var currentCamera : AVCaptureDevice?
    var photoOutPut : AVCapturePhotoOutput?
    var cameraPreviewLayer : AVCaptureVideoPreviewLayer?
    var image : UIImage?
    
    //MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        createCaptureSession()
        configureInputOutput()
        configurePreviewLayer()
        startRunningSession()
    }
    
    override var prefersStatusBarHidden: Bool{
        return false
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
    
    //6. Switching the front and back camera
    @IBAction func switchCameraButtonPressed(_ sender: UIButton) {
        
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
    
    //7. Taking photo when button is pressed
    @IBAction func cameraButtonPressed(_ sender: RoundButton) {
        let setting = AVCapturePhotoSettings()
        photoOutPut?.capturePhoto(with: setting, delegate: self)
    }
    
    //8. Transitions from CameraVC to PreviewVC and pass the taken image to the preview layer
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToShowPhoto"{
            let previewVC = segue.destination as! PreviewmageViewController
            previewVC.image = self.image
        }
    }
    
    //9. Goes back to the home screen
    @IBAction func backButtonPressed(_ sender: UIButton) {
        let customBtnStoryboard: UIStoryboard = UIStoryboard(name: "TabBar", bundle: nil)
        let customBtnController: CustomButton = customBtnStoryboard.instantiateViewController(withIdentifier: "CustomButton") as! CustomButton
        
        let navController = UINavigationController(rootViewController: customBtnController)
        self.present(navController, animated: true, completion: nil)
    }
    
    //10. Go to video view to record video
    @IBAction func switchToVideoModeButtonPressed(_ sender: UIButton) {
        captureSession.stopRunning()
        performSegue(withIdentifier: "segueToVideo", sender: self)
    }

    //11. Preview latest file taken
    //    @IBAction previewLatestFileButtonPressed(){
    //
    //

}

extension CameraViewController : AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation(){
            image = UIImage(data: imageData)!
            
            let cIImage : CIImage = CIImage(cgImage: (image?.cgImage!)!).oriented(forExifOrientation: 6)
            let mirroredImage = cIImage.transformed(by: CGAffineTransform(scaleX: -1, y: 1))
            image = UIImage.convert(from: mirroredImage)
            performSegue(withIdentifier: "segueToShowPhoto", sender: nil)
        }
    }
}

extension UIImage{
    
    static func convert(from ciImage: CIImage) -> UIImage{
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(ciImage, from: ciImage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
}
