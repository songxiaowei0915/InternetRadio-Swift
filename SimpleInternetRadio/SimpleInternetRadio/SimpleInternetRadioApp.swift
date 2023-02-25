//
//  SimpleInternetRadioApp.swift
//  SimpleInternetRadio
//
//  Created by 宋小伟 on 2023/2/14.
//

import SwiftUI

@main
struct SimpleInternetRadioApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().environment(\.locale, .init(identifier: Locale.current.identifier))
        }
    }
}
