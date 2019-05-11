import UIKit
import AVKit

protocol UploadVideoDelegate: class {
    func uploadVideo()
    func clearTmpDir()
}


class PreviewVideoViewController : UIViewController
{
    //MARK: - Properties
    var videoURL : URL!
    var avPlayer : AVPlayer?
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var centerPlayButton: UIButton!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var totalDurationLabal: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var UploadButton: UIButton!
    weak var delegate: UploadVideoDelegate? = nil
    
    //MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        configurePreviewView()
        trackTimeProgress()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    //MARK: - Methods

    //1. Sets up the video preview configuration
    fileprivate func configurePreviewView(){
        avPlayer = AVPlayer(url: videoURL)
        
        //Checks to see if video has loaded and is ready to be played
        //avPlayer!.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)

        //View setup
        let avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.frame = view.bounds
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoView.layer.insertSublayer(avPlayerLayer, at: 0)
        
        view.layoutIfNeeded()
        
        let playerItem = AVPlayerItem(url: videoURL as URL)
        avPlayer!.replaceCurrentItem(with: playerItem)
        avPlayer!.pause()
    }
    
    //2. Checks to see if the video has been loaded and is ready to play
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        if keyPath == "currentItem.loadedTimeRanges"{
//            activityIndicator.stopAnimating()
//            containerView.isHidden = true
//        }
//    }
    
    //2. Tracks the duration of time played in the video
    fileprivate func trackTimeProgress(){
        
        //Defines the seconds to increment by 1+
        let interval = CMTime(value: 1, timescale: 1)
        
        //sets a timer that increment with 1 until video is finished
        avPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: nil, using: { (progressTime) in
            
            //Updates the current time label
            let seconds = CMTimeGetSeconds(progressTime)
            let secondsText = String(format: "%02d", Int(seconds) % 60)
            let minutesText = String(format: "%02d", Int(seconds) / 60)
            self.currentTimeLabel.text = "\(minutesText):\(secondsText)"

            // Moving the thumb on the slider
            if let duration = self.avPlayer?.currentItem?.duration{
                let durationSeconds = CMTimeGetSeconds(duration)
                
                self.slider.value = Float(seconds / durationSeconds)
                
            }
        })
        let videoPlayed = NSNotification.Name.AVPlayerItemDidPlayToEndTime
        
        //Observes whether the video is done, and sets the video back to 0 and to played again
        NotificationCenter.default.addObserver(forName: videoPlayed, object: nil, queue: nil) { (notification) in
            self.avPlayer?.seek(to: CMTime.zero)
            self.isPlaying = false
            self.avPlayer?.pause()
            self.centerPlayButton.setImage(UIImage(named: "Play"), for: .normal)
        }
    }

    var isPlaying = false

    //3. Start the video when pressed and stops it again
    @IBAction func playButtonPressed(_ sender: UIButton) {
        
        //Sets the duration of the entire video
        if let duration = avPlayer?.currentItem?.duration{
            let seconds = CMTimeGetSeconds(duration)
            let secondsDisplayed = String(format: "%02d", Int(seconds) % 60)
            let minutesDisplayed = String(format: "%02d", Int(seconds) / 60)
            totalDurationLabal.text = "\(minutesDisplayed):\(secondsDisplayed)"
        }

        if isPlaying == false{
            avPlayer!.play()
            centerPlayButton.setImage(UIImage(named: "Pause"), for: .normal)
            centerPlayButton.tintColor = .white
            slider.thumbTintColor = .clear
            isPlaying = true
        }
        else{
            avPlayer!.pause()
            centerPlayButton.setImage(UIImage(named: "Play"), for: .normal)
            isPlaying = false
        }
    }
    
    //4. Set new playtime of video with slider
    @IBAction func changeSliderDurationPressed(_ sender: UISlider) {
        slider.addTarget(self, action: #selector(handleSliderChange), for: .valueChanged)
    }
    
    //5. Handles the slider logic to a specific time in the slider
    @objc func handleSliderChange(){

        //Gets the total duration of the video
        if let duration = avPlayer?.currentItem?.duration{
            let totalDuration = CMTimeGetSeconds(duration)
            
            let sliderValue = Float64(slider.value) * totalDuration
            let seekTime = CMTime(value: Int64(sliderValue), timescale: 1)
            
            //sets the video to the selected slider value
            avPlayer?.seek(to: seekTime, completionHandler: { (completedSeek) in
            })
        }
    }
    
    //6.  Hides or shows controls depending on touch
    var isDismissed = false
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        centerPlayButton.isHidden = false
        if isDismissed == false {
            cancelButton.isHidden = true
            centerPlayButton.isHidden = true
            slider.isHidden = true
            totalDurationLabal.isHidden = true
            currentTimeLabel.isHidden = true
            UploadButton.isHidden = true
            slider.thumbTintColor = .clear
            isDismissed = true
        }
        else{
            cancelButton.isHidden = false
            centerPlayButton.isHidden = false
            slider.isHidden = false
            totalDurationLabal.isHidden = false
            currentTimeLabel.isHidden = false
            UploadButton.isHidden = false
            slider.thumbTintColor = .red
            isDismissed = false
        }
    }
    
    @IBAction func uploadButtonPressed(_ sender: UIButton) {
        self.delegate?.uploadVideo()
    }
    //7. Dismisses the video preview
    @IBAction func dismissPreviewButtonPressed(_ sender: UIButton) {
        self.delegate?.clearTmpDir()
        dismiss(animated: true, completion: nil)
    }
}
