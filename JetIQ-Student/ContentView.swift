//
//  ContentView.swift
//  JetIQ-Student
//
//  Created by max on 12/2/19.
//  Copyright © 2019 EvilSquad. All rights reserved.
//

import SwiftUI

struct ContentView: View
{
    @EnvironmentObject var userData:UserData
    @EnvironmentObject var archState:ArchState
    
    @State private var selection = 0
    
    var body: some View
    {
        Group
        {
            if !archState.isLoggedIn
            {
                LoginView()
            }
            else if userData.subgroup == nil
            {
                SubgroupSelectionView()
            }
            else
            {
                TabView(selection: $selection)
                {
                    NavigationView
                    {
                        ScheduleView()
                    }
                    .tabItem
                    {
                        VStack
                        {
                            Image("schedule_tab").renderingMode(.template)
                            Text("Schedule")
                        }
                    }
                    .tag(0)
                    
                    NavigationView
                    {
                        MarkbookView()
                    }
                    .tabItem
                    {
                        VStack
                        {
                            Image("markbook_tab").renderingMode(.template)
                            Text("Markbook")
                        }
                    }
                    .tag(1)
                    
                    NavigationView
                    {
                        SettingsView(previousUserdata: userData, selectedSubgroup: userData.subgroup!)
                    }
                    .tabItem
                    {
                        VStack
                        {
                            Image("settings_tab").renderingMode(.template)
                            Text("Settings")
                        }
                    }
                    .tag(2)
                    
                }//.edgesIgnoringSafeArea(.top)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider
{
    static var previews: some View
    {
        ContentView().environmentObject(UserData(subgroup: "2")).environmentObject(ArchState(login: true))
    }
}
