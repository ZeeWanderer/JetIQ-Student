//
//  LoginView.swift
//  JetIQ-Student
//
//  Created by max on 12/2/19.
//  Copyright © 2019 EvilSquad. All rights reserved.
//

import SwiftUI

struct LoginView: View
{
    @EnvironmentObject var userData:UserData
    @EnvironmentObject var archState:ArchState
    
    @Environment(\.colorScheme) var colorScheme
    
    //@ObservedObject private var keyboard = KeyboardResponder()
    
    @State var performingLogin:Bool = false
    
    @State var wrongCredentials:Bool = false
    
    @State var password:String = ""
    
    @State var username:String = ""
    
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
            
            if(self.wrongCredentials)
            {
                Text("Wrong login or password")
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
            
            // TODO:Block button
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
        //.padding(.bottom, keyboard.currentHeight)
        //.edgesIgnoringSafeArea(.bottom)
        //        .onTapGesture
        //        {
        //                if self.keyboard.currentHeight != 0
        //                { UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
        //                }
        //        }
        
        
    }
    
    func performLogin()
    {
        if username.isEmpty || password.isEmpty
        {
            return
        }
        
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
        self.performingLogin = true
        self.wrongCredentials = false
        URLSession.shared.dataTask(with: URL(string: "\(Defaults.API_BASE)?login=\(username)&pwd=\(password)")!) { [self] (data, _, error) in
            if let error = error
            {
                //self?.state = .fetched(.failure(.error(error.localizedDescription)))
                //let jsonString = String(data: data!, encoding: .utf8)
                DispatchQueue.main.async
                {
                    self.performingLogin = false
                }
                return
            }
            
            guard let data = data else
            {
                //self?.state = .fetched(.failure(.error("Malformed response data")))
                DispatchQueue.main.async
                {
                    self.performingLogin = false
                }
                return
            }
            let root = try! JSONDecoder().decode(APIJsons.LoginResponse.self, from: data)
            
            if root.id != nil && !(root.session?.starts(with: "wrong") ?? false)
            {
                
                DispatchQueue.main.async { [self] in
                    //self?.state = .fetched(.success(root))
                    self.userData.password = self.password
                    self.userData.login = self.username
                    
                    self.userData.group_id = root.gr_id
                    self.userData.f_id = root.f_id
                    self.userData.u_name = root.u_name
                    
                    saveUserData(userData: self.userData)
                    
                    self.wrongCredentials = false
                    self.performingLogin = false
                    withAnimation
                    {
                        self.archState.isLoggedIn = true
                    }
                }
            }
            else
            {
                // TODO: WRONG login or password
                DispatchQueue.main.async
                {
                    self.wrongCredentials = true
                    self.performingLogin = false
                }
                return
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
