import SwiftUI

struct GradientBackground: View {
    let timePeriod: TimePeriod
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: timePeriod.gradientColors),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 2.0), value: timePeriod.gradientColors)
    }
}

#Preview {
    GradientBackground(timePeriod: .sunset)
}
