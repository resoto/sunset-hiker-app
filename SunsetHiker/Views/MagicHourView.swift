import SwiftUI
import CoreLocation

/// Circular visualization of magic hour on clock face
struct MagicHourView: View {
    let magicHourData: MagicHourData
    
    var body: some View {
        ZStack {
            // Gradient arc showing remaining time
            GradientArc(
                progress: arcProgress,
                colors: magicHourData.gradientColors,
                lineWidth: 12
            )
            .frame(width: 280, height: 280)
            
            // Center info display
            VStack(spacing: 8) {
                // Icon
                Image(systemName: magicHourData.iconName)
                    .font(.system(size: 40))
                    .foregroundStyle(
                        LinearGradient(
                            colors: magicHourData.gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .black.opacity(0.3), radius: 5)
                
                // Countdown text
                Text(magicHourData.countdownText)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 3)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.2), radius: 5)
                    )
                
                // Sunset and twilight times
                VStack(spacing: 4) {
                    TimeLabel(
                        icon: "sunset.fill",
                        time: magicHourData.sunTimes.sunset,
                        label: "日没"
                    )
                    
                    TimeLabel(
                        icon: "moon.fill",
                        time: magicHourData.sunTimes.civilTwilight,
                        label: "薄明終了"
                    )
                }
                .padding(.top, 8)
                
                // Location information
                if let coordinateString = magicHourData.coordinateString {
                    VStack(spacing: 4) {
                        HStack(spacing: 6) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text(coordinateString)
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .foregroundColor(.white)
                        }
                        
                        if let country = magicHourData.country, let region = magicHourData.region {
                            Text("\(country) · \(region)")
                                .font(.system(size: 11, weight: .regular, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                        } else if let country = magicHourData.country {
                            Text(country)
                                .font(.system(size: 11, weight: .regular, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial.opacity(0.5))
                    )
                    .padding(.top, 6)
                }
            }
        }
    }
    
    /// Calculate arc progress based on phase
    private var arcProgress: Double {
        switch magicHourData.phase {
        case .beforeSunset:
            return magicHourData.progressToSunset
        case .magicHour:
            return magicHourData.progressToDark
        case .afterDark:
            return 1.0
        }
    }
}

/// Gradient arc shape for circular progress
struct GradientArc: View {
    let progress: Double
    let colors: [Color]
    let lineWidth: CGFloat
    
    var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(
                    Color.white.opacity(0.1),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
            
            // Gradient progress arc
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: colors),
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(-90 + 360 * progress)
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: colors.first?.opacity(0.5) ?? .clear, radius: 8)
                .animation(.easeInOut(duration: 1.0), value: progress)
        }
    }
}

/// Time label with icon
struct TimeLabel: View {
    let icon: String
    let time: Date
    let label: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.8))
            
            Text(label)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
            
            Text(timeString)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(.ultraThinMaterial.opacity(0.5))
        )
    }
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: time)
    }
}

#Preview {
    let coordinate = CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6503) // Tokyo
    let sunTimes = SunCalculator.calculate(for: coordinate)
    let magicHourData = MagicHourData(
        sunTimes: sunTimes,
        currentTime: Date(),
        coordinate: coordinate,
        country: "日本",
        region: "東京都"
    )
    
    ZStack {
        Color.black
        MagicHourView(magicHourData: magicHourData)
    }
}
