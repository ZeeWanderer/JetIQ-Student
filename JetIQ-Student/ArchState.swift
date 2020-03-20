//
//  ArchState.swift
//  JetIQ-Student
//
//  Created by max on 12/2/19.
//  Copyright © 2019 EvilSquad. All rights reserved.
//

import UIKit

class ArchState: ObservableObject{
    
    @Published var isLoggedIn = false
    
    init(login: Bool)
    {
        isLoggedIn = login
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

