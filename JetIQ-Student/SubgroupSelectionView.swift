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
    
    @State private var selectedStrength = ""
    
    var body: some View
    {
     VStack
        {
            Text("Select Subgroup:")
            Picker(selection: $selectedStrength, label: Text(""))
            {
                Text("None")
                ForEach(1 ..< 6)
                {
                    Text(String($0))
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
            self.userData.subgroup = self.$selectedStrength.wrappedValue
            saveUserData(userData: self.userData)
        }
        
    }
}

struct SubgroupSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        SubgroupSelectionView().environmentObject(UserData())
    }
}
