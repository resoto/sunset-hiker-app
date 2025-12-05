import SwiftUI

struct ContentView: View {
    @State private var currentTime = Date()
    @State private var timePeriod = TimePeriod.current()
    @StateObject private var locationManager = LocationManager()
    @State private var magicHourData: MagicHourData?
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // Dynamic gradient background
            GradientBackground(timePeriod: timePeriod)
            
            VStack(spacing: 0) {
                // Magic hour visualization at top
                if let magicHourData = magicHourData {
                    MagicHourView(magicHourData: magicHourData)
                        .padding(.top, 60)
                        .transition(.opacity)
                }
                
                Spacer()
                
                // Time display in center
                VStack(spacing: 20) {
                    Text(timeString)
                        .font(.system(size: 80, weight: .thin, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    // Date display
                    Text(dateString)
                        .font(.system(size: 24, weight: .light, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                    
                    // Time period label
                    Text(timePeriodLabel)
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(.white.opacity(0.2))
                                .shadow(color: .black.opacity(0.2), radius: 5)
                        )
                }
                
                Spacer()
            }
        }
        .onAppear {
            // Request location permission on appear
            locationManager.requestPermission()
        }
        .onChange(of: locationManager.location) { location in
            // Update magic hour data when location changes
            updateMagicHourData()
        }
        .onReceive(timer) { _ in
            currentTime = Date()
            let newPeriod = TimePeriod.current()
            if newPeriod != timePeriod {
                withAnimation(.easeInOut(duration: 2.0)) {
                    timePeriod = newPeriod
                }
            }
            
            // Update magic hour data every minute
            updateMagicHourData()
        }
    }
    
    private func updateMagicHourData() {
        guard let location = locationManager.location else { return }
        
        let sunTimes = SunCalculator.calculate(for: location.coordinate)
        
        // Extract country and region from placemark
        let country = locationManager.placemark?.country
        let region = locationManager.placemark?.locality ?? locationManager.placemark?.administrativeArea
        
        withAnimation(.easeInOut(duration: 0.5)) {
            magicHourData = MagicHourData(
                sunTimes: sunTimes,
                currentTime: currentTime,
                coordinate: location.coordinate,
                country: country,
                region: region
            )
        }
    }
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: currentTime)
    }
    
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日 (E)"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: currentTime)
    }
    
    private var timePeriodLabel: String {
        switch timePeriod {
        case .dawn:
            return "夜明け"
        case .morning:
            return "朝"
        case .day:
            return "昼"
        case .sunset:
            return "夕焼け"
        case .dusk:
            return "夕暮れ"
        case .night:
            return "夜空"
        }
    }
}

#Preview {
    ContentView()
}
