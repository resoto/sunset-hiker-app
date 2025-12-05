import SwiftUI

enum TimePeriod {
    case dawn      // 夜明け (4:00-6:00)
    case morning   // 朝 (6:00-10:00)
    case day       // 昼 (10:00-16:00)
    case sunset    // 夕焼け (16:00-18:00)
    case dusk      // 夕暮れ (18:00-20:00)
    case night     // 夜空 (20:00-4:00)
    
    var gradientColors: [Color] {
        switch self {
        case .dawn:
            // Deep purple to warm orange
            return [
                Color(red: 0.2, green: 0.1, blue: 0.3),
                Color(red: 0.4, green: 0.2, blue: 0.4),
                Color(red: 0.8, green: 0.4, blue: 0.3),
                Color(red: 1.0, green: 0.6, blue: 0.4)
            ]
        case .morning:
            // Light blue to cyan
            return [
                Color(red: 0.4, green: 0.7, blue: 0.9),
                Color(red: 0.5, green: 0.8, blue: 0.95),
                Color(red: 0.6, green: 0.85, blue: 1.0)
            ]
        case .day:
            // Bright blue sky
            return [
                Color(red: 0.3, green: 0.6, blue: 0.95),
                Color(red: 0.5, green: 0.75, blue: 1.0),
                Color(red: 0.7, green: 0.85, blue: 1.0)
            ]
        case .sunset:
            // Orange to pink to purple (夕焼け)
            return [
                Color(red: 1.0, green: 0.5, blue: 0.2),
                Color(red: 1.0, green: 0.4, blue: 0.4),
                Color(red: 0.9, green: 0.3, blue: 0.6),
                Color(red: 0.6, green: 0.2, blue: 0.5)
            ]
        case .dusk:
            // Deep purple to dark blue
            return [
                Color(red: 0.3, green: 0.2, blue: 0.5),
                Color(red: 0.2, green: 0.2, blue: 0.4),
                Color(red: 0.1, green: 0.15, blue: 0.3)
            ]
        case .night:
            // Dark blue to black (夜空)
            return [
                Color(red: 0.05, green: 0.1, blue: 0.2),
                Color(red: 0.02, green: 0.05, blue: 0.15),
                Color(red: 0.0, green: 0.0, blue: 0.05)
            ]
        }
    }
    
    static func current() -> TimePeriod {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 4..<6:
            return .dawn
        case 6..<10:
            return .morning
        case 10..<16:
            return .day
        case 16..<18:
            return .sunset
        case 18..<20:
            return .dusk
        default:
            return .night
        }
    }
}
