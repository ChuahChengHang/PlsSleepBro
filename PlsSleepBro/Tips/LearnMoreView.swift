//
//  LearnMoreViwe.swift
//  PlsSleepBro
//
//  Created by Chuah Cheng Hang on 23/11/25.
//

import SwiftUI

struct LearnMoreView: View {
    @Binding var tips: [String]
    @Binding var index: Int
    @Environment(\.dismiss) var dismiss
    @State private var dismissSheet: Bool = false
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(.tertiary)
                .frame(width: 350, height: 700)
                .shadow(color: .black.opacity(0.3), radius: 12, y: 4)
                .overlay(
                    VStack(spacing: 24) {
                        Image(systemName: "book.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .padding()
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.top, 40)
                        Text("Learn More")
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        if index < 10 {
                            Text("Getting enough sleep helps your body restore energy and your brain stay sharp. When you sleep too little, your body can’t complete its full sleep cycles, leaving you tired the next day. Aim for a consistent schedule and enough time in bed to wake up refreshed.")
                                .foregroundColor(.white.opacity(0.9))
                                .font(.title2)
                                .padding()
                                .frame(maxWidth: 320)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }else if index >= 10 && index < 20{
                            Text("Light tells your body when to be awake or sleepy. Bright light in the morning helps you feel alert, while dimmer light at night helps your brain prepare for sleep. Try reducing screen brightness before bed and getting natural sunlight during the day.")
                                .foregroundColor(.white.opacity(0.9))
                                .font(.title2)
                                .padding()
                                .frame(maxWidth: 320)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }else {
                            Text("Noise at night can interrupt your sleep even if you don’t fully wake up. Sudden sounds can pull you out of deep sleep and make you feel less rested in the morning. Keeping your room quiet or using gentle background noise can help you sleep more smoothly.")
                                .foregroundColor(.white.opacity(0.9))
                                .font(.title2)
                                .padding()
                                .frame(maxWidth: 320)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer()
                        Button {
                            dismissSheet = true
                            dismiss()
                        }label: {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(.blue)
                                .shadow(radius: 8, y: 4)
                                .frame(width: 330, height: 50)
                                .overlay(
                                    Text("Done")
                                        .foregroundStyle(.white)
                                        .bold()
                                )
                        }
                        .glassEffect(in: RoundedRectangle(cornerRadius: 14))
                        .sensoryFeedback(.impact(weight: .light), trigger: dismissSheet)
                        .padding()
                        Spacer()
                    }
                )
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    LearnMoreView(tips: .constant([]), index: .constant(0))
}
