//
//  ScheduleView.swift
//  JetIQ-Student
//
//  Created by max on 12/2/19.
//  Copyright © 2019 EvilSquad. All rights reserved.
//

import SwiftUI

class ScheduleModel: ObservableObject {
    @Published var schedule: APIJsons.Schedule? = nil
    
    var isAvailable:Bool
    {
        get
        {
            return schedule != nil
        }
    }
    
    func fetchShedule(_ userData:UserData)
    {
        let url:URL? = URL(string: "https://iq.vntu.edu.ua/b04213/curriculum/api.php?view=g&group_id=\(userData.group_id!)&f_id=\(userData.f_id!)")!

        let dataTask:URLSessionDataTask? = URLSession.shared.dataTask(with: url!) {(data, response, error) in
                        guard let data = data else
                        {
                            //self.ScheduleTableViewController?.StopRefreshAnimation()
                            return
                        }
                        let jsonString = String(data: data, encoding: .utf8)
                        let jsonData = jsonString!.data(using: .utf8)

                        do
                        {
                            let json = try JSONSerialization.jsonObject(with: jsonData!, options: []) as! [String: AnyObject]
                            let Schedule_ = APIJsons.Schedule(json:json, user_data: userData)
                            //self.SaveDayForWidget(Schedule_)
                                DispatchQueue.main.async
                                {
                                        self.schedule = Schedule_
                                }

                        }
        //                catch is DecodingError
        //                {
        //                    // TODO:
        //                    return
        //                }
                        catch _
                        {
                            //self.TabBarController?.PresenExceptionAlert(title: "Error", message: "Something is wrong with the API server.\nWait and refresh.", animated: true)
                            // TODO:
        //                    #if DEBUG
        //                    print(error)
        //                    #endif
                            return
                        }


                    }
                    dataTask?.resume()
    }
}

struct LessonView :View
{
    let lesson: APIJsons.Lesson
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View
    {
        
        HStack
        {
            if (!lesson.isWindow)
            {
                ZStack
                {
                    Image("first")
                    Text("\(lesson.Number)").foregroundColor(Color.white)
                }
                Text(lesson.SbType)
                Text(lesson.Subject)
            
                Spacer()
                
                VStack(alignment: .trailing)
                {
                    if lesson.AddInfo.isEmpty
                    {
                        Text(lesson.GetLessonTime()).multilineTextAlignment(.trailing)
                    }
                    else
                    {
                        Text(lesson.AddInfo)
                    }
                    
                    Text(lesson.Auditory).multilineTextAlignment(.trailing)
                }
                
            }
            else
            {
                ZStack
                {
                    Image("first")
                    Text("-").foregroundColor(Color.white)
                }
                Spacer()

                Text("Window")
                
            }
        }
            
        .listRowBackground(lesson.GetLessonColor(colorScheme: colorScheme))
    }
}

//
//struct ListHeader: View {
//    let name:String
//    var body: some View
//    {
//        Text(name).font(.headline).foregroundColor(Color.black).padding(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
//    }
//}

struct ScheduleView: View
{
    @EnvironmentObject var userData:UserData
    @ObservedObject private var schedule_ = ScheduleModel()
    
    var body: some View
    {
    VStack
        {
            if !schedule_.isAvailable
            {
                Text("Loading...")
                .onAppear (perform: {
                    //.schedule_.userData = self.userData
                        self.schedule_.fetchShedule(self.userData)
                })
            }
            else
            {
                List
                {
                    ForEach(schedule_.schedule!.days)
                    {
                    day in
                        Section(header: Text("\(day.dow) \(day.date) нд \(day.weeks_shift)(\(day.week_num))"))
                        {
                            ForEach(day.Lessons)
                            {
                            lesson in
                                LessonView(lesson: lesson)
                                    
                            }

                        }//.padding(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                        //.edgesIgnoringSafeArea(.leading)
                    }
                }.navigationBarTitle(Text("Schedule"), displayMode: .inline)
                //.environment(\.defaultMinListRowHeight, 1)
            }
        }
    }
}

struct ScheduleView_Previews: PreviewProvider
{
    static var previews: some View
    {
        ScheduleView().environmentObject(UserData())
    }
}
