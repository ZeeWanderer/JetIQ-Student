//
//  SuccessLogDetailView.swift
//  JetIQ-Student
//
//  Created by Maksym Kulyk on 10/1/20.
//  Copyright © 2020 EvilSquad. All rights reserved.
//

import SwiftUI
import SwiftUIPullToRefresh

class SuccessLogDetailModel: ObservableObject {
    @Published var success_log: APIJsons.SL_detailItem? = nil
    
    @Published var isLoading = false
    
    var isAvailable:Bool
    {
        get
        {
            return success_log != nil
        }
    }
    
    func fetch(_ userData: UserData, _ subject: APIJsons.Subject)
    {
        isLoading = true
        let url:URL? = URL(string: "https://iq.vntu.edu.ua/b04213/curriculum/api.php?action=journ_view&card_id=\(subject.card_id)")!
        
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
                let Schedule_ = APIJsons.SL_detailItem(json)
                
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

struct SuccessLogDetailModuleSectionView: View
{
    let module: APIJsons.SL_module
    let title: String
    var body: some View
    {
        Section(header: Text(title))
        {
            ForEach(module.categories)
            {
                category in
                
                HStack
                {
                    Text(category.legeng)
                    Spacer()
                    Text(category.points)
                }
            }
            HStack
            {
                Text("Годин пропущено:")
                Spacer()
                Text(String(module.h_pres))
            }
            HStack
            {
                Text("Оцінка за присутність:")
                Spacer()
                Text(String(module.for_pres))
            }
            HStack
            {
                Text("Оцінка:")
                Spacer()
                Text(String(module.mark))
            }
            HStack
            {
                Text("Всього:")
                Spacer()
                Text(String(module.sum))
            }
            
        }
    }
}

struct SuccessLogDetailView: View {
    let subject: APIJsons.Subject
    @EnvironmentObject var userData:UserData
    @ObservedObject private var success_log_ = SuccessLogDetailModel()
    var body: some View
    {
        VStack
        {
            if !success_log_.isAvailable
            {
                ProgressView("loading")
                    .onAppear (perform: {
                        self.success_log_.fetch(userData, subject)
                    })
            }
            else
            {
                List
                {
                    if let m1 = success_log_.success_log!.module_1
                    {
                        SuccessLogDetailModuleSectionView(module: m1, title: "Модуль 1")
                    }
                    if let m2 = success_log_.success_log!.module_2
                    {
                        SuccessLogDetailModuleSectionView(module: m2, title: "Модуль 2")
                    }
                    if let detail_info = success_log_.success_log
                    {
                        Section(header: Text("Всього"))
                        {
                            HStack
                            {
                                Text("Всього:")
                                Spacer()
                                Text(String(detail_info.total))
                            }
                            HStack
                            {
                                Text("ECTS:")
                                Spacer()
                                Text(!detail_info.ects.isEmpty ? detail_info.ects : "None" )
                            }
                            HStack
                            {
                                Text("Всього за минулий семестр:")
                                Spacer()
                                Text(String(detail_info.total_prev))
                            }
                        }
                    }
                }.navigationBarTitle(Text("Subject"), displayMode: .inline)
                .listStyle(GroupedListStyle())
                .navigationViewStyle(StackNavigationViewStyle())
                .background(SwiftUIPullToRefresh(action: {
                    self.success_log_.fetch(userData, subject)
                }, isShowing: self.$success_log_.isLoading))
            }
        }
    }
}

//struct SuccessLogDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        SuccessLogDetailView()
//    }
//}
