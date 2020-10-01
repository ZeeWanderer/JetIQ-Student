//
//  LessonView.swift
//  JetIQ-Student
//
//  Created by Maksym Kulyk on 9/30/20.
//  Copyright © 2020 EvilSquad. All rights reserved.
//

import SwiftUI

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
                        Text(lesson.GetLessonTime()).multilineTextAlignment(.trailing)
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
        }.listRowBackground(lesson.GetLessonColor(colorScheme: colorScheme))
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
