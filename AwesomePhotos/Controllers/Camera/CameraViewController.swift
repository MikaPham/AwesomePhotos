import UIKit
import AVFoundation
import FirebaseStorage
import Firebase
import FirebaseFirestore
import MediaWatermark
import MapKit



class CameraViewController : UIViewController {
    // MARK: - Properties
    var captureSession = AVCaptureSession()
    var currentCamera : AVCaptureDevice?
    var photoOutPut : AVCapturePhotoOutput?
    var cameraPreviewLayer : AVCaptureVideoPreviewLayer?
    var image : UIImage?
    var avCaptureConnection : AVCaptureConnection?
    var newInput : AVCaptureDeviceInput?
    var newCamera : AVCaptureDevice?
    var wmImage: UIImage!
    var progressStatusCompleted : Float!
    let db = Firestore.firestore()
    let userUid = Auth.auth().currentUser?.uid
    let userEmail = Auth.auth().currentUser?.email
    var captureLocation: [String: String]!
    let defaultCaptureLocation:[String: String] = ["ward": "", "town": "", "city": ""]
    private let locationManager = LocationManager()
    
    //MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCurrentLocation()
        navigationController?.navigationBar.isHidden = true
        createCaptureSession()
        configureInputOutput()
        configurePreviewLayer()
        startRunningSession()
        
        
        
    }
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    
    //MARK: - Methods
    // 1. Creating a capture session.
    func createCaptureSession(){
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    // 2. Identifying the necessary capture devices.
    func configureCaptureDevices(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession( deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: position)
        
        if let device = deviceDiscoverySession.devices.first
        {
            return device
        }
        return nil
    }
    
    // 3. Creating inputs using the capture devices.
    // and outputs the photo to be shown later in the previewLayer
    func configureInputOutput() {
        currentCamera = AVCaptureDevice.default(for: AVMediaType.video)
        do {
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
    func configurePreviewLayer() {
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        if (cameraPreviewLayer!.connection!.isVideoMirroringSupported){
            cameraPreviewLayer?.connection!.automaticallyAdjustsVideoMirroring = true
            //cameraPreviewLayer?.connection!.isVideoMirrored = true
        }
        cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        cameraPreviewLayer?.frame = self.view.frame
        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
    }
    
    // 5. Starting the camera session
    func startRunningSession() {
        captureSession.startRunning()
    }
    
    //6. Switching the front and back camera
    @IBAction func switchCameraButtonPressed(_ sender: UIButton) {
        
        let currentCameraPosition : AVCaptureInput = captureSession.inputs[0]
        captureSession.removeInput(currentCameraPosition)
        
        if (currentCameraPosition as! AVCaptureDeviceInput).device.position == .back{
            newCamera = self.configureCaptureDevices(position: .front)!
        }
        else{
            newCamera = self.configureCaptureDevices(position: .back)!
        }
        do{
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
            previewVC.delegate = self
        }
    }
    
    //9. Goes back to the home screen
    @IBAction func backButtonPressed(_ sender: UIButton) {
        captureSession.stopRunning()
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
    @IBAction func previewLatestFileButtonPressed(_sender: UIButton) {
        captureSession.stopRunning()
        let customBtnStoryboard: UIStoryboard = UIStoryboard(name: "TabBar", bundle: nil)
        let customBtnController: CustomButton = customBtnStoryboard.instantiateViewController(withIdentifier: "CustomButton") as! CustomButton
        let navController = UINavigationController(rootViewController: customBtnController)
        self.present(navController, animated: true, completion: nil)
    }
    
}

extension CameraViewController : AVCapturePhotoCaptureDelegate, UploadImageDelegate {

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation(){
            image = UIImage(data: imageData)
    }
        
        /// Image flow handler
        let autoUpload = defaults.bool(forKey: keys.autoUpload)
        let autoSave = defaults.bool(forKey: keys.autoSave)
        
        if autoSave == true && autoUpload == true {
            uploadImage()
            UIImageWriteToSavedPhotosAlbum(image!, self, nil, nil)
            print("Image Saved and Uploaded")
        } else if autoUpload == true && autoSave == false {
            uploadImage()
            print("Image Uploaded")
        } else {
            performSegue(withIdentifier: "segueToShowPhoto", sender: nil)
            print("Going To Preview")
        }
    }
    
    
    func uploadImage() {
        let id = UUID()
        let photoName = id.uuidString
        
        makeWmCopyOfImage()
        
        guard let imageData = self.image?.jpegData(compressionQuality: 0.55) else { return }
        guard let imageDataWm = wmImage.jpegData(compressionQuality: 0.55) else {return}
        
        //Upload to Firestore
        let data: [String:Any] = ["name": photoName + ".jpg","owners":[userUid], "sharedWith":[], "sharedWM":[], "location": captureLocation ?? defaultCaptureLocation]
        var ref: DocumentReference? = nil
        ref = db.collection("photos").addDocument(data: data) { (error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Upload to Firestore finished. ")
            }
        }
        
        //Add to user document
        self.db.collection("users").document(userUid!).updateData(
            ["ownedPhotos":FieldValue.arrayUnion([ref!.documentID])]
        )
        
        //Upload to Firebase
        for (key,value) in PhotoTypesConstants {
            let storageReference: StorageReference = {
                return Storage.storage()
                    .reference(forURL: "gs://awesomephotos-b794e.appspot.com/")
                    .child("User/\(userUid!)/Uploads/Photo/\((ref?.documentID)!)/\(value)")
            }()
            
            let uploadImageRef = storageReference.child(id.uuidString + "-\(value).jpg")
            let uploadTask = uploadImageRef.putData(key == "WatermarkPhoto" ? imageDataWm : imageData, metadata : nil) { (metadata, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("Upload to Firebase Storage finished. ")
                }
            }
            
            
            //Observes where the progress of the file is at in %
            uploadTask.observe(.progress) { [weak self] (snapshot) in
                guard let progressStatus = snapshot.progress else { return }
                
                self!.progressStatusCompleted = Float(progressStatus.fractionCompleted)
                
                //Adds observer to listen when photo is being uploaded
                let progressName = Notification.Name(rawValue: progressCapturedKey)
                let statuses = ["" : self!.progressStatusCompleted]
                NotificationCenter.default.post(name: progressName, object: self, userInfo: statuses as [AnyHashable : Any])
            }
            
            let thumbnailName = Notification.Name(rawValue: thumbnailCapturedKey)
            NotificationCenter.default.post(name: thumbnailName, object: self)
            
            
            
            
            let uploadPath: [String:Any] = ["pathTo\(value.uppercased())":uploadImageRef.fullPath]
            db.collection("photos").document(ref!.documentID).updateData(uploadPath) {
                err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Path to storage sucessfully set. ")
                }
            }
        }
    }
    
    // Initialize WM copy
    fileprivate func makeWmCopyOfImage() {
        let item = MediaItem(image: image!)
        let watermarkString = "\(userEmail ?? "")\n[AwesomePhotos]"
        let attributes = [ NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 80) ]
        let attrStr = NSAttributedString(string: watermarkString, attributes: attributes)
        let secondElement = MediaElement(text: attrStr)
        secondElement.frame = CGRect(x: 10, y: image!.size.height-200, width: image!.size.width, height: image!.size.height)
        item.add(elements: [secondElement])
        let mediaProcessor = MediaProcessor()
        mediaProcessor.processElements(item: item) { [weak self] (result, error) in
            self?.wmImage = result.image
        }
    }
    
    // Retrieve user's location into captureLocation
    fileprivate func setCurrentLocation() {
        guard let exposedLocation = self.locationManager.exposedLocation else {
            print("*** Error in \(#function): exposedLocation is nil")
            return
        }
        
        self.locationManager.getPlace(for: exposedLocation) { placemark in
            guard let placemark = placemark else { return }
            let ward = String(placemark.subAdministrativeArea!) // District
            let town = String(placemark.locality!) // Town
            let country = String(placemark.country!) // Country

            self.captureLocation = ["ward" : ward, "town": town, "country": country]
            print(self.captureLocation ?? "")
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
