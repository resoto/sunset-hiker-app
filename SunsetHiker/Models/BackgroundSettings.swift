import SwiftUI

enum BackgroundStyle: String, CaseIterable {
    case mountains = "mountain_range"
    case peak = "single_peak"
    case hills = "rolling_hills"
    case none = "none"
    
    var displayName: String {
        switch self {
        case .mountains: return "山脈"
        case .peak: return "単峰"
        case .hills: return "丘陵"
        case .none: return "なし"
        }
    }
    
    var imageName: String? {
        self == .none ? nil : self.rawValue
    }
}

class BackgroundSettings: ObservableObject {
    @AppStorage("backgroundStyle") var backgroundStyle: BackgroundStyle = .mountains
}
