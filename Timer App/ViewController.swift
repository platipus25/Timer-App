//
//  ViewController.swift
//  Timer App
//
//  Created by Ravago on 7/25/18.
//  Copyright © 2018 blabblabla. All rights reserved.
//

import UIKit
import Foundation
import UserNotifications
import AVFoundation

class Alarm {
    let durationFormatter = DateComponentsFormatter()
    let dateFormatter = DateFormatter()
    let uuid: String
    let endDate: Date
    let show:  (String) -> Void
    let cleanup: (Alarm) -> Void
    var alarmTimer: Timer? = nil
    
    init(endDate: Date, notification: (String, String, Date) -> String, show: @escaping (String) -> Void, cleanup: @escaping (Alarm) -> Void){
        self.endDate = endDate
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        durationFormatter.unitsStyle = .short
        durationFormatter.includesApproximationPhrase = false//true
        durationFormatter.includesTimeRemainingPhrase = false//true
        durationFormatter.allowedUnits = [.day, .hour, .minute, .second]
        durationFormatter.maximumUnitCount = 2
        self.show =  show
        self.cleanup = cleanup
        self.uuid = notification("Alarm Done", dateFormatter.string(from:endDate), endDate)
        
        updateTime(timer: nil)
        alarmTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: updateTime)
    }
    
    func updateTime(timer: Timer?){
        var duration: TimeInterval?
        if(Date() < endDate){
            duration = DateInterval(start: Date(), end: endDate).duration
        }

        if((duration ?? 0) < 1.0){
            self.cleanup(self)
            return
        }
        
        guard let durationString = durationFormatter.string(from: duration ?? 0) else {return}
        show(durationString)
        print(durationString)
    }
    
    func cancel(){
        alarmTimer?.invalidate()
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [uuid])
    }
}

class ViewController : UIViewController {
    let calendar = Calendar.current
    var futureDate: Date? = nil
    var alarm: Alarm? = nil
    var uuidString: String? = nil //
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    var timerInterval: TimeInterval?  {
        get {
            if let date = futureDate{
                if(date > Date()){
                    return DateInterval(start: Date(), end: date).duration
                }else{
                    return nil
                }
            }
            return nil
        }
    }
    
    @IBAction func datePickerHandler(_ sender: UIDatePicker) {
        let hourAndMinuteComponent = calendar.dateComponents(Set<Calendar.Component>([.hour, .minute]), from: sender.date)
        
        futureDate = calendar.nextDate(after:Date(), matching:hourAndMinuteComponent, matchingPolicy: .nextTime, repeatedTimePolicy: .first, direction: .forward)
        
        alarm?.cancel()
        alarm = Alarm(endDate: futureDate ?? Date(), notification: self.configureNotification, show: show, cleanup: alarmCleanup)
    }
    
    func show(text: String){
        titleLabel.text = text
    }
    
    func alarmCleanup(alarm: Alarm) {
        inAppNotification()
        print("Cleaning Up")
        alarm.cancel()
        self.alarm = nil
        show(text: "Countdown")
    }
    
    func inAppNotification(){
        let systemSoundID: SystemSoundID = 1307 // Input : https://github.com/TUNER88/iOSSystemSoundsLibrary
        // to play sound
        AudioServicesPlaySystemSound (systemSoundID)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let center = UNUserNotificationCenter.current()
        // Request permission to display alerts and play sounds.
        center.requestAuthorization(options: [.alert, .sound])
        { (granted, error) in
            print("Authorized: \(granted) Errors: \(String(describing: error))")
            // Enable or disable features based on authorization.
        }
        
        print("hello world")
    }
    
    func configureNotification(title: String, body: String, date: Date) -> String {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { (settings) in
            // Do not schedule notifications if not authorized.
            guard settings.authorizationStatus == .authorized else {return}
            
            if settings.alertSetting == .enabled {
                // Schedule an alert-only notification.
                let content = UNMutableNotificationContent()
                content.title = title
                content.body = body
                content.sound = UNNotificationSound.default
                let dateComponents = self.calendar.dateComponents(Set<Calendar.Component>([.hour, .minute]), from: date)
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                // Create the request
                let uuidString = UUID().uuidString
                let request = UNNotificationRequest(identifier: uuidString,
                                                    content: content, trigger: trigger)
                print(request)
                // Schedule the request with the system.
                let notificationCenter = UNUserNotificationCenter.current()
                notificationCenter.add(request) { (error) in
                    if error != nil {
                        // Handle any errors.
                        print(error!)
                    }
                }
                self.uuidString = uuidString
            }
        }
        return (uuidString ?? "")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


/*class ViewController : UIViewController {
    
    let calendar = Calendar.current
    var futureDate: Date? = nil
    let dateFormatter = DateFormatter() //
    var timer: Timer? = nil //
    var timeLeftTimer: Timer? = nil //
    let durationFormatter = DateComponentsFormatter() //
    var notificationUUID: String? = nil; //
    var timerInterval: TimeInterval?  {
        get {
            if let date = futureDate{
                if(date > Date()){
                    return DateInterval(start: Date(), end: date).duration
                }else{
                    return nil
                }
            }
            return nil
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    
    func configureNotification(title: String, body: String, date: Date){
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { (settings) in
            // Do not schedule notifications if not authorized.
            guard settings.authorizationStatus == .authorized else {return}
            
            if settings.alertSetting == .enabled {
                // Schedule an alert-only notification.
                let content = UNMutableNotificationContent()
                content.title = title
                content.body = body
                content.sound = UNNotificationSound.default
                let dateComponents = self.calendar.dateComponents(Set<Calendar.Component>([.hour, .minute]), from: date)
                let trigger = UNCalendarNotificationTrigger(
                    dateMatching: dateComponents, repeats: false)
                // Create the request
                let uuidString = UUID().uuidString
                let request = UNNotificationRequest(identifier: uuidString,
                                                    content: content, trigger: trigger)
                print(request)
                // Schedule the request with the system.
                let notificationCenter = UNUserNotificationCenter.current()
                notificationCenter.add(request) { (error) in
                    if error != nil {
                        // Handle any errors.
                        print(error!)
                    }
                }
                if(self.notificationUUID != nil){
                    self.cancelNotification(uuid: self.notificationUUID!)
                }
                self.notificationUUID = uuidString
                
            }
        }
    }
    
    func cancelNotification(uuid: String){
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [uuid])
    }
    
    @IBAction func datePickerHandler(_ sender: UIDatePicker) {
        let hourAndMinuteComponent = calendar.dateComponents(Set<Calendar.Component>([.hour, .minute]), from: sender.date)
        futureDate = calendar.nextDate(after:Date(), matching:hourAndMinuteComponent, matchingPolicy: .nextTime, repeatedTimePolicy: .first, direction: .forward)
        if let date = futureDate {
            print(dateFormatter.string(from: date))
        }
        
        updateTimeRemaining()
        configureNotification(title: "Timer Done", body: "It's "+dateFormatter.string(from:futureDate ?? Date()), date:futureDate ?? Date())
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
        durationFormatter.includesApproximationPhrase = false//true
        durationFormatter.includesTimeRemainingPhrase = false//true
        durationFormatter.allowedUnits = [.day, .hour, .minute, .second]
        durationFormatter.maximumUnitCount = 2
        
        let center = UNUserNotificationCenter.current()
        // Request permission to display alerts and play sounds.
        center.requestAuthorization(options: [.alert, .sound])
        { (granted, error) in
            // Enable or disable features based on authorization.
        }
        
        print("hello world")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
*/
