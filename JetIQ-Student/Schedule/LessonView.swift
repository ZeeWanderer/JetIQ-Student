//
//  LessonView.swift
//  JetIQ-Student
//
//  Created by Maksym Kulyk on 9/30/20.
//  Copyright © 2020 EvilSquad. All rights reserved.
//

import SwiftUI

import MobileCoreServices
struct LessonContextMenu: View
{
    let lesson: APIJsons.Test_Lesson
    
    private func open_url(_ str: String)
    {
        if let url = URL(string: str)
        {
            UIApplication.shared.open(url)
        }
    }
    
    private func copy_url(_ str: String)
    {
        UIPasteboard.general.setValue(str, forPasteboardType: kUTTypeURL as String)
    }
    
    var body: some View
    {
        HStack
        {
            if let link = lesson.link
            {
                Button(action: {open_url(link)})
                {
                    Text("Open Link")
                }
                Button(action: {copy_url(link)})
                {
                    Text("Copy Link")
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
    let lesson: APIJsons.Test_Lesson
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View
    {
        HStack(spacing: 0)
        {
            //if (!lesson.isWindow)
            //{
            RoundedRectangle(cornerRadius: 8).fill(lesson.link == nil ? Color.clear : Color.green).frame(width: 5).padding(.vertical, 5)
            
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
            //}
            //            else
            //            {
            //                ZStack
            //                {
            //                    Image("first")
            //                    Text("-").foregroundColor(Color.white)
            //                }
            //                Spacer()
            //
            //                Text("Window")
            //
            //            }
        }.padding(.trailing, 10).padding(.vertical, 2)
    }
}

struct LessonView_Previews: PreviewProvider {
    // TODO: fix this preview
    static var previews: some View {
        //        LessonView(lesson:
        //                    {
        //                        let json :[String:AnyObject] = ["aud":"5113", "type":"ЛК", "subject":"Стандарти та проектування комп'ютерно інтегрованих систем", "num_lesson": 1,"comment":"", "add_info":"", "t_name":"Папіч"] as [String:AnyObject]
        //                        let lesson = APIJsons.Test_Lesson(lesson: json)
        //
        //                        return lesson
        //                    }())
        EmptyView()
    }
}
