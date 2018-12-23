//
//  ViewController.swift
//  Timer App
//
//  Created by Ravago on 7/25/18.
//  Copyright © 2018 blabblabla. All rights reserved.
//

import UIKit
import Foundation

enum AlarmMode: Int {
    case time, duration
}

class ViewController : UIViewController {
    
    let calendar = Calendar.current
    var futureDate: Date? = nil
    let dateFormatter = DateFormatter()
    var timer: Timer? = nil
    var timeLeftTimer: Timer? = nil
    let durationFormatter = DateComponentsFormatter()
    var currentMode: AlarmMode = .time
    var timerInterval: TimeInterval?  {
        get {
            if currentMode == .time {
                
                if let date = futureDate{
                    if(date > Date()){
                        return DateInterval(start: Date(), end: date).duration
                    }else{
                        return nil
                    }
                }
            }else if currentMode == .duration {
                return datePicker.countDownDuration
            }
            return nil
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var modeSwitch: UISegmentedControl!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBAction func modeSwitchHandler(_ sender: Any) {
        for mode in 0...1 {
            if(modeSwitch.isEnabledForSegment(at: mode)){
                currentMode = AlarmMode(rawValue: mode) ?? .time
                if(currentMode == .duration){
                    datePicker.datePickerMode = .countDownTimer
                }else if(currentMode == .time){
                    datePicker.datePickerMode = .time
                }
            }
        }
    }
    
    @IBAction func datePickerHandler(_ sender: UIDatePicker) {
        if currentMode == .time {
            let hourAndMinuteComponent = calendar.dateComponents(Set<Calendar.Component>([.hour, .minute]), from: sender.date)
            futureDate = calendar.nextDate(after:Date(), matching:hourAndMinuteComponent, matchingPolicy: .nextTime, repeatedTimePolicy: .first, direction: .forward)
        }
        
        if let date = futureDate {
            print(dateFormatter.string(from: date))
        }
        
        
        updateTimeRemaining()
        timeLeftTimer?.invalidate()
        timeLeftTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true){ timer in
            self.updateTimeRemaining()
        }
        
         timer?.invalidate()
         timer = Timer.scheduledTimer(withTimeInterval: timerInterval ?? 0.1, repeats: false){ timer in
            print("Alarm Done")
            self.titleLabel.text = "Countdown"
            self.timeLeftTimer?.invalidate()
         }
    }
    
    func updateTimeRemaining(){
        if let durationText = durationFormatter.string(from: timerInterval ?? 0){
            titleLabel.text = durationText
            print(durationText)
        } else{
            titleLabel.text = "Countdown"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // init formatters
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        durationFormatter.unitsStyle = .short
        durationFormatter.includesApproximationPhrase = true
        durationFormatter.includesTimeRemainingPhrase = true
        durationFormatter.allowedUnits = [.day, .hour, .minute, .second]
        durationFormatter.maximumUnitCount = 2
        
        print("hello world")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
