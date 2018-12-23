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

class ViewController : UIViewController {
    
    let calendar = Calendar.current
    var futureDate: Date? = nil
    let dateFormatter = DateFormatter()
    var timer: Timer? = nil
    var timeLeftTimer: Timer? = nil
    let durationFormatter = DateComponentsFormatter()
    var notificationUUID: String? = nil;
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
