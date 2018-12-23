import Foundation

var now = Date()
let calendar = Calendar.current
var timerInterval : DateInterval? = nil

var futureDate: Date? = nil

let dateFormatter = DateFormatter()
  dateFormatter.dateStyle = .short
  dateFormatter.timeStyle = .short

print(dateFormatter.string(from: now))

var hour = 20
var minute = 30


futureDate = calendar.nextDate(after:now, matching:DateComponents(hour:hour, minute:minute), matchingPolicy: .nextTime, repeatedTimePolicy: .first, direction: .forward)

print(dateFormatter.string(from: futureDate!))

timerInterval = DateInterval(start: now, end: futureDate!)

print(timerInterval!.duration)
