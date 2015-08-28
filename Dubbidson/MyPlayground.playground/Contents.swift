//: Playground - noun: a place where people can play

import UIKit

let components = NSDateComponents()
components.second = 30

let formatter = NSDateComponentsFormatter()
//formatter.unitsStyle = NSDateComponentsFormatterUnitsStyle.Positional
//formatter.zeroFormattingBehavior = .Pad
//formatter.allowedUnits = (NSCalendarUnit.CalendarUnitMinute | NSCalendarUnit.CalendarUnitSecond)
formatter.allowedUnits = NSCalendarUnit.CalendarUnitSecond
formatter.stringFromDateComponents(components)
//formatter.stringFromTimeInterval(500)


//formatter.zeroFormattingBehavior = .Pad
//formatter.allowedUnits = [.Minute, .Second]

let seconds = 29.9769614512472
round(seconds)