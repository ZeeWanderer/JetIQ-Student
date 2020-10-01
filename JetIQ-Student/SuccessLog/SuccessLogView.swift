//
//  SuccessLogView.swift
//  JetIQ-Student
//
//  Created by Maksym Kulyk on 10/1/20.
//  Copyright © 2020 EvilSquad. All rights reserved.
//

import SwiftUI
import SwiftUIPullToRefresh

class SuccessLogModel: ObservableObject {
    @Published var success_log: APIJsons.SuccessLog? = nil
    
    @Published var isLoading = false
    
    var isAvailable:Bool
    {
        get
        {
            return success_log != nil
        }
    }
    
    func fetch(_ userData: UserData)
    {
        isLoading = true
        let url:URL? = URL(string: "https://iq.vntu.edu.ua/b04213/curriculum/api.php?action=journ_list")!
        
        let dataTask = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            guard let data = data else
            {
                DispatchQueue.main.async
                {
                    self.isLoading = false
                }
                return
            }
            let jsonString = String(data: data, encoding: .utf8)
            let jsonData = jsonString!.data(using: .utf8)
            
            do
            {
                let json = try JSONSerialization.jsonObject(with: jsonData!, options: []) as! [String: AnyObject]
                let Schedule_ = APIJsons.SuccessLog(json)
                
                DispatchQueue.main.async
                {
                    self.success_log = Schedule_
                    self.isLoading = false
                }
                
            }
            catch _
            {
                DispatchQueue.main.async
                {
                    self.isLoading = false
                }
                return
            }
            
            
        }
        //dataTask.resume()
        
        let dataTask_ = URLSession.shared.dataTask(with:URL(string: "\(Defaults.API_BASE)?login=\(userData.login!)&pwd=\(userData.password!)")!) {(data, response, error) in
            guard data != nil && error == nil else { return }
            //let jsonString = String(data: data!, encoding: .utf8)
            dataTask.resume()
        }
        dataTask_.resume()
    }
}

struct SL_SubjectView: View
{
    let subject: APIJsons.Subject
    
    var body: some View
    {
        HStack
        {
            Text(subject.subject)
            Spacer()
            VStack
            {
                if subject.isECTS
                {
                    Text(subject.scale)
                    Text("Оцінка").font(.footnote)
                }
                else
                {
                    Text(subject.scale)
                }
                
                
            }
        }
    }
}

struct SuccessLogView: View {
    @EnvironmentObject var userData:UserData
    @ObservedObject private var success_log_ = SuccessLogModel()
    var body: some View
    {
        VStack
        {
            if !success_log_.isAvailable
            {
                Text("Loading...")
                    .onAppear (perform: {
                        self.success_log_.fetch(userData)
                    })
            }
            else if success_log_.success_log!.semesters.isEmpty
            {
                Text("No Data")
            }
            else
            {
                List
                {
                    ForEach(success_log_.success_log!.semesters)
                    {
                        semester in
                        Section(header: Text("Семестер \(semester.semester_number)"))
                        {
                            ForEach(semester.subjects)
                            { subject in
                                NavigationLink(destination: SuccessLogDetailView(subject: subject))
                                {
                                    SL_SubjectView(subject: subject)
                                }
                                
                            }
                        }
                    }
                }.navigationBarTitle(Text("Success Log"), displayMode: .inline)
                .listStyle(PlainListStyle())
                .navigationViewStyle(StackNavigationViewStyle())
                .background(SwiftUIPullToRefresh(action: {
                    self.success_log_.fetch(userData)
                }, isShowing: self.$success_log_.isLoading))
            }
        }
    }
}

struct SuccessLogView_Previews: PreviewProvider {
    static var previews: some View {
        SuccessLogView()
    }
}
