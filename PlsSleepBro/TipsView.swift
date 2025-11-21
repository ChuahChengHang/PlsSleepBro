//
//  TipsView.swift
//  PlsSleepBro
//
//  Created by Chuah Cheng Hang on 21/11/25.
//

import SwiftUI

struct TipsView: View {
    @Binding var sleeptip: String
    @Binding var lighttip: String
    @Binding var noisetip: String
    var body: some View {
        RoundedRectangle(cornerRadius: 40)
            .fill(.secondary)
            .frame(width: 380, height: 160)
            .overlay(
                VStack {
                    HStack {
                        Text("Tip")
                            .font(.title2)
                            .bold()
                        Spacer()
                    }
                    Divider()
                        .overlay(.black)
                    Text("\(sleeptip)\n\(lighttip)\n\(noisetip)")
                    Spacer()
                }
                    .padding()
            )
    }
}

#Preview {
    TipsView(sleeptip: .constant(""), lighttip: .constant(""), noisetip: .constant(""))
}
