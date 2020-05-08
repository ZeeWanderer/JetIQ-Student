//
//  APIJsons.swift
//  JetIQ-Student
//
//  Created by max on 12/2/19.
//  Copyright © 2019 EvilSquad. All rights reserved.
//

import UIKit
import SwiftUI


class APIJsons {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    class LoginResponse: Codable
    {
        var session:String? = nil
        var id:String? = nil
        var u_name:String? = nil
        var gr_id:String? = nil
        var gr_name:String? = nil
        var cource_num:Int? = nil
        
        var stud_id:Int? = nil
        var spec_id:String? = nil
        var f_id:String? = nil
        
    }
    
    // MARK: - SCHEDULE
    
    class Schedule
    {
        var sectionNumber: Int {return days.count }
        var days:[Day] = []
        let user_data: UserData
        init(json:[String:AnyObject], user_data: UserData)
        {
            self.user_data = user_data
            let date = Date()
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy'T'HH:mm"
            formatter.locale = Locale.current
            formatter.calendar = Calendar.current
            formatter.timeZone = TimeZone.autoupdatingCurrent

            let calendar = Calendar.current

            let year = ".\(calendar.component(.year, from: date))T18:45"
            
            let sched = (json["sched"] as! [String:AnyObject])
            
            let dayKeys = Array(sched.keys).sorted{$0.compare($1, options: .numeric) == .orderedAscending}
            
            for dayKey in dayKeys
            {
                let day = sched[dayKey] as! [String:AnyObject]
                let sect_date = formatter.date(from: (day["date"] as! String)+year)!
                
                if !(day.keys.allSatisfy{$0.count>2}) && sect_date >= date // TODO: use date-time of the end of the last lesson of the day
                {
                    self.days.append(Day(day: day, idx:Int(dayKey)!, user_data: user_data))
                    // TODO: not the best solution. Insert sorted?
    //                let newDay = Day(day: day.value as! [String : AnyObject], idx:Int(day.key)!)
    //                let index = days.index(where: { $0.idx > newDay.idx })
    //                self.days.insert(newDay, at: index ?? 0)
                    
                }
            }
            //self.days.sort(by: {$0.idx < $1.idx})
        }
        
        

    }
    class Day : Codable, Identifiable
    {
        let id = UUID()
        
        let idx:Int
        let date:String
        let dow:String
        let week_num:Int
        let weeks_shift:Int
        var Lessons:[Lesson] = []
        let user_data: UserData
        init(day:[String:AnyObject], idx:Int, user_data: UserData)
        {
            self.user_data = user_data
            self.idx = idx
            self.date = (day["date"] as! String)
            self.dow = (day["dow"] as! String)
            self.week_num = (day["week_num"] as! Int)
            self.weeks_shift = (day["weeks_shift"] as! Int)
            
            var lessonKeys = Array((day).keys)
            lessonKeys.removeAll(where: {$0.count > 2})
            lessonKeys.sort{$0.compare($1, options: .numeric) == .orderedDescending}
            //let min = Int(lessonKeys[lessonKeys.count-1])!
            for lessonKey in lessonKeys // Window Detection
            {
                if ((day[lessonKey] as! [String:AnyObject]).keys.contains("") || (day[lessonKey] as! [String:AnyObject]).keys.contains((user_data.subgroup)!) )
                {
                    break
                }
                else
                {
                    lessonKeys.removeFirst()
                }
            }
            
            lessonKeys = lessonKeys.reversed()
            
            for lessonKey in lessonKeys // Window Detection
            {
                if ((day[lessonKey] as! [String:AnyObject]).keys.contains("") || (day[lessonKey] as! [String:AnyObject]).keys.contains((user_data.subgroup)!) )
                {
                    break
                }
                else
                {
                    lessonKeys.removeFirst()
                }
            }
            
            
            //var bIsWindow = false
            var key:String = ""
            var PreviousKey:Int = Int(lessonKeys.first!)!
            for lessonKey in lessonKeys
            {
                if(Int(lessonKey)!-PreviousKey)>1
                {
                    for _ in 2...(Int(lessonKey)!-PreviousKey)
                    {
                        Lessons.append(Lesson())
                    }
                }
                PreviousKey = Int(lessonKey)!
                
                key = ""
                if !(day[lessonKey] as! [String:AnyObject]).keys.contains("")
                {
                    if (day[lessonKey] as![String:AnyObject]).keys.contains((user_data.subgroup)!)
                    {
                        key = (user_data.subgroup)!
                    }
                    else
                    {
                        Lessons.append(Lesson())
                        continue
                    }
                }
                Lessons.append(Lesson(lesson: ((day[lessonKey] as! [String:AnyObject])[key] as! [String : AnyObject])))
                
            }
            
            //Lessons.append(Lesson(leastLesson: min, rows: Intmax-min, idx: <#T##Int#>, isWindow: <#T##Bool#>))
        }
        
    }

    struct Lesson : Codable, Identifiable
    {
        let id = UUID()
        
        let Auditory:String
        let SbType:String
        let Subject:String
        let Number:Int
        let Comment:String
        let AddInfo:String
        let Teacher:String
        let isWindow:Bool
        let isSession:Bool
        init(lesson:[String:AnyObject]?)
        {
            
            self.Auditory = lesson!["aud"] as! String
            self.SbType = lesson!["type"] as! String
            self.Subject = lesson!["subject"] as! String
            self.Number = lesson!["num_lesson"] as! Int
            self.Comment = lesson!["comment"] as! String
            self.AddInfo = lesson!["add_info"] as! String
            self.Teacher = lesson!["t_name"] as! String
            self.isWindow = false
            self.isSession = !self.AddInfo.isEmpty
        }
        init()
        {
            
            // TODO fix this
            self.Auditory = ""
            self.SbType = ""
            self.Subject = ""
            self.Number = 0
            self.Comment = ""
            self.AddInfo = ""
            self.Teacher = ""
            self.isWindow = true
            self.isSession = false
            
        }
        
        func GetLessonColor(colorScheme:ColorScheme = .light)->Color
        {
            if(self.isWindow)
            {
                return Color.gray
            }
            else
            {
                if colorScheme == .light
                {
                    switch self.SbType
                    {
                    case "ЛК":
                        return Color(#colorLiteral(red: 1, green: 0.8869055742, blue: 0.5970449066, alpha: 1))
                    case "ПЗ":
                        return Color(#colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1))
                    case "ЛР":
                        return Color(#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1))
                    case "ДЗ":
                        return Color(#colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1))
                    case "Зал":
                        return Color(#colorLiteral(red: 1, green: 0.8472312441, blue: 0.4537079421, alpha: 1))
                    case "Конс":
                        return Color(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1))
                    case "Ісп":
                        return Color(#colorLiteral(red: 0.961265689, green: 0.2604754811, blue: 0.233939329, alpha: 1))
                    default:
                        return Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
                    }
                }
                else
                {
                    switch self.SbType
                    {
                    case "ЛК":
                        return Color(#colorLiteral(red: 0.4826300761, green: 0.4317500114, blue: 0.2918904648, alpha: 1))
                    case "ПЗ":
                        return Color(#colorLiteral(red: 0.396834647, green: 0.4902561156, blue: 0.3309897689, alpha: 1))
                    case "ЛР":
                        return Color(#colorLiteral(red: 0.2319329672, green: 0.4154234426, blue: 0.484382233, alpha: 1))
                    case "ДЗ":
                        return Color(#colorLiteral(red: 0.3440248997, green: 0.4834080708, blue: 0.2499767521, alpha: 1))
                    case "Зал":
                        return Color(#colorLiteral(red: 0.4924651015, green: 0.4193497898, blue: 0.2260875566, alpha: 1))
                    case "Конс":
                        return Color(#colorLiteral(red: 0.1162179505, green: 0.3397114481, blue: 0.4914304351, alpha: 1))
                    case "Ісп":
                        return Color(#colorLiteral(red: 0.4848310596, green: 0.1277867529, blue: 0.118707702, alpha: 1))
                    default:
                        return Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
                    }
                }
            }
        }
        
        func GetLessonTime() -> String
        {
            switch self.Number
            {
            case 1...6:
                return "\(8+self.Number-1):15"
            case 7,8:
                return "\(14+self.Number-7):45"
            case 9,10:
                return "16:40"
            case 11,12:
                return "18:10"
            case 13,14:
                return "19:40"
            default:
                return ""
            }
            
        }
    }
    
// MARK: - Markbook
    class Markbook
    {
        
        var Semesters:[Semester] = []
        
        init(json:[String:AnyObject])
        {
            var Keys = Array(json.keys)
            
            Keys.removeAll(where: {$0 == "result"})
            Keys.sort{$0.compare($1, options: .numeric) == .orderedDescending}
            
            for key in Keys
            {
                Semesters.append(Semester(json[key] as! [String:AnyObject], key))
            }
            
        }
        class Semester: Codable, Identifiable
        {
            let id = UUID()
            
            let number:String
            var Subjects:[Subject] = []
            init(_ json:[String:AnyObject],_ s_key:String)
            {
                number = s_key
                var Keys = Array(json.keys)
                Keys.sort{$0.compare($1, options: .numeric) == .orderedAscending}
                
                for key in Keys
                {
                    Subjects.append(Subject(json[key] as! [String:AnyObject]))
                }
                
            }
            
            class Subject: Codable, Identifiable
            {
                let id = UUID()
                
                let subj_name:String
                let form:String
                let hours:String
                let credits:String
                let total:Int
                let ects:String
                let mark:String
                let date:String
                let teacher:String
                
                init (_ json:[String:AnyObject])
                {
                    subj_name = json["subj_name"] as! String
                    form = json["form"] as! String
                    hours = json["hours"] as! String
                    credits = json["credits"] as! String
                    total = json["total"] as! Int
                    ects = json["ects"] as! String
                    //mark = json["mark"] as! String
                    let json_mark = json["mark"]// TODO: Correct usage of mark
                    switch json_mark
                    {
                    case is NSNumber:
                        mark = String(json_mark as! Int64)
                    default:
                        mark = json_mark as! String
                    }
                    date = json["date"] as! String
                    teacher = json["teacher"] as! String
                }
            }
            
        }
        
    }
    
    
}
