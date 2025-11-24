//
//  TipsView.swift
//  PlsSleepBro
//
//  Created by Chuah Cheng Hang on 21/11/25.
//

import SwiftUI

struct TipsView: View {
    @State private var title: String = "Tip"
    @State private var tip: [String] = [
        "Try to keep your bedtime consistent — your body falls asleep faster with routine.",
        "If you often wake during the night, review your room temperature and comfort level.",
        "Avoid heavy meals 2–3 hours before sleeping to prevent night awakenings.",
        "Limit caffeine after the afternoon, as it can reduce deep sleep at night.",
        "If you wake up frequently, avoid large amounts of water right before bed.",
        "A relaxing pre-sleep routine helps increase total time asleep.",
        "If you struggle to sleep at night, avoid long evening naps.",
        "Your room should be quiet, dark, and cool to support longer uninterrupted sleep.",
        "Reducing screen exposure before bed can help you fall asleep more easily.",
        "Gentle stretching or calm breathing before bed can improve sleep duration.",
        "Keep your room as dark as possible — even small light sources can disrupt deep sleep.",
        "Avoid sleeping with bright LEDs in your room; cover them or turn them off.",
        "If you need to get up at night, use dim red or amber lights to avoid waking fully.",
        "Street lights leaking in? Consider blackout curtains to protect night sleep quality.",
        "Blue light in the bedroom can reduce melatonin — keep screens out before sleep.",
        "Lower evening light levels 1–2 hours before bed to help your body prepare for sleep.",
        "Night lights should be warm and dim to avoid disturbing your internal clock.",
        "If your phone glows at night, flip it screen-down or enable do-not-disturb.",
        "Keep brightness low when checking the time during the night to avoid waking up.",
        "Ensure your room is dark enough that you can’t see your hand clearly in front of you.",
        "Sudden noises during the night can interrupt deep sleep — aim for a steady background sound.",
        "If outside noise wakes you up, try white noise or a fan to mask interruptions.",
        "Use soft earplugs if your bedroom is near traffic or other night activity.",
        "Avoid sleeping with loud music or TV — inconsistent noise reduces sleep depth.",
        "If your partner snores, side-sleeping or humidifying the room can help reduce sound.",
        "Close windows at night if outside noise easily enters your room.",
        "Soft, continuous background noise is less disruptive than silence with random spikes.",
        "Check for devices with buzzing or ticking sounds and move them away from your bed.",
        "Thick curtains or soft furnishings can help reduce echo and nighttime noise.",
        "If pets make noise at night, consider adjusting their sleeping space."
    ]
    @State private var message: String = ""
    @State private var showSheet: Bool = false
    @State private var messageIndex: Int = 0
    var body: some View {
        Button {
            showSheet = true
        }label: {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 10) {
                    Image(systemName: "lightbulb.max.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(.yellow)
                    Text(title)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
                
                Text(message)
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.leading, 2)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Spacer()
                    Text("Learn More")
                        .foregroundStyle(.white)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 16)
                        .background(
                            Capsule()
                                .fill(.white.opacity(0.15))
                        )
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.yellow.opacity(0.2))
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 24))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(.white.opacity(0.15), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.4), radius: 12, y: 6)
            .padding(.horizontal, 20)
        }
//        .glassEffect(in: RoundedRectangle(cornerRadius: 24))
        .onAppear {
            message = tip.randomElement()!
            messageIndex = tip.firstIndex(of: message)!
        }
        .sheet(isPresented: $showSheet) {
            LearnMoreView(tips: $tip, index: $messageIndex)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    TipsView()
}
