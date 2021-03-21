//
//  MarkbookView.swift
//  JetIQ-Student
//
//  Created by max on 12/2/19.
//  Copyright © 2019 EvilSquad. All rights reserved.
//

import SwiftUI
import SwiftUIPullToRefresh

class MarkbookModel: ObservableObject {
    @Published var markbook: APIJsons.Markbook? = nil
    
    @Published var isLoading = false
    
    var isAvailable:Bool
    {
        get
        {
            return markbook != nil
        }
    }
    //    let netSession_:URLSession
    //    init()
    //    {
    //                let configuration = URLSessionConfiguration.ephemeral
    //                       //configuration.timeoutIntervalForResource = 300
    //                       configuration.httpCookieAcceptPolicy = .always
    //                       configuration.httpShouldSetCookies = true
    //
    //                       configuration.waitsForConnectivity = true
    //
    //                netSession_ = URLSession(configuration: configuration)
    //    }
    
    func fetch(_ userData:UserData)
    {
        isLoading = true
        let url:URL? = URL(string: "https://iq.vntu.edu.ua/b04213/curriculum/api.php?markbook=1")!
        
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
                let Markbook_ = APIJsons.Markbook(json:json)
                //self.SaveDayForWidget(Schedule_)
                DispatchQueue.main.async
                {
                    self.markbook = Markbook_
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
        
        if let login = userData.login, let password = userData.password, !login.isEmpty && !password.isEmpty
        {
            
            let login_string = "\(Defaults.API_BASE)?login=\(login)&pwd=\(password)"
            
            let login_data_task = URLSession.shared.dataTask(with:URL(string:login_string)!)
            {(data, response, error) in
                guard data != nil && error == nil else
                {
                    DispatchQueue.main.async
                    {
                        self.isLoading = false
                    }
                    return
                }
                //let jsonString = String(data: data!, encoding: .utf8)
                dataTask.resume()
            }
            login_data_task.resume()
        }
    }
}

struct SubjectItemRow :View
{
    let name:String
    let value:String
    var body: some View
    {
        HStack
        {
            VStack(alignment: .leading)
            {
                Text(name)
            }
            Spacer()
            VStack(alignment: .trailing)
            {
                Text(value)//.multilineTextAlignment(.center)
            }
        }
    }
}

struct SubjectDetailView :View
{
    let subject: APIJsons.Markbook.Semester.Subject
    
    var body: some View
    {
        
        List
        {
            SubjectItemRow(name:"Форма:", value: subject.form)
            SubjectItemRow(name:"Бали:", value: subject.total)
            SubjectItemRow(name:"Оцінка:", value: subject.mark)
            SubjectItemRow(name:"ECTS:", value: subject.ects)
            SubjectItemRow(name:"Кредити:", value: subject.credits)
            SubjectItemRow(name:"Дата:", value: subject.date)
            SubjectItemRow(name:"Викладач:", value: subject.teacher)
        }.navigationBarTitle(Text(subject.subj_name), displayMode: .inline)
        .listStyle(GroupedListStyle())
        
    }
}

struct SubjectView : View
{
    let subject: APIJsons.Markbook.Semester.Subject
    
    var body: some View
    {
        NavigationLink(destination: SubjectDetailView(subject: subject))
        {
            HStack
            {
                VStack(alignment: .leading)
                {
                    Text(subject.subj_name)
                    Text(subject.form).font(.subheadline)
                }
                Spacer()
                VStack(alignment: .trailing)
                {
                    Text(subject.mark) //.multilineTextAlignment(.center)
                    Text("Оцінка").font(.subheadline) //.multilineTextAlignment(.center)
                }
            }
        }
        
    }
}

struct MarkbookView: View
{
    @EnvironmentObject var userData:UserData
    @ObservedObject private var markbook_ = MarkbookModel()
    
    var body: some View
    {
        VStack
        {
            if (!markbook_.isAvailable)
            {
                ProgressView("loading")
                    .onAppear (perform: {
                        self.markbook_.fetch(self.userData)
                    })
            }
            //            else if markbook_.markbook!.Semesters.isEmpty
            //            {
            //                Text("No Data")
            //                    .background(SwiftUIPullToRefresh(action: {
            //                        self.markbook_.fetch(userData)
            //                    }, isShowing: self.$markbook_.isLoading))
            //            }
            else
            {
                List
                {
                    ForEach(markbook_.markbook!.Semesters)
                    {
                        semester in
                        Section(header: Text("Семестр \(semester.number)"))
                        {
                            ForEach(semester.Subjects)
                            {
                                subject in
                                SubjectView(subject: subject)
                            }
                            
                        }.padding(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    }
                }.navigationBarTitle(Text("Markbook"), displayMode: .inline)
                .background(SwiftUIPullToRefresh(action: {
                    self.markbook_.fetch(userData)
                }, isShowing: self.$markbook_.isLoading))
                .overlay(markbook_.markbook!.Semesters.isEmpty ? Text("No Data\nPull to Reresh").multilineTextAlignment(.center) : nil)
            }
        }
    }
}

struct MarkbookView_Previews: PreviewProvider
{
    static var previews: some View
    {
        MarkbookView().environmentObject(UserData())
    }
}
