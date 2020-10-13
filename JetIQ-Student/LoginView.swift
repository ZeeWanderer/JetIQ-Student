//
//  LoginView.swift
//  JetIQ-Student
//
//  Created by max on 12/2/19.
//  Copyright © 2019 EvilSquad. All rights reserved.
//

import SwiftUI
import SystemConfiguration

struct LoginView: View
{
    @EnvironmentObject var userData:UserData
    @EnvironmentObject var archState:ArchState
    
    @Environment(\.colorScheme) var colorScheme
    
    //@ObservedObject private var keyboard = KeyboardResponder()
    
    @State var performingLogin:Bool = false
    
    @State var b_error_on_login:Bool = false
    
    @State var password:String = ""
    
    @State var username:String = ""
    
    @State var login_error_message:String = ""
    
    let reachability = SCNetworkReachabilityCreateWithName(nil,"https://connectivitycheck.gstatic.com/generate_204")
    
    private let login_error_wrong_login = "Wrong login or password"
    private let login_error_empty_login = "Empty login or password"
    private let login_error_no_internet = "No internet connection"
    private let login_error_no_data = "API sent no data in response"
    private let login_error_recv_failed = "Revieve failed"
    private let login_error_json_parse_failed = "Session json parcing failed"
    private let login_error_unknown_error = "Unknown error"
    
    var login_bttn_color:Color
    {
        get
        {
            if performingLogin
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
            
            if(b_error_on_login)
            {
                Text(login_error_message)
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
                Text("LOGIN")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 220, height: 60)
                    .background(login_bttn_color)
                    .cornerRadius(15.0)
                    .padding(.bottom)
                
            }.disabled(performingLogin)
        }.animation(.easeInOut(duration: 0.5))
    }
    
    func performLogin()
    {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
        
        username = username.trimmingCharacters(in: .whitespacesAndNewlines)
        password = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if username.isEmpty || password.isEmpty
        {
            self.login_error_message = self.login_error_empty_login
            self.b_error_on_login = true
            return
        }
        
        self.performingLogin = true
        self.b_error_on_login = false
        
        URLSession.shared.dataTask(with: URL(string: "\(Defaults.API_BASE)?login=\(username)&pwd=\(password)")!) { [self] (data, _, error) in
            if let error = error
            {
                DispatchQueue.main.async
                {
                    print(error)
                    self.login_error_message = self.login_error_no_internet
                    self.b_error_on_login = true
                    self.performingLogin = false
                }
                return
            }
            
            guard let data = data else
            {
                DispatchQueue.main.async
                {
                    self.login_error_message = self.login_error_no_data
                    self.performingLogin = false
                }
                return
            }
            do
            {
                let root = try JSONDecoder().decode(APIJsons.LoginResponse.self, from: data)
                
                if root.id != nil && !(root.session?.starts(with: "wrong") ?? false)
                {
                    
                    DispatchQueue.main.async { [self] in
                        self.userData.password = self.password
                        self.userData.login = self.username
                        
                        self.userData.group_id = root.gr_id
                        self.userData.f_id = root.f_id
                        self.userData.u_name = root.u_name
                        
                        saveUserData(userData: self.userData)
                        
                        self.b_error_on_login = false
                        self.performingLogin = false
                        withAnimation
                        {
                            self.archState.isLoggedIn = true
                        }
                    }
                }
                else
                {
                    DispatchQueue.main.async
                    {
                        self.login_error_message = self.login_error_wrong_login
                        self.b_error_on_login = true
                        self.performingLogin = false
                    }
                    return
                }
            }
            catch _
            {
                DispatchQueue.main.async
                {
                    self.login_error_message = self.login_error_json_parse_failed
                    self.performingLogin = false
                }
            }
        }.resume()
    }
}




struct LoginView_Previews: PreviewProvider
{
    static var previews: some View
    {
        LoginView().environmentObject(UserData()).environmentObject(ArchState(login: false))
    }
}
