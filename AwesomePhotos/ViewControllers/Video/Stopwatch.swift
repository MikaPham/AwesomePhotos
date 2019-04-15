import Foundation

class Stopwatch
{
    var startTime : Date?
    
    var elapsedTime: TimeInterval
    {
        if let startTime = self.startTime
        {
            return -startTime.timeIntervalSinceNow
        }else{
            return 0
        }
    }
    
    var elapsedTimeAsString: String {
        return String(format: "%02d:%02d",
                      Int(elapsedTime / 60), Int(elapsedTime.truncatingRemainder(dividingBy: 60)), Int((elapsedTime * 10).truncatingRemainder(dividingBy: 10)))
    }
    
    var isRunning : Bool{
        return startTime != nil
    }
    
    func start(){
        startTime = Date()
    }
    func stop(){
        startTime = nil
    }
}
