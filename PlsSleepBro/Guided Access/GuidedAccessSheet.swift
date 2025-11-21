import SwiftUI

struct GuidedAccessSheet: View {
    @State private var guidedAccess = UIAccessibility.isGuidedAccessEnabled
    @Binding var hasSeenSheet: Bool
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "lock.rectangle.fill")
                .resizable()
                .frame(width: 140, height: 100)
                .foregroundStyle(.red)
            Text(guidedAccess ? "Guided Access is ON" : "Guided Access is OFF")
                .font(.title)
                .padding(.top)
            if !guidedAccess {
                VStack(spacing: 16) {
                    Text("""
                         Guided Access helps ensure accurate sleep tracking by keeping the app active
                         throughout the night. It prevents the screen from turning off and avoids
                         accidental taps.
                         """)
                    .multilineTextAlignment(.center)
                    .padding(.top)
                    
                    Text("""
Settings → Accessibility → Guided Access  
Then turn it ON and set a passcode.
""")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                }
                Button {
                    Task {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            await UIApplication.shared.open(url)
                        }
                    }
                } label: {
                    //                        ZStack {
                    //                            RoundedRectangle(cornerRadius: 12)
                    //                                .fill(Color.blue)
                    //                                .frame(height: 50)
                    //
                    //                            Text("Go to Settings")
                    //                                .foregroundColor(.white)
                    //                                .font(.headline)
                    //                        }
                    //                        .padding(.horizontal)
                    Text("Go to Settings")
                }
            }else if guidedAccess{
                Text("""
                     Our App uses Guided Access to prevents the screen from turning off and avoids
                         accidental taps.
                     """)
                .multilineTextAlignment(.center)
                .padding(.top)
            }
            Spacer()
            VStack {
                Button {
                    hasSeenSheet = true
                    dismiss()
                }label: {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(.red)
                        .frame(width: 370, height: 50)
                        .overlay(
                            Text("Done")
                                .foregroundStyle(.white)
                                .bold()
                        )
                        .glassEffect(in: RoundedRectangle(cornerRadius: 14))
                }
                .sensoryFeedback(.impact(weight: .light), trigger: hasSeenSheet)
            }
        }
        .preferredColorScheme(.dark)
        
        
        .onReceive(
            NotificationCenter.default.publisher(
                for: UIAccessibility.guidedAccessStatusDidChangeNotification
            )
        ) { _ in
            guidedAccess = UIAccessibility.isGuidedAccessEnabled
        }
        
        .onAppear {
            guidedAccess = UIAccessibility.isGuidedAccessEnabled
        }
        
        .padding()
    }
}

#Preview {
    GuidedAccessSheet(hasSeenSheet: .constant(false))
}
