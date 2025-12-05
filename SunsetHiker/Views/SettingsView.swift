import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var backgroundSettings: BackgroundSettings
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("背景スタイル")) {
                    ForEach(BackgroundStyle.allCases, id: \.self) { style in
                        Button(action: {
                            backgroundSettings.backgroundStyle = style
                        }) {
                            HStack {
                                if let imageName = style.imageName {
                                    Image(imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 60, height: 40)
                                        .cornerRadius(4)
                                } else {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 60, height: 40)
                                        .cornerRadius(4)
                                }
                                
                                Text(style.displayName)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if backgroundSettings.backgroundStyle == style {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(BackgroundSettings())
}
