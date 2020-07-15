//
//  SettingsView.swift
//  JetIQ-Student
//
//  Created by max on 3/24/20.
//  Copyright © 2020 EvilSquad. All rights reserved.
//

import SwiftUI

struct SettingsView: View
{
    let previousUserdata:UserData
    
    @State var selectedSubgroup:String = ""
    @EnvironmentObject var userData:UserData
    @EnvironmentObject var archState:ArchState
    
    let subgroups = ["None", "1", "2", "3", "4", "5"]
    
    var body: some View
    {
        List
        {
            Section(header: Text("User Settings"))
            {
                HStack
                {
                    Picker(selection: $selectedSubgroup, label: Text("Subgroups"))
                    {
                        ForEach(subgroups, id: \.self) { string in
                            Text(string)
                        }
                    }.pickerStyle(SegmentedPickerStyle())
                    
                }
            }
            Section(header: Text(""))
            {
                Button(action: {self.logOut()})
                {
                    HStack
                    {
                        Spacer()
                        Text("Logout").foregroundColor(Color.red)
                        Spacer()
                    }
                }
            }
        }
//        .onReceive(selectedSubgroup.publisher, perform:{rec in
//                print("rcieved \(rec)")
//            self.saveSettings()
//            }) // suboptimal - gets called 3 times in a row
        .navigationBarTitle(Text(userData.u_name ?? "user"), displayMode: .inline)
        .listStyle(GroupedListStyle())
        .onDisappear {
            print("onDissapear")
            self.saveSettings()
        }
        .onAppear{print("onAppear")}
        
            
    }
    nonmutating func saveSettings()
    {
        if archState.isLoggedIn
        {
            self.setSubgroup()
        }
    }
    func setSubgroup()
    {
        print("prev subgroup \(previousUserdata.subgroup ?? "-1")")
        print("curr subgroup \(self.selectedSubgroup)")
        if previousUserdata.subgroup != self.selectedSubgroup
        {
            print("saving new user data")
            //DispatchQueue.main.async { [self] in
            self.userData.subgroup = self.selectedSubgroup
            saveUserData(userData: self.userData)
            //}
        }
        
    }
    
    func logOut()
    {
        //DispatchQueue.main.async { [self] in
        self.userData.clearUserData()
        self.archState.isLoggedIn = false
        //}
        
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(previousUserdata: UserData())
    }
}
