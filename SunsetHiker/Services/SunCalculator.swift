import Foundation
import CoreLocation

/// Calculates sunset and civil twilight times based on geographic coordinates
/// Uses NOAA solar calculation algorithms
struct SunCalculator {
    
    /// Calculate sunset and civil twilight times for a given location and date
    static func calculate(for coordinate: CLLocationCoordinate2D, date: Date = Date()) -> SunTimes {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        
        guard let year = components.year,
              let month = components.month,
              let day = components.day else {
            return SunTimes(sunset: date, civilTwilight: date)
        }
        
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        
        // Calculate Julian day
        let a = (14 - month) / 12
        let y = year + 4800 - a
        let m = month + 12 * a - 3
        let julianDay = day + (153 * m + 2) / 5 + 365 * y + y / 4 - y / 100 + y / 400 - 32045
        
        // Calculate sunset
        let sunsetMinutes = calculateSunEventMinutes(
            julianDay: julianDay,
            latitude: latitude,
            longitude: longitude,
            zenith: 90.833 // Sunset zenith angle
        )
        
        // Calculate civil twilight end (sun 6° below horizon)
        let twilightMinutes = calculateSunEventMinutes(
            julianDay: julianDay,
            latitude: latitude,
            longitude: longitude,
            zenith: 96.0 // Civil twilight zenith angle
        )
        
        // Convert minutes to Date
        let sunset = dateFromMinutes(sunsetMinutes, year: year, month: month, day: day)
        let twilight = dateFromMinutes(twilightMinutes, year: year, month: month, day: day)
        
        return SunTimes(sunset: sunset, civilTwilight: twilight)
    }
    
    private static func calculateSunEventMinutes(julianDay: Int, latitude: Double, longitude: Double, zenith: Double) -> Double {
        // Convert latitude to radians
        let latRad = latitude * .pi / 180.0
        
        // Calculate day of year
        let n = Double(julianDay - 2451545)
        
        // Mean solar time
        let meanSolarTime = n - (longitude / 360.0)
        
        // Solar mean anomaly
        let M = (0.9856 * meanSolarTime - 3.289).truncatingRemainder(dividingBy: 360)
        let MRad = M * .pi / 180.0
        
        // Sun's true longitude
        var L = M + 1.916 * sin(MRad) + 0.020 * sin(2 * MRad) + 282.634
        L = L.truncatingRemainder(dividingBy: 360)
        let LRad = L * .pi / 180.0
        
        // Sun's right ascension
        var RA = atan(0.91764 * tan(LRad)) * 180.0 / .pi
        RA = RA.truncatingRemainder(dividingBy: 360)
        
        // Adjust RA to be in same quadrant as L
        let Lquadrant = floor(L / 90.0) * 90.0
        let RAquadrant = floor(RA / 90.0) * 90.0
        RA = RA + (Lquadrant - RAquadrant)
        
        // Convert RA to hours
        RA = RA / 15.0
        
        // Sun's declination
        let sinDec = 0.39782 * sin(LRad)
        let cosDec = cos(asin(sinDec))
        
        // Sun's local hour angle
        let zenithRad = zenith * .pi / 180.0
        let cosH = (cos(zenithRad) - sinDec * sin(latRad)) / (cosDec * cos(latRad))
        
        // Check if sun never sets or never rises
        if cosH > 1 {
            // Sun never rises
            return 0
        } else if cosH < -1 {
            // Sun never sets
            return 1440
        }
        
        // Calculate hour angle for sunset (in degrees)
        let H = acos(cosH) * 180.0 / .pi
        
        // Convert to hours
        let hourAngle = H / 15.0
        
        // Local mean time of setting
        let T = hourAngle + RA - (0.06571 * meanSolarTime) - 6.622
        
        // Adjust to UTC
        var UT = T - (longitude / 15.0)
        UT = UT.truncatingRemainder(dividingBy: 24)
        
        // Convert to local time zone (JST = UTC+9)
        let localTime = UT + 9.0
        
        // Convert to minutes
        return localTime * 60.0
    }
    
    private static func dateFromMinutes(_ minutes: Double, year: Int, month: Int, day: Int) -> Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = Int(minutes / 60.0)
        components.minute = Int(minutes.truncatingRemainder(dividingBy: 60))
        components.timeZone = TimeZone.current
        
        return calendar.date(from: components) ?? Date()
    }
}

/// Container for sunset and civil twilight times
struct SunTimes {
    let sunset: Date
    let civilTwilight: Date
    
    /// Minutes until sunset from now
    var minutesUntilSunset: Int {
        let interval = sunset.timeIntervalSince(Date())
        return max(0, Int(interval / 60))
    }
    
    /// Minutes until civil twilight ends from now
    var minutesUntilDark: Int {
        let interval = civilTwilight.timeIntervalSince(Date())
        return max(0, Int(interval / 60))
    }
    
    /// Current magic hour phase
    var phase: MagicHourPhase {
        let now = Date()
        if now < sunset {
            return .beforeSunset
        } else if now < civilTwilight {
            return .magicHour
        } else {
            return .afterDark
        }
    }
}

enum MagicHourPhase {
    case beforeSunset
    case magicHour
    case afterDark
}
