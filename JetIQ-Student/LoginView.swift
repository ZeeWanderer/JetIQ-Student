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
        
        //        URLSession.shared.dataTask(with: URL(string: "\(Defaults.API_BASE)?login=\(username)&pwd=\(password)")!) { [self] (data, _, error) in
        //            if let error = error
        //            {
        //                DispatchQueue.main.async
        //                {
        //                    print(error)
        //                    self.login_error_message = self.login_error_no_internet
        //                    self.b_error_on_login = true
        //                    self.performingLogin = false
        //                }
        //                return
        //            }
        //
        //            guard let data = data else
        //            {
        //                DispatchQueue.main.async
        //                {
        //                    self.login_error_message = self.login_error_no_data
        //                    self.b_error_on_login = true
        //                    self.performingLogin = false
        //                }
        //                return
        //            }
        //            do
        //            {
        //                let root = try JSONDecoder().decode(APIJsons.LoginResponse.self, from: data)
        //
        //                if root.id != nil && !root.session.starts(with: "wrong")
        //                {
        //
        //                    DispatchQueue.main.async { [self] in
        //                       self.userData.password = self.password
        //                        self.userData.login = self.username
        //
        //                        self.userData.group_id = root.gr_id
        //                        self.userData.f_id = root.f_id
        //                        self.userData.u_name = root.u_name
        //
        //                        saveUserData(userData: self.userData)
        //
        //                        self.b_error_on_login = false
        //                        self.performingLogin = false
        //                        withAnimation
        //                        {
        //                            self.archState.isLoggedIn = true
        //                        }
        //                    }
        //                }
        //                else
        //                {
        //                    DispatchQueue.main.async
        //                    {
        //                        self.login_error_message = self.login_error_wrong_login
        //                        self.b_error_on_login = true
        //                        self.performingLogin = false
        //                    }
        //                    return
        //                }
        //            }
        //            catch _
        //            {
        //                DispatchQueue.main.async
        //                {
        //                    self.login_error_message = self.login_error_json_parse_failed
        //                    self.b_error_on_login = true
        //                    self.performingLogin = false
        //                }
        //            }
        //        }.resume()
    }
}




struct LoginView_Previews: PreviewProvider
{
    static var previews: some View
    {
        LoginView().environmentObject(UserData())
    }
}
