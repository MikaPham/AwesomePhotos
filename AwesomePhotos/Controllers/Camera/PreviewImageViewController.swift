import Foundation
import UIKit
import FirebaseStorage
import Firebase


protocol UploadImageDelegate: class {
    func uploadImage()
}

class PreviewmageViewController : UIViewController {
    
    //MARK: - Properties
    
    @IBOutlet weak var photo: UIImageView!
    
    
    @IBOutlet weak var UploadingBtn: UIButton!
    @IBOutlet weak var downloadBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var whiteHomeBG: UILabel!
    
    var image : UIImage!
    var wmImage: UIImage!
    //let userUid = Auth.auth().currentUser?.uid
    //let userEmail = Auth.auth().currentUser?.email
    weak var delegate: UploadImageDelegate! = nil
    
    //MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        photo.image = self.image
    }
    
    // Hide statusBar
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    var isDismissed = false
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isDismissed == false {
            backBtn.isHidden = true
            downloadBtn.isHidden = true
            UploadingBtn.isHidden = true
            whiteHomeBG.isHidden = true
            isDismissed = true
        }
        else{
            backBtn.isHidden = false
            downloadBtn.isHidden = false
            UploadingBtn.isHidden = false
            whiteHomeBG.isHidden = false
            isDismissed = false
        }
    }
    //MARK: - Methods
    
    //1. Uploads the taken photo to Firebase Storage
    @IBAction func uploadBtnPressed(_ sender: UIButton) {
        self.delegate?.uploadImage()
        self.present(AlertService.basicAlert(imgName: "WinkFace", title: "Photo Uploaded", message: "This photo has been uploaded to the cloud."), animated: true, completion: nil)
        print("Uploading to Storage")
    }
    
    //2. Saves the photo to local storage
    @IBAction func downloadBtnPressed(_ sender: UIButton) {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            self.present(AlertService.basicAlert(imgName: "SmileFace", title: "Photo Downloaded", message: "This photo has been saved to your device."), animated: true, completion: nil)
            print("Saving to Local")
    }
    
    
    //3. Returns the users to the camera
    @IBAction func backToCamera(_ sender: UIButton) {
        print("Returning to Camera")
        dismiss(animated: true, completion: nil)
    }
    
}
