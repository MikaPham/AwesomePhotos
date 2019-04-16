import Foundation

class SwitchBackAndForth
{
    //Switching the front and back camera
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

}


