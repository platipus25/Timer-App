//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport
import Foundation



class MyViewController : UIViewController {
    var now = Date()
    let calendar = Calendar.current
    var timerInterval : DateInterval? = nil
    var timerDuration : TimeInterval? = nil
    var futureDate: Date? = nil
    let dateFormatter = DateFormatter()
    var timer: Timer? = nil
    let durationFormatter = DateComponentsFormatter()
    
    func updateTimeRemaining(duration: TimeInterval){
        print(durationFormatter.string(from:timerDuration!)!)
    }
    @IBAction func timeChooserHandeler(sender: UIDatePicker){
        now = Date()
        futureDate = sender.date
        let hourAndMinuteComponent = calendar.dateComponents(Set<Calendar.Component>([.hour, .minute]), from: futureDate!)
        futureDate = calendar.nextDate(after:now, matching:hourAndMinuteComponent, matchingPolicy: .nextTime, repeatedTimePolicy: .first, direction: .forward)

        print(dateFormatter.string(from: futureDate!))
        timerInterval = DateInterval(start: now, end: futureDate!)
        timerDuration = timerInterval!.duration
        updateTimeRemaining(duration:timerDuration!)
        if(timer != nil){
            timer!.invalidate()
        }
        timer = Timer.scheduledTimer(withTimeInterval: timerDuration ?? 0.1, repeats: false){ timer in
             print("Timer Fired")
         }
    }
    override func loadView() {
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        durationFormatter.unitsStyle = .short
        durationFormatter.includesApproximationPhrase = true
        durationFormatter.includesTimeRemainingPhrase = true
        durationFormatter.allowedUnits = [.day, .hour, .minute, .second]
        durationFormatter.maximumUnitCount = 2
        
        let view = UIView()
        view.backgroundColor = .white

        let label = UILabel()
        label.frame = CGRect(x: 200, y: 250, width: 200, height: 20)
        label.text = "Hello World!"
        label.textColor = .black
        
        let timeChooser = UIDatePicker()
        timeChooser.datePickerMode = .time
        timeChooser.addTarget(nil, action: #selector(timeChooserHandeler(sender:)), for: .valueChanged)
        
        //print(timerDuration!)
        
        /*let timer = Timer.scheduledTimer(withTimeInterval: timerDuration ?? 0.1, repeats: false){ timer in
            print("Timer Fired")
        }*/
        
        
        view.addSubview(label)
        view.addSubview(timeChooser)
        self.view = view
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()








