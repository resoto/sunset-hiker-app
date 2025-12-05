import SwiftUI

struct GradientBackground: View {
    let timePeriod: TimePeriod
    let mountainImage: String?
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: timePeriod.gradientColors),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            if let mountainImage = mountainImage {
                Image(mountainImage)
                    .resizable()
                    .scaledToFill()
                    .opacity(0.12)
                    .blendMode(.multiply)
                    .ignoresSafeArea()
            }
        }
        .animation(.easeInOut(duration: 2.0), value: timePeriod.gradientColors)
    }
}

#Preview {
    GradientBackground(timePeriod: .sunset, mountainImage: nil)
}
