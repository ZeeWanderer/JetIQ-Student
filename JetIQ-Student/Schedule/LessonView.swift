//
//  LessonView.swift
//  JetIQ-Student
//
//  Created by Maksym Kulyk on 9/30/20.
//  Copyright © 2020 EvilSquad. All rights reserved.
//

import SwiftUI

struct LessonContextMenu: View
{
    let lesson: APIJsons.Lesson
    
    private func open_url(_ str: String)
    {
        if let url = URL(string: str)
        {
            UIApplication.shared.open(url)
        }
    }
    
    var body: some View
    {
        HStack
        {
            if !lesson.link.isEmpty
            {
                Button(action: {open_url(lesson.link)})
                {
                    Text("Open Online Link")
                }
            }
            else
            {
                Text("No Actions available.")
            }
        }
    }
}

struct LessonView :View
{
    let lesson: APIJsons.Lesson
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View
    {
        HStack(spacing: 0)
        {
            if (!lesson.isWindow)
            {

                RoundedRectangle(cornerRadius: 8).fill(lesson.link.isEmpty ? Color.clear : Color.green).frame(width: 5).padding(.vertical, 5)
                
                VStack
                {
                    ZStack
                    {
                        Image("first")
                        Text("\(lesson.Number)").foregroundColor(Color.white)
                    }.padding(.trailing, 7)
                    
                    Text(lesson.SbType).padding(.trailing, 7)
                }
                
                VStack
                {
                    Text(lesson.Subject).allowsTightening(true)
                        .multilineTextAlignment(.leading)
                    Text(lesson.Teacher).font(.footnote).lineLimit(1).scaledToFit()
                }
                
                Spacer()
                
                VStack(alignment: .trailing)
                {
                    if lesson.AddInfo.isEmpty
                    {
                        Text(lesson.start_time).multilineTextAlignment(.trailing)
                    }
                    else
                    {
                        Text(lesson.AddInfo)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    if !lesson.Auditory.isEmpty
                    {
                        Text(lesson.Auditory).multilineTextAlignment(.trailing)
                    }
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
        }.padding(.trailing, 10).padding(.vertical, 2)
    }
}

struct LessonView_Previews: PreviewProvider {
    
    static var previews: some View {
        LessonView(lesson:
                    {
                        let json :[String:AnyObject] = ["aud":"5113", "type":"ЛК", "subject":"Стандарти та проектування комп'ютерно інтегрованих систем", "num_lesson": 1,"comment":"", "add_info":"", "t_name":"Папіч"] as [String:AnyObject]
                        let lesson = APIJsons.Lesson(lesson: json)
                        
                        return lesson
                    }())
    }
}
