//
//  NSDateFormatter.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 05/04/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//
import Foundation
extension DateFormatter {
    
    @nonobjc static let hourAndDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    
    @nonobjc static let hourAndMin: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "H:mm a"
        return formatter
    }()
    
    @nonobjc static let localeMediumStyle: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
            formatter.locale = Locale(identifier: countryCode)
        }
        return formatter
    }()
    
    @nonobjc static let dayMonthYearHourMinute: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MM yyyy HH:mm"
        return formatter
    }()
    
    @nonobjc static let MonthDayYearHourMinute: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM, dd yyyy HH:mm"
        return formatter
    }()
    
    @nonobjc static let InternationalFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM dd yyyy HH:mm"
        return formatter
    }()
    
    @nonobjc static let ShortInternationalFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM dd yyyy"
        return formatter
    }()
    
    @nonobjc static let dayMonthAndYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MM yyyy"
        return formatter
    }()
    @nonobjc static let MonthdayAndYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MM yyyy"
        return formatter
    }()
    @nonobjc static let dayMonthAndYear2: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter
    }()
    
    @nonobjc static let yearMonthAndDay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        return formatter
    }()
    
    @nonobjc static let monthAndYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MM yyyy")
        return formatter
    }()
    @nonobjc static let year: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("yyyy")
        return formatter
    }()
    @nonobjc static let month: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMM")
        return formatter
    }()
    @nonobjc static let ddMMMyyyy: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("dd MMM yyyy")
        return formatter
    }()
    @nonobjc static let MMMddHHmm: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMM. dd, HH:mm")
        return formatter
    }()
    @nonobjc static let MMMyyyy: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMM-yyyy")
        return formatter
    }()
    @nonobjc static let MMddyyyy: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MM dd yyyy")
        return formatter
    }()
}
extension Date {
    
    /// Prints a string representation for the date with the given formatter
    func string(with format: DateFormatter) -> String {
        return format.string(from: self as Date)
    }
    
    func MonthDayYearHourMinute() -> String {
        return DateFormatter.MonthDayYearHourMinute.string(from: self as Date)
    }
    
    /// Creates an `NSDate` from the given string and formatter. Nil if the string couldn't be parsed
    init?(string: String, formatter: DateFormatter) {
        guard let date = formatter.date(from: string) else { return nil }
        self.init(timeIntervalSince1970: date.timeIntervalSince1970)
    }
    init?(_ date: Int) {
       self.init(timeIntervalSince1970: TimeInterval(date/1000))
    }
    
    var monthYearLabel: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: self)
    }
    func toMillis() -> Int! {
        return Int(self.timeIntervalSince1970 * 1000)
    }
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func endOfMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }
    
    func midnight() -> Date {
        let gregorian = Calendar.current
        let components = gregorian.dateComponents([.year, .month, .day], from: self)
        return gregorian.date(from: components)!
    }
    
    func isToday() -> Bool {
        let gregorian = Calendar.current
        return gregorian.isDateInToday(self)
    }
    
    func isYesterday() -> Bool {
        let gregorian = Calendar.current
        return gregorian.isDateInYesterday(self)
    }
}
