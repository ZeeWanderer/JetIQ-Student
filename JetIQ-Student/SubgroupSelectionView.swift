//
//  SubgroupSelection.swift
//  JetIQ-Student
//
//  Created by max on 1/8/20.
//  Copyright © 2020 EvilSquad. All rights reserved.
//

import SwiftUI

struct SubgroupSelectionView: View
{
    @EnvironmentObject var userData:UserData
    
    @State private var selectedSubgroup = ""
    
    let subgroups = ["None", "1", "2", "3", "4", "5"]
    
    var body: some View
    {
        VStack
        {
            Text("Select Subgroup:")
            Picker(selection: $selectedSubgroup, label: Text(""))
            {
                ForEach(subgroups, id: \.self) { (string: String) in
                    Text(string)
                }
            }
            Button(action: {self.setSubgroup()})
            {
                Text("Select")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 220, height: 60)
                    .background(Color.green)
                    .cornerRadius(15.0)
                
            }
        }
    }
    func setSubgroup()
    {
        DispatchQueue.main.async { [self] in
            
            //self.userData.subgroup = self.selectedStrength
            self.userData.subgroup = self.selectedSubgroup
            saveUserData(userData: self.userData)
        }
        
    }
}

struct SubgroupSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        SubgroupSelectionView().environmentObject(UserData())
    }
}
