//
//  GuidedAccessView.swift
//  PlsSleepBro
//
//  Created by Chuah Cheng Hang on 21/11/25.
//

import SwiftUI

struct GuidedAccessView: View {
    @Environment(\.dismiss) var dismiss
    @State private var success: Bool = false
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Why use guided access?")
                        .font(.largeTitle)
                        .bold()
                        .padding()
                    Spacer()
                }
                Text("""
                 Guided Access helps ensure accurate sleep tracking by keeping the app active
                 throughout the night. It prevents the screen from turning off and avoids
                 accidental taps.
                 """)
                .foregroundStyle(.white)
                .font(.subheadline)
                .padding()
                HStack {
                    Text("How to use Guided Access?")
                        .font(.largeTitle)
                        .bold()
                        .padding()
                    Spacer()
                }
                Text("To start a session, go to Settings > Accessibility > Guided Access and turn it on, then set a passcode.\n\nYou can start a session by opening the desired app and triple-clicking the side or home button, then choosing the options and tapping 'Start'.\n\nTo Stop a session triple-click the side or home button.")
                    .foregroundStyle(.white)
                    .font(.subheadline)
                    .padding()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                dismiss()
                                success = true
                            }label: {
                                Text("Done")
                            }
                            .sensoryFeedback(.impact(weight: .light), trigger: success)
                        }
                    }
                Spacer()
            }
        }
    }
}

#Preview {
    GuidedAccessView()
}
