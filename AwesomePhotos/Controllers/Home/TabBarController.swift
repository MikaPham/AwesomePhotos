//
//  TabBarController.swift
//  AwesomePhotos
//
//  Created by User on 5/3/19.
//

import UIKit
import Firebase
import FirebaseUI
import AVFoundation
import MediaWatermark

class TabBarController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var libraryCollectionView: UICollectionView!
    @IBOutlet weak var mySegmentedControl: UISegmentedControl!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emptyFace: UIImageView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    lazy var db = Firestore.firestore()
    lazy var userUid = Auth.auth().currentUser?.uid
    
    var photosUid: [String] = []
    var ownedPhotosUid: [String] = []
    
    var videosUid: [String] = []
    var ownedVideosUid: [String] = []
    
    var showPhotos = true
    
    let thumbnailCache = NSCache<NSString, UIImage>()
    
    // MARK: UI
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:#selector(handleRefresh),for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.mainRed()
        return refreshControl
    }()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if showPhotos {
            if photosUid.count == 0 {
                emptyFace.isHidden = false
                emptyLabel.isHidden = false
                activityIndicator.isHidden = false
            } else {
                emptyFace.isHidden = true
                emptyLabel.isHidden = true
                activityIndicator.isHidden = true
            }
            return photosUid.count
        } else {
            if videosUid.count == 0 {
                emptyLabel.isHidden = false
                emptyFace.isHidden = false
                activityIndicator.isHidden = false
            } else {
                emptyLabel.isHidden = true
                emptyFace.isHidden = true
                activityIndicator.isHidden = true
            }
            return videosUid.count
        }
    }
    
    fileprivate func showPhotos(_ indexPath: IndexPath, _ cell: LibraryCollectionViewCell) {
        self.activityIndicator.startAnimating()
        let photoUid = photosUid[indexPath.row]
        cell.myImage.image = nil
        DispatchQueue.global().async {
            self.db.collection("photos").document(photoUid).getDocument{document, error in
                if let document = document, document.exists {
                    guard let data = document.data() else { return }
                    let reference = Storage.storage()
                        .reference(forURL: "gs://awesomephotos-b794e.appspot.com/")
                        .child(data["pathToOG"] as! String)
                    cell.filePath = data["pathToOG"] as? String
                    cell.photoUid = photoUid
                    DispatchQueue.main.async {
                        cell.myImage.sd_setImage(with: reference, placeholderImage: UIImage(named: "SleepFace"))
                        self.activityIndicator.stopAnimating()
                    }
                } else {
                    print("Document does not exist")
                    return
                }
            }
        }
    }
    
    fileprivate func showVideos(_ indexPath: IndexPath, _ cell: LibraryCollectionViewCell) {
        self.activityIndicator.startAnimating()
        let videoUid = videosUid[indexPath.row]
        cell.myImage.image = nil
        self.db.collection("medias").document(videoUid).getDocument{document, error in
            if let document = document, document.exists {
                guard let data = document.data() else { return }
                // If there is cache
                if let imageFromCache = self.thumbnailCache.object(forKey: videoUid as NSString) {
                    cell.myImage.image = imageFromCache
                    self.activityIndicator.stopAnimating()
                    // If the is no cache
                } else {
                    let reference = Storage.storage().reference(forURL: "gs://awesomephotos-b794e.appspot.com/").child(data["pathToOG"] as! String)
                    reference.downloadURL { url, error in
                        if let error = error {
                            print(error.localizedDescription)
                        } else {
                            let downloadURL = url
                            let thumbnail = self.createThumbnailOfVideoFromRemoteUrl(url: downloadURL!.absoluteString)
                            DispatchQueue.global(qos: .background).async {
                                if thumbnail != nil {
                                    let mediaProcessor = MediaProcessor()
                                    mediaProcessor.processElements(item: self.makeWmCopyOfImage(thumbnail: thumbnail!)) {(result, error) in
                                        DispatchQueue.main.async {
                                            self.thumbnailCache.setObject(result.image!, forKey: videoUid as NSString)
                                            cell.myImage.image = result.image
                                            self.activityIndicator.stopAnimating()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                cell.filePath = data["pathToOG"] as? String
                cell.photoUid = videoUid
            } else {
                print("Document does not exist")
                return
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! LibraryCollectionViewCell
        if showPhotos {
            showPhotos(indexPath, cell)
        } else {
            showVideos(indexPath, cell)
        }
        return cell
    }
    
    fileprivate func showImageView(_ indexPath: IndexPath) {
        // Instatiate the image view
        let ownedImageViewStoryboard: UIStoryboard = UIStoryboard(name: "OwnedImageView", bundle: nil)
        let ownedImageViewController: OwnedImageViewController = ownedImageViewStoryboard.instantiateViewController(withIdentifier: "ownedImageViewController") as! OwnedImageViewController
        let selectedCell = libraryCollectionView.cellForItem(at: indexPath) as! LibraryCollectionViewCell
        // Pass properties
        ownedImageViewController.filePath = selectedCell.filePath
        ownedImageViewController.photoUid = selectedCell.photoUid
        ownedImageViewController.owned = true
        // Move to image view
        let navController = UINavigationController(rootViewController: ownedImageViewController)
        self.present(navController, animated: true, completion: nil)
    }
    
    fileprivate func showVideoPlaybackView(_ indexPath: IndexPath) {
        // Instatiate the video playback view
        let videoPlaybackStoryboard: UIStoryboard = UIStoryboard(name: "VideoPreview", bundle: nil)
        let videoPlaybackController: VideoPlaybackController = videoPlaybackStoryboard.instantiateViewController(withIdentifier: "VideoPlaybackController") as! VideoPlaybackController
        let selectedCell = libraryCollectionView.cellForItem(at: indexPath) as! LibraryCollectionViewCell
        let reference = Storage.storage()
            .reference(forURL: "gs://awesomephotos-b794e.appspot.com/")
            .child(selectedCell.filePath!)
        // Fetch the download URL
        reference.downloadURL {[unowned self] (url, error) in
            if let error = error {
                self.present(AlertService.basicAlert(imgName: "GrinFace", title: "Download Failed", message: error.localizedDescription), animated: true, completion: nil)
            } else {
                let downloadURL = url
                // Pass properties
                videoPlaybackController.filePath = selectedCell.filePath
                videoPlaybackController.videoURL = downloadURL
                videoPlaybackController.owned = true
                videoPlaybackController.videoUid = selectedCell.photoUid
                videoPlaybackController.thumbnail = selectedCell.myImage.image
                // Move to video playback view
                let navController = UINavigationController(rootViewController: videoPlaybackController)
                self.present(navController, animated: true, completion: nil)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if showPhotos {
            showImageView(indexPath)
        } else {
            showVideoPlaybackView(indexPath)
        }
    }
    
    // MARK: Init
    override func viewDidLoad() {
        super.viewDidLoad()
        self.libraryCollectionView.addSubview(self.refreshControl)
        fetchPhotos()
    }
    
    // MARK: Helpers
    func createThumbnailOfVideoFromRemoteUrl(url: String) -> UIImage? {
        let asset = AVAsset(url: URL(string: url)!)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(1.0, preferredTimescale: 100)
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            return thumbnail
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    fileprivate func makeWmCopyOfImage(thumbnail: UIImage) -> MediaItem {
        let item = MediaItem(image: thumbnail)
        let playIcon = UIImage(named: "icons8-play_filled")
        let firstElement = MediaElement(image: playIcon!)
        firstElement.frame = CGRect(x: item.size.width/2-item.size.width/11, y: item.size.height/2-item.size.height/11, width: item.size.width/5, height: item.size.height/5)
        item.add(elements: [firstElement])
        return item
    }
    
    fileprivate func clearArrays() {
        self.ownedPhotosUid.removeAll()
        self.photosUid.removeAll()
        self.videosUid.removeAll()
        self.ownedVideosUid.removeAll()
    }
    
    // MARK: Selectors
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.libraryCollectionView.reloadData()
        refreshControl.endRefreshing()
    }
    
    @IBAction func switchCustom(_ sender: UISegmentedControl) {
        showPhotos = !showPhotos
        libraryCollectionView.reloadData()
    }
    
    // MARK: API
    func fetchPhotos() {
        self.db.collection("users").document(userUid!).addSnapshotListener{snapshot, error in
            self.clearArrays()
            if let document = snapshot, document.exists {
                guard let data = document.data() else { return }
                // Photos
                self.ownedPhotosUid = data["ownedPhotos"] as! [String]
                self.photosUid += data["ownedPhotos"] as! [String]
                
                // Videos
                self.ownedVideosUid = data["ownedVideos"] as! [String]
                self.videosUid += data["ownedVideos"] as! [String]
            } else {
                print("Document does not exist")
                return
            }
        }
        DispatchQueue.main.async {
            self.libraryCollectionView.reloadData()
        }
    }
}


