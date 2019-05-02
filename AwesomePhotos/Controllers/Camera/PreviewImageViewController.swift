import Foundation
import UIKit
import FirebaseStorage
import Firebase

class PreviewmageViewController : UIViewController{
    
    //MARK: - Properties
    @IBOutlet weak var photo: UIImageView!
    var image : UIImage!
    let db = Firestore.firestore()
    
    //MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        photo.image = self.image
    }
    
    //MARK: - Methods
    
    //1. Uploads the taken photo to Firebase Storage
    @IBAction func uploadToStorageButtonPressed(_ sender: UIButton) {
        let id = UUID()
        let photoName = id.uuidString
        guard let imageData = image.jpegData(compressionQuality: 0.55) else { return }
        
        //Upload to Firestore
        let data = ["name": photoName + ".jpg"]
        var ref: DocumentReference? = nil
        ref = db.collection("photos").addDocument(data: data) { (error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Upload to Firestore finished. ")
            }
        }
        
        //Upload to Firebase
        for (_,value) in PhotoTypesConstants {
            let storageReference : StorageReference = {
                return Storage.storage().reference(forURL: "gs://awesomephotos-b794e.appspot.com/").child("User/doc12/Uploads/Photo/\((ref?.documentID)!)/\(value)")
            }()
            
            let uploadImageRef = storageReference.child(id.uuidString + "-\(value).jpg")
            _ = uploadImageRef.putData(imageData, metadata : nil) { (metadata, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("Upload to Firebase Storage finished. ")
                }
            }
            let uploadPath = ["pathTo\(value)":uploadImageRef.fullPath]
            db.collection("photos").document(ref!.documentID).setData(uploadPath) {
                err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Path to storage sucessfully set. ")
                }
            }
            
        }
    }
 
    //2. Saves the photo to local storage
    @IBAction func saveToLocalStorageButtonPressed(_ sender: UIButton) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        dismiss(animated: true, completion: nil)
    }
    
    //3. Returns the users to the camera
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
                dismiss(animated: true, completion: nil)
    }
}


//!! Tracks progress of image uplaoding -- might be used for later 
//            uploadTask.observe(.progress){ (snapshot) in
//                print(snapshot.progress ?? "Progress cancelled")
//            }
//            uploadTask.resume()
//            dismiss(animated: true, completion: nil)
//       }
