//
//  ArchState.swift
//  JetIQ-Student
//
//  Created by max on 12/2/19.
//  Copyright © 2019 EvilSquad. All rights reserved.
//

import SwiftUI

class ArchState: ObservableObject{
    
    @Published var isLoggedIn = false
    
    init(login: Bool)
    {
        isLoggedIn = login
    }
}

