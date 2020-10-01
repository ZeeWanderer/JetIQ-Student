//
//  LocalStorage.swift
//  JetIQ-Student
//
//  Created by Maksym Kulyk on 10/1/20.
//  Copyright © 2020 EvilSquad. All rights reserved.
//

import SwiftUI

class LocalStorage: ObservableObject
{
    @Published var SL_detail_items: [String: APIJsons.SL_detailItem] = [:]
}
