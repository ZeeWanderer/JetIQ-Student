//
//  LoginView.swift
//  JetIQ-Student
//
//  Created by max on 12/2/19.
//  Copyright © 2019 EvilSquad. All rights reserved.
//

import SwiftUI
import SystemConfiguration
import Combine

struct LoginView: View
{
    @EnvironmentObject var userData:UserData
    
    @Environment(\.colorScheme) var colorScheme
    
    //@ObservedObject private var keyboard = KeyboardResponder()
    @AppStorage("isLoggedIn") var isLoggedIn:Bool = false
    
    @State var password:String = ""
    
    @State var username:String = ""
    
    let reachability = SCNetworkReachabilityCreateWithName(nil,"https://connectivitycheck.gstatic.com/generate_204")
    
    @ObservedObject var viewModel = LoginViewModel()
    
    var login_bttn_color:Color
    {
        get
        {
            if viewModel.performingLogin
            {
                return Color.gray
            }
            else
            {
                return Color.green
            }
        }
    }
    
    var body: some View
    {
        VStack
        {
            if (colorScheme == ColorScheme.dark)
            {
                Image("JetIQ")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .colorInvert()
            }
            else
            {
                Image("JetIQ")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            
            Text("JetIQ-Student")
                .font(.largeTitle)
            
            if(!viewModel.login_error_message.isEmpty)
            {
                Text(viewModel.login_error_message)
                    .foregroundColor(Color.red)
            }
            
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .padding(.leading, 5)
                .padding(.trailing, 5)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 15)
                .padding(.leading, 5)
                .padding(.trailing, 5)
            
            Button(action: {self.performLogin()})
            {
                Text(viewModel.performingLogin ? "LOGGING IN..." : "LOGIN")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 220, height: 60)
                    .background(login_bttn_color)
                    .cornerRadius(15.0)
                    .padding(.bottom)
                
            }.disabled(viewModel.performingLogin)
        }.animation(.easeInOut(duration: 0.5))
    }
    
    func performLogin()
    {
        username = username.trimmingCharacters(in: .whitespacesAndNewlines)
        password = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        viewModel.getLogin(username, password, userData)
    }
}




struct LoginView_Previews: PreviewProvider
{
    static var previews: some View
    {
        
        Group
        {
            LoginView().environmentObject(UserData())
                .previewDevice("iPhone SE (2nd generation)")
                //.previewLayout(.device)
                .previewLayout(.fixed(width: 667, height: 375)) // iPhone SE landscape size
                .previewDisplayName("iPhone SE (2nd generation)")
                .environment(\.locale, Locale.init(identifier: "en"))
            
            LoginView().environmentObject(UserData())
                .previewDevice("iPhone SE")
                //.previewLayout(.device)
                .previewLayout(.fixed(width: 375, height: 667)) // iPhone SE landscape size
                .previewDisplayName("iPhone SE")
                .environment(\.locale, Locale.init(identifier: "en"))
            
            LoginView().environmentObject(UserData())
                .previewDevice("iPad Pro (12.9-inch) (4th generation)")
                .previewLayout(.fixed(width: 1366, height: 1024)) // iPad Pro (12.9-inch) landscape size
                .previewDisplayName("iPad Pro (12.9-inch)")
                .environment(\.locale, Locale.init(identifier: "en"))
            LoginView().environmentObject(UserData())
                
                .previewDevice("iPad Pro (12.9-inch) (4th generation)")
                .previewLayout(.fixed(width: 1024, height: 1366)) // iPad Pro (12.9-inch) landscape size
                .previewDisplayName("iPad Pro (12.9-inch)")
                .environment(\.locale, Locale.init(identifier: "en"))
        }
    }
}
