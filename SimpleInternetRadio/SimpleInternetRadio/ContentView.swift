//
//  ContentView.swift
//  SimpleInternetRadio
//
//  Created by 宋小伟 on 2023/2/14.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        GeometryReader { geometry in
            TabView {
                MainView()
                    .frame(width: geometry.size.width)
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                    .tag(1)
                
                FavoriteView()
                    .frame(width: geometry.size.width)
                    .tabItem {
                        Label("Favorite", systemImage: "star")
                    }
                    .tag(2)
            }
            .frame(width: geometry.size.width)
        }
    }
}

extension View {
    @ViewBuilder func isHidden(_ isHidden: Bool) -> some View {
        if isHidden {
            self.hidden()
        } else {
            self
        }
    }
}

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear.preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }).onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
