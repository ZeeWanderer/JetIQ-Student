//
//  JetIQStudentApp.swift
//  Ropes
//
//  Created by Maksym Kulyk on 7/15/20.
//  Copyright © 2020 Maksym Kulyk. All rights reserved.
//

import SwiftUI

// overrides default print function in release build
#if !DEBUG
public func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
}
#endif

@main
struct JetIQStudentApp: App {
    let userData : UserData
    let archState : ArchState
    
    init() {
        
        URLSession.shared.configuration.httpCookieAcceptPolicy = .always
        URLSession.shared.configuration.httpShouldSetCookies = true
        URLSession.shared.configuration.waitsForConnectivity = true
        
        userData = loadUserData()
        archState = ArchState(login: userData.password != nil)
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userData)
                .environmentObject(archState)
        }
    }
}
