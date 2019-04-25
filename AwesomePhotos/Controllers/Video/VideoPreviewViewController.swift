import UIKit
import AVKit

class PreviewVideoViewController : UIViewController
{
    var videoURL : URL!
    var avPlayer : AVPlayer?
    @IBOutlet weak var playAndPauseButton: UIButton!
    @IBOutlet weak var centerPlayButton: UIButton!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var totalDurationLabal: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewDidAppear(_ animated: Bool) {
        configurePreviewView()
        trackTimeProgress()
    }

    //Sets up the video preview
    fileprivate func configurePreviewView(){
        avPlayer = AVPlayer(url: videoURL)
        let avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.frame = view.bounds
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoView.layer.insertSublayer(avPlayerLayer, at: 0)
        
        view.layoutIfNeeded()
        
        let playerItem = AVPlayerItem(url: videoURL as URL)
        avPlayer!.replaceCurrentItem(with: playerItem)
        avPlayer!.pause()
        }
    
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
            
            print(secondsText)
            
            // Moving the thumb on the slider
            if let duration = self.avPlayer?.currentItem?.duration{
                let durationSeconds = CMTimeGetSeconds(duration)
                
                self.slider.value = Float(seconds / durationSeconds)
                
            }
        })
    }
    
    
    var isPlaying = false
    
    //Start the video
    @IBAction func playButtonPressed(_ sender: UIButton) {
        
        //Sets the duration of the entire video
        if let duration = avPlayer?.currentItem?.duration{
            let seconds = CMTimeGetSeconds(duration)
            let secondsDisplayed = String(format: "%02d", Int(seconds) % 60)
            let minutesDisplayed = String(format: "%02d", Int(seconds) / 60)
            totalDurationLabal.text = "\(minutesDisplayed):\(secondsDisplayed)"
        }
        centerPlayButton.isHidden = true
        playAndPauseButton.isHidden = false

        if isPlaying == false{
            avPlayer!.play()
            playAndPauseButton.setImage(UIImage(named: "icons8-pause"), for: .normal)
            isPlaying = true
        }
        else{
            avPlayer!.pause()
            playAndPauseButton.setImage(UIImage(named: "icons8-start"), for: .normal)
            isPlaying = false
        }
    }
    
    @IBAction func changeSliderDurationPressed(_ sender: UISlider) {
        
        slider.addTarget(self, action: #selector(handleSliderChange), for: .valueChanged)
    }
    
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
    
    @IBAction func dismissPreviewButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
