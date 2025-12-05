import SwiftUI
import CoreLocation

/// Data model for magic hour visualization
struct MagicHourData {
    let sunTimes: SunTimes
    let currentTime: Date
    let coordinate: CLLocationCoordinate2D?
    let country: String?
    let region: String?
    
    /// Minutes remaining until sunset
    var minutesUntilSunset: Int {
        sunTimes.minutesUntilSunset
    }
    
    /// Minutes remaining until complete darkness (civil twilight end)
    var minutesUntilDark: Int {
        sunTimes.minutesUntilDark
    }
    
    /// Current phase of magic hour
    var phase: MagicHourPhase {
        sunTimes.phase
    }
    
    /// Progress from now to sunset (0.0 to 1.0)
    /// Used for gradient visualization
    var progressToSunset: Double {
        let totalMinutes = 120.0 // Show 2 hours before sunset
        let remaining = Double(minutesUntilSunset)
        return max(0, min(1, 1 - (remaining / totalMinutes)))
    }
    
    /// Progress from sunset to darkness (0.0 to 1.0)
    var progressToDark: Double {
        guard phase == .magicHour else { return 0 }
        let magicHourDuration = sunTimes.civilTwilight.timeIntervalSince(sunTimes.sunset)
        let elapsed = Date().timeIntervalSince(sunTimes.sunset)
        return max(0, min(1, elapsed / magicHourDuration))
    }
    
    /// Gradient colors for visualization based on current phase
    var gradientColors: [Color] {
        switch phase {
        case .beforeSunset:
            // Golden hour approaching sunset
            return [
                Color(red: 1.0, green: 0.8, blue: 0.3),
                Color(red: 1.0, green: 0.6, blue: 0.2),
                Color(red: 1.0, green: 0.4, blue: 0.3)
            ]
        case .magicHour:
            // Magic hour - sunset to twilight
            return [
                Color(red: 1.0, green: 0.5, blue: 0.2),
                Color(red: 0.9, green: 0.3, blue: 0.5),
                Color(red: 0.5, green: 0.2, blue: 0.6)
            ]
        case .afterDark:
            // After civil twilight
            return [
                Color(red: 0.2, green: 0.1, blue: 0.3),
                Color(red: 0.1, green: 0.05, blue: 0.2)
            ]
        }
    }
    
    /// Display text for countdown
    var countdownText: String {
        switch phase {
        case .beforeSunset:
            if minutesUntilSunset < 60 {
                return "日没まで \(minutesUntilSunset)分"
            } else {
                let hours = minutesUntilSunset / 60
                let mins = minutesUntilSunset % 60
                return "日没まで \(hours)時間\(mins)分"
            }
        case .magicHour:
            if minutesUntilDark < 60 {
                return "マジックアワー \(minutesUntilDark)分"
            } else {
                let hours = minutesUntilDark / 60
                let mins = minutesUntilDark % 60
                return "マジックアワー \(hours)時間\(mins)分"
            }
        case .afterDark:
            return "夜"
        }
    }
    
    /// Icon name for current phase
    var iconName: String {
        switch phase {
        case .beforeSunset:
            return "sun.max.fill"
        case .magicHour:
            return "sunset.fill"
        case .afterDark:
            return "moon.stars.fill"
        }
    }
    
    /// Formatted latitude string (e.g., "35.68°N")
    var latitudeString: String? {
        guard let coordinate = coordinate else { return nil }
        let direction = coordinate.latitude >= 0 ? "N" : "S"
        return String(format: "%.2f°%@", abs(coordinate.latitude), direction)
    }
    
    /// Formatted longitude string (e.g., "139.65°E")
    var longitudeString: String? {
        guard let coordinate = coordinate else { return nil }
        let direction = coordinate.longitude >= 0 ? "E" : "W"
        return String(format: "%.2f°%@", abs(coordinate.longitude), direction)
    }
    
    /// Combined coordinate string (e.g., "35.68°N, 139.65°E")
    var coordinateString: String? {
        guard let lat = latitudeString, let lon = longitudeString else { return nil }
        return "\(lat), \(lon)"
    }
}
