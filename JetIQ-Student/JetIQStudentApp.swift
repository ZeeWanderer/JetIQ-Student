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
    
    @AppStorage("isLoggedIn") var isLoggedIn:Bool = false
    
    init()
    {
        URLSession.shared.configuration.httpCookieAcceptPolicy = .always
        URLSession.shared.configuration.httpShouldSetCookies = true
        URLSession.shared.configuration.waitsForConnectivity = true
        
        let userData_ = loadUserData()
        userData = userData_
        isLoggedIn = userData_.password != nil
    }
    var body: some Scene
    {
        WindowGroup
        {
            ContentView()
                .environmentObject(userData)
                .environmentObject(LocalStorage())
        }
    }
}
