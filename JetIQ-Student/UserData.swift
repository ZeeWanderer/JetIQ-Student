//
//  UserData.swift
//  JetIQ-Student
//
//  Created by max on 12/2/19.
//  Copyright © 2019 EvilSquad. All rights reserved.
//

import UIKit

class UserData: Codable, ObservableObject
{
    @Published var login:String? = nil
    @Published var password:String? = nil
    
    @Published var group_id:String? = nil
    @Published var f_id:String? = nil
    
    @Published var subgroup:String? = nil
    @Published var u_name:String? = nil
    
    enum CodingKeys: String, CodingKey {
        case login
        case password
        case group_id
        case f_id
        case subgroup
        case u_name
    }
    
    init(){}
    
    init(subgroup:String)
    {
        self.subgroup = subgroup
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        login = try values.decode(String?.self, forKey: .login)
        password = try values.decode(String?.self, forKey: .password)
        group_id = try values.decode(String?.self, forKey: .group_id)
        f_id = try values.decode(String?.self, forKey: .f_id)
        subgroup = try values.decode(String?.self, forKey: .subgroup) ?? nil
        u_name = try values.decode(String?.self, forKey: .u_name) ?? nil
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(login, forKey: .login)
        try container.encode(password, forKey: .password)
        try container.encode(group_id, forKey: .group_id)
        try container.encode(f_id, forKey: .f_id)
        try container.encode(subgroup, forKey: .subgroup)
        try container.encode(u_name, forKey: .u_name)
    }
    func clearUserData(){
        UserDefaults.standard.removeObject(forKey: "UserData")
        self.f_id = nil
        self.group_id = nil
        self.login = nil
        self.password = nil
        self.subgroup = nil
        self.u_name = nil
    }
}

func saveUserData(userData:UserData)
{
    let encoder = JSONEncoder()
    if let encoded = try? encoder.encode(userData) {
        let defaults = UserDefaults.standard
        defaults.set(encoded, forKey: "UserData")
    }
    
}

func clearUserData(){
    UserDefaults.standard.removeObject(forKey: "UserData")
}

func loadUserData()->UserData
{
    if let savedUserData = UserDefaults.standard.object(forKey: "UserData") as? Data {
        let decoder = JSONDecoder()
        if let loadedUserData = try? decoder.decode(UserData.self, from: savedUserData)
        {
            return loadedUserData
        }
    }
    return UserData()
}
