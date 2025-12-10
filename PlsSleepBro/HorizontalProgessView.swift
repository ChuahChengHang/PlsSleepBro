//
//  HorizontalProgessView.swift
//  PlsSleepBro
//
//  Created by T Krobot on 8/12/25.
//

import SwiftUI

struct HorizontalProgessView: View {
    
    @Binding var progress: CGFloat
    
    var colors: [Color] = [Color.darkRed, Color.lightRed]
    
    var body: some View {
        ZStack() {
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.outlineRed, lineWidth: 5)

            GeometryReader { proxy in
                let width = max(0, min(progress, 1)) * proxy.size.width
                
                let height = max(1, proxy.size.height)

                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            colors: colors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: width, height: height)
                    .animation(.easeOut(duration: 1.2), value: progress)
            }
        }
        .frame(idealWidth: 200, idealHeight: 50)
    }
}

#Preview {
    HorizontalProgessView(progress: .constant(0.0))
}
