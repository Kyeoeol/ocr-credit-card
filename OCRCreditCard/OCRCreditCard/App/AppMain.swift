//
//  AppMain.swift
//  OCRCreditCard
//
//  Created by kyeoeol on 2023/04/29.
//

import UIKit
import SwiftUI

@main
struct AppMain {
    static func main() {
        if #available(iOS 14.0, *) { OCRCreditCardApp.main() }
        else { ApplicationMain.main() }
    }
}




// SwiftUI
@available(iOS 14.0, *)
struct OCRCreditCardApp: App {
    var body: some Scene {
        WindowGroup {
            GeometryReader { proxy in
                ContentView()
                    .environment(\.windowSize, proxy.size)
            }
        }
    }
}

// AppDelegate
struct ApplicationMain {
    static func main() {
        UIApplicationMain(
            CommandLine.argc,
            CommandLine.unsafeArgv,
            nil,
            NSStringFromClass(AppDelegate.self)
        )
    }
}
