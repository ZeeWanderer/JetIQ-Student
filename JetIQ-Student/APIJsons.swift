//
//  APIJsons.swift
//  JetIQ-Student
//
//  Created by max on 12/2/19.
//  Copyright © 2019 EvilSquad. All rights reserved.
//

import SwiftUI


class APIJsons {
    
    // MARK: - LOGIN
    
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
    
    // MARK: - SUCCESS_LOG
    
    class SuccessLog
    {
        var numSections:Int {return semesters.count}
        var semesters:[Semester] = []
        init(_ json:[String:AnyObject])
        {
            // TODO: This is Unoptimal. FIX.
            var SubjKeys = Array(json.keys).sorted{$0.compare($1, options: .numeric) == .orderedDescending}
            var SemSet:Set<String> = []
            
            for SubjKey in SubjKeys
            {
                if let subj = json[SubjKey] as? [String:AnyObject] // TODO: investigate
                {
                    SemSet.insert(subj["sem"] as! String)
                }
            }
            
            let SemKeys = SemSet.sorted{$0.compare($1, options: .numeric) == .orderedDescending}
            
            for SemKey in SemKeys
            {
                semesters.append(Semester(json,semKey: SemKey, subjKeys: &SubjKeys))
            }
        }
    }
    class Semester: Codable, Identifiable
    {
        var id = UUID()
        
        var numRows:Int {return subjects.count}
        let semester_number:String
        var subjects:[Subject] = []
        init(_ json:[String:AnyObject], semKey:String, subjKeys: inout [String]) {
            self.semester_number = semKey
            var endDeleteidx = -1
            for subjKey in subjKeys
            {
                let subject = json[subjKey] as! [String:AnyObject]
                if ((subject["sem"] as! String) == self.semester_number)
                {
                    endDeleteidx = endDeleteidx + 1
                    subjects.append(Subject(subject))
                }
                else
                {
                    break
                }
            }
            
            subjKeys.removeSubrange(0...endDeleteidx)
        }
    }
    class Subject: Codable, Identifiable
    {
        var id = UUID()
        
        let card_id:String
        let subject:String
        let t_name:String
        let scale:String
        init(_ json:[String:AnyObject])
        {
            self.card_id = json["card_id"] as! String
            self.subject = json["subject"] as! String
            self.t_name = json["t_name"] as! String
            let scale_tmp = json["scale"] as! String
            switch scale_tmp
            {
            case "0":
                self.scale = "ECTS"
            default:
                self.scale = scale_tmp
            }
        }
        
        var isECTS: Bool
        {
            return self.scale == "ECTS"
        }
    }
    
    // MARK: SUCCESS_LOG_detail
    class SL_detailItem
    {
        
        let total:String
        let total_prev:String
        let ects:String
        let module_1:SL_module?
        let module_2:SL_module?
        init(_ json:[String:AnyObject])
        {
            self.total = (json["total"] as? NSNumber)?.stringValue ?? ""
            self.total_prev = (json["total_prev"] as? NSNumber)?.stringValue ?? ""
            self.ects = json["ects"] as? String ?? ""
            
            var keys = Array(json.keys).sorted{$0.compare($1, options: .numeric) == .orderedDescending}
            
            if(keys.allSatisfy{$0.count > 3})
            {
                module_1 = nil
                module_2 = nil
            }
            else
            {
                keys.removeAll{$0.count > 3}
                module_1 = SL_module(json, m_key:"1", keys:keys)
                module_2 = SL_module(json, m_key:"2", keys:keys)
            }
        }
    }
    
    class SL_module: Codable, Identifiable
    {
        var id = UUID()
        
        var categories:[SL_category] = []
        let sum:Int
        let mark:Int
        let h_pres:Int
        let for_pres:Int
        init(_ json:[String:AnyObject], m_key:String, keys:[String])
        {
            self.sum = json["sum\(m_key)"] as! Int
            self.mark = json["mark\(m_key)"] as! Int
            self.h_pres = json["h_pres\(m_key)"] as! Int
            self.for_pres = json["for_pres\(m_key)"] as! Int
            
            for key in keys
            {
                let category = json[key] as! [String:AnyObject]
                if ((category["num_mod"] as! String) == m_key)
                {
                    self.categories.append(SL_category(category))
                }
            }
        }
    }
    
    class SL_category: Codable, Identifiable
    {
        var id = UUID()
        
        let legeng:String
        let points:String
        init(_ json:[String:AnyObject])
        {
            self.legeng = json["legend"] as? String ?? "" // TODO: investigate
            self.points = (json["points"] as? NSNumber )?.stringValue ?? "" // TODO: investigate
        }
    }
    
    // MARK: - SCHEDULE
    
    class Schedule
    {
        var sectionNumber: Int {return days.count }
        var days:[Day] = []
        //let user_data: UserData
        init(json:[String:AnyObject], user_data: UserData)
        {
            //self.user_data = user_data
            let date = Date()
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy'T'HH:mm"
            formatter.locale = Locale.current
            formatter.calendar = Calendar.current
            formatter.timeZone = TimeZone.autoupdatingCurrent
            
            let calendar = Calendar.current
            
            let year = ".\(calendar.component(.year, from: date))T18:45"
            
            guard let sched = (json["sched"] as? [String:AnyObject])
            else {return}
            
            let dayKeys = Array(sched.keys).sorted{$0.compare($1, options: .numeric) == .orderedAscending}
            
            for dayKey in dayKeys
            {
                let day = sched[dayKey] as! [String:AnyObject]
                
                if !day.keys.contains("date") // TODO: investigate
                {
                    continue
                }
                
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
        var id = UUID()
        
        let idx:Int
        let date:String
        let dow:String
        let week_num:Int
        let weeks_shift:Int
        var Lessons:[Lesson] = []
        
        init(day:[String:AnyObject], idx:Int, user_data: UserData)
        {
            self.idx = idx
            self.date = (day["date"] as! String)
            self.dow = (day["dow"] as! String)
            self.week_num = (day["week_num"] as! Int)
            self.weeks_shift = (day["weeks_shift"] as! Int)
            
            var lessonKeys = Array((day).keys)
            lessonKeys.removeAll(where: {$0.count > 2})
            lessonKeys.sort{$0.compare($1, options: .numeric) == .orderedAscending}
            
            for lessonKey in lessonKeys // Window Detection
            {
                if let lesson = (day[lessonKey] as? [String:AnyObject]), lesson.keys.contains("") || lesson.keys.contains(user_data.subgroup!)
                {
                    break
                }
                else
                {
                    lessonKeys.removeFirst()
                }
            }
            
            //lessonKeys = lessonKeys.reversed()
            
            for lessonKey in lessonKeys.reversed() // Window Detection
            {
                if let lesson = (day[lessonKey] as? [String:AnyObject]), lesson.keys.contains("") || lesson.keys.contains(user_data.subgroup!)
                {
                    break
                }
                else
                {
                    lessonKeys.removeLast()
                }
            }
            
            if lessonKeys.isEmpty
            {
                return
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
        }
    }
    
    struct Lesson : Codable, Identifiable
    {
        var id = UUID()
        
        let Auditory:String
        let SbType:String
        let Subject:String
        let Number:Int
        let Comment:String
        let AddInfo:String
        let Teacher:String
        let isWindow:Bool
        let isSession:Bool
        
        let start_time:String
        let end_time:String
        
        let link:String
        
        init(lesson:[String:AnyObject]?)
        {
            
            self.Auditory = lesson!["aud"] as! String
            self.SbType = lesson!["type"] as! String
            self.Subject = lesson!["subject"] as! String
            self.Number = lesson!["num_lesson"] as! Int
            self.Comment = lesson!["comment"] as! String
            self.AddInfo = lesson!["add_info"] as! String
            self.Teacher = lesson!["t_name"] as! String
            
            
            let _link = lesson!["meet_url"] as? String ?? ""
            self.link = _link
            
            let l_beg_str = lesson!["l_beg"] as! String
            let l_end_str = lesson!["l_end"] as! String
            
            self.start_time = l_beg_str.split(separator: ",")[0..<2].joined(separator: ":")
            self.end_time = l_end_str.split(separator: ",")[0..<2].joined(separator: ":")
            
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
            self.start_time = ""
            self.end_time = ""
            self.link = ""
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
            var id = UUID()
            
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
                var id = UUID()
                
                let subj_name:String
                let form:String
                let hours:String
                let credits:String
                let total:String
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
                    let _total = json["total"] as! NSNumber
                    
                    ects = json["ects"] as! String
                    
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
                    
                    let formatter = NumberFormatter()
                    formatter.minimumFractionDigits = 0
                    formatter.maximumFractionDigits = 2
                    formatter.numberStyle = .decimal
                    formatter.decimalSeparator = "."
                    
                    total = formatter.string(from: _total) ?? String(_total as! Double)
                }
            }
        }
    }
}
