//
//  ScheduleView.swift
//  JetIQ-Student
//
//  Created by max on 12/2/19.
//  Copyright © 2019 EvilSquad. All rights reserved.
//

import SwiftUI
import SwiftUIPullToRefresh

//class ScheduleModel: ObservableObject {
//    @Published var schedule: APIJsons.Schedule? = nil
//
//    @Published var isLoading = false
//
//    var isAvailable:Bool
//    {
//        get
//        {
//            return schedule != nil
//        }
//    }
//
//    func fetchShedule(_ userData:UserData)
//    {
//        isLoading = true
//        let url:URL? = URL(string: "https://iq.vntu.edu.ua/b04213/curriculum/api.php?view=g&group_id=\(userData.group_id!)&f_id=\(userData.f_id!)")!
//
//        let dataTask:URLSessionDataTask? = URLSession.shared.dataTask(with: url!) {(data, response, error) in
//            guard let data = data else
//            {
//                DispatchQueue.main.async
//                {
//                    self.isLoading = false
//                }
//                return
//            }
//            let jsonString = String(data: data, encoding: .utf8)
//            let jsonData = jsonString!.data(using: .utf8)
//
//            do
//            {
//                let test = try JSONDecoder().decode(APIJsons.Test_Schedule.self, from: data)
//                let json = try JSONSerialization.jsonObject(with: jsonData!, options: []) as! [String: AnyObject]
//                let Schedule_ = APIJsons.Schedule(json:json, user_data: userData)
//
//                DispatchQueue.main.async
//                {
//                    self.schedule = Schedule_
//                    self.isLoading = false
//                }
//            }
//            catch _
//            {
//                DispatchQueue.main.async
//                {
//                    self.isLoading = false
//                }
//                return
//            }
//        }
//        dataTask?.resume()
//    }
//}


struct ScheduleView: View
{
    @EnvironmentObject var userData:UserData
    @ObservedObject private var schedule_ = ScheduleViewModel()
    @AppStorage("numberOfDaysScheduleShown") var schedule_days_count:String = "10"
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View
    {
        VStack
        {
            if schedule_.schedule_r == nil
            {
                if schedule_.fetch_error_message.isEmpty
                {
                    Text("Loading...")
                        .onAppear (perform: {
                            //.schedule_.userData = self.userData
                            self.schedule_.getSchedule(userData.group_id ?? "", userData.f_id ?? "")
                        })
                }
                else
                {
                    List
                    {
                        HStack
                        {
                            Spacer()
                            Text("\(schedule_.fetch_error_message)").foregroundColor(Color.red)
                                .multilineTextAlignment(.center)
                            Spacer()
                        }
                        if !schedule_.error_string.isEmpty
                        {
                            HStack
                            {
                                Spacer()
                                Text("\(schedule_.error_string)").foregroundColor(Color.red)
                                    .multilineTextAlignment(.center)
                                Spacer()
                            }
                        }
                        HStack
                        {
                            Spacer()
                            Text("Pull to refetch").foregroundColor(Color.red)
                                .multilineTextAlignment(.center)
                            Spacer()
                        }
                        
                    }.navigationBarTitle(Text("Schedule"), displayMode: .inline)
                    .background(SwiftUIPullToRefresh(action: {
                        self.schedule_.getSchedule(userData.group_id ?? "", userData.f_id ?? "")
                    }, isShowing: self.$schedule_.performingFetch))
                    
                }
            }
            else
            {
                List
                {
                    ForEach(schedule_.daysFiltered(userData.subgroup!, schedule_days_count))
                    { day in
                        Section(header: Text("\(day.dow) \(day.date) нд \(day.weeks_shift)(\(day.week_num))"))
                        {
                            ForEach(day.Lessons)
                            {
                                lesson in
                                LessonView(lesson: lesson)
                                    .contextMenu {
                                        LessonContextMenu(lesson: lesson)
                                    }
                                    .listRowBackground(lesson.GetLessonColor(colorScheme: colorScheme))
                            }
                        }.listRowInsets(EdgeInsets())
                    }//.drawingGroup()
                }.navigationBarTitle(Text("Schedule"), displayMode: .inline)
                .listStyle(PlainListStyle())
                .navigationViewStyle(StackNavigationViewStyle())
                .background(SwiftUIPullToRefresh(action: {
                    self.schedule_.getSchedule(userData.group_id ?? "", userData.f_id ?? "")
                }, isShowing: self.$schedule_.performingFetch))
                
                //                List
                //                {
                //                    ForEach(schedule_.schedule!.days)
                //                    {
                //                        day in
                //                        Section(header: Text("\(day.dow) \(day.date) нд \(day.weeks_shift)(\(day.week_num))"))
                //                        {
                //                            ForEach(day.Lessons)
                //                            {
                //                                lesson in
                //                                LessonView(lesson: lesson)
                //                                    .contextMenu {
                //                                        LessonContextMenu(lesson: lesson)
                //                                    }
                //                                    .listRowBackground(lesson.GetLessonColor(colorScheme: colorScheme))
                //                            }
                //                        }.listRowInsets(EdgeInsets())
                //                    }
                //                }.navigationBarTitle(Text("Schedule"), displayMode: .inline)
                //                .listStyle(PlainListStyle())
                //                .navigationViewStyle(StackNavigationViewStyle())
                //                .background(SwiftUIPullToRefresh(action: {
                //                    self.schedule_.getSchedule(userData.group_id ?? "", userData.f_id ?? "")
                //                }, isShowing: self.$schedule_.performingFetch))
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
