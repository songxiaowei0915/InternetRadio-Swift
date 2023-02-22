//
//  BufferingView.swift
//  SimpleInternetRadio
//
//  Created by 宋小伟 on 2023/2/22.
//

import SwiftUI

struct BufferingView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State var appear = false
    @State var fameWH: CGFloat = 50
    var isReverseColor: Bool = true

    var body: some View {
        Circle()
            .trim(from: 0.2, to: 1)
            .stroke(lineWidth: 1)
            .foregroundColor(getColor())
            .frame(width: fameWH, height: fameWH)
            .rotationEffect(Angle(degrees: appear ? 360 : 0))
            .animation(Animation.linear(duration:1).repeatForever(autoreverses: false), value: appear)
            .onAppear {
                appear = true
            }
    }
    
    func getColor() -> Color {
        if isReverseColor {
            return colorScheme == .light ? .black : .white
        }
        
        return colorScheme == .light ? .white : .black
    }
}

