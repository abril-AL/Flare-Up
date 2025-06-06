////
////  ScreenTimeParser.swift.swift
////  flareup
////
////  Created by Richelle Shim on 5/31/25.
////
//
//import Foundation
//
//struct ScreenTimeEntry: Identifiable {
//    var id = UUID()
//    let app: String
//    let minutes: Int
//}
//
//struct ScreenTimeParser {
//    static func parse(text: String) -> [ScreenTimeEntry] {
//        let lines = text.components(separatedBy: .newlines)
//        var results: [ScreenTimeEntry] = []
//
//        let regex = try! NSRegularExpression(pattern: #"([A-Za-z\s]+)\s[-–]\s((\d+)h)?\s*((\d+)m)?"#, options: [])
//
//        for line in lines {
//            let range = NSRange(location: 0, length: line.utf16.count)
//            if let match = regex.firstMatch(in: line, options: [], range: range) {
//                let appRange = match.range(at: 1)
//                let hoursRange = match.range(at: 3)
//                let minutesRange = match.range(at: 5)
//
//                let app = (line as NSString).substring(with: appRange).trimmingCharacters(in: .whitespaces)
//                let hours = hoursRange.location != NSNotFound ? Int((line as NSString).substring(with: hoursRange)) ?? 0 : 0
//                let minutes = minutesRange.location != NSNotFound ? Int((line as NSString).substring(with: minutesRange)) ?? 0 : 0
//
//                results.append(ScreenTimeEntry(app: app, minutes: hours * 60 + minutes))
//            }
//        }
//
//        return results
//    }
//}
