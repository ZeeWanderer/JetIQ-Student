//
//  Networking.swift
//  JetIQ-Student
//
//  Created by Maksym Kulyk on 2/11/21.
//  Copyright © 2021 EvilSquad. All rights reserved.
//

import SwiftUI
import Combine

struct APIClient {
    
    struct Response<T> {
        let value: T
        let response: URLResponse
    }
    
    func run<T: Decodable>(_ request: URLRequest) -> AnyPublisher<Response<T>, Error> {
        let publisher = URLSession.shared
            .dataTaskPublisher(for: request)
            .mapError({ $0 as Error })
            .map ({ result -> AnyPublisher<Response<T>, Error> in
                do
                {
                    let value = try JSONDecoder().decode(T.self, from: result.data)
                    return Just(Response(value: value, response: result.response))
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                catch let error as DecodingError
                {
                    return Fail(error: error)
                        .eraseToAnyPublisher()
                }
                catch
                {
                    return Fail(error: error)
                        .eraseToAnyPublisher()
                }
                
            })
            .receive(on: DispatchQueue.main)
            .switchToLatest()
            .eraseToAnyPublisher()
        return publisher
    }
}

enum LoginService {
    static let apiClient = APIClient()
    static let baseUrl = URL(string: "https://iq.vntu.edu.ua/b04213/curriculum/api.php/")!
}

extension LoginService {
    
    static func request(_ login: String, _ password: String) -> AnyPublisher<APIJsons.LoginResponse, Error> {
        
        guard var components = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true)
        else { fatalError("Couldn't create URLComponents") }
        components.queryItems = [URLQueryItem(name: "login", value: login), URLQueryItem(name: "pwd", value: password)]
        
        let request = URLRequest(url: components.url!)
        
        print("url = \(components.url!)")
        
        return apiClient.run(request)
            .map(\.value)
            .eraseToAnyPublisher()
    }
}

class LoginViewModel: ObservableObject {
    @AppStorage("isLoggedIn") var isLoggedIn:Bool = false
    
    @Published var login_r: APIJsons.LoginResponse? = nil // 1
    var cancellationToken: AnyCancellable? = nil // 2
    
    @Published var performingLogin:Bool = false
    
    //@Published var b_error_on_login:Bool = false
    
    @Published var login_error_message:String = ""
    
    private let login_no_error = ""
    
    private let login_error_wrong_login = "Wrong login or password"
    private let login_error_empty_login = "Empty login or password"
    private let login_error_no_internet = "No internet connection"
    private let login_error_no_data = "API sent no data in response"
    private let login_error_recv_failed = "Revieve failed"
    private let login_error_json_parse_failed = "API retured null. Try again."
    private let login_error_unknown_error = "Unknown error"
}

extension LoginViewModel
{
    func validateResponce(_ r:APIJsons.LoginResponse) -> Bool
    {
        if r.id == nil || r.session.starts(with: "wrong")
        {
            self.login_error_message = self.login_error_wrong_login
            return false
        }
        else
        {
            return true
        }
    }
    
    func getLogin(_ login: String, _ password: String, _ userData: UserData? = nil)
    {
        login_error_message = login_no_error
        
        if login.isEmpty || password.isEmpty
        {
            self.login_error_message = self.login_error_empty_login
            self.performingLogin = false
            return
        }
        
        self.performingLogin = true
        
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
        
        let publisher = LoginService.request(login, password)
        cancellationToken = publisher.share()
            .tryCatch({error -> AnyPublisher<APIJsons.LoginResponse, Error> in
                if let derror = error as? DecodingError
                {
                    print(derror)
                    switch derror
                    {
                    case DecodingError.valueNotFound(let value, let context):
                        print(value)
                        print(context)
                        if context.codingPath.last!.stringValue == APIJsons.LoginResponse.CodingKeys.session.stringValue
                        {
                            return publisher
                        }
                        else
                        {
                            throw derror
                        }
                    default:
                        throw derror
                    }
                }
                else
                {
                    throw error
                }
            })
            .retry(2)
            .mapError({ (error) -> Error in
                print(error)
                if let urlError = error as? URLError
                {
                    switch urlError.code
                    {
                    case .notConnectedToInternet:
                        self.login_error_message = self.login_error_no_internet
                    case .dataNotAllowed:
                        self.login_error_message = self.login_error_no_internet
                    case .cannotDecodeRawData:
                        self.login_error_message = self.login_error_no_data
                    default:
                        self.login_error_message = self.login_error_unknown_error
                    }
                    
                    self.isLoggedIn = false
                    self.performingLogin = false
                    return urlError
                }
                else
                if let derror = error as? DecodingError
                {
                    self.login_error_message = self.login_error_json_parse_failed
                    
                    self.isLoggedIn = false
                    self.performingLogin = false
                    return derror
                }
                else
                {
                    self.login_error_message = self.login_error_unknown_error
                }
                self.isLoggedIn = false
                self.performingLogin = false
                return error
            })
            .sink(receiveCompletion: { _ in },
                  receiveValue: { val in
                    let isValid = self.validateResponce(val)
                    if isValid
                    {
                        self.login_error_message = self.login_no_error
                        self.isLoggedIn = true
                        self.login_r = val
                        userData?.update_from_login(val, login, password)
                    }
                    else
                    {
                        self.login_error_message = self.login_error_wrong_login
                        self.isLoggedIn = false
                    }
                    self.performingLogin = false
                  })
    }
    
}

// MARK: - Schedule

enum ScheduleService {
    static let apiClient = APIClient()
    static let baseUrl = URL(string: "https://iq.vntu.edu.ua/b04213/curriculum/api.php/")!
}

extension ScheduleService {
    
    static func request(_ group_id: String, _ f_id: String) -> AnyPublisher<APIJsons.Test_Schedule, Error> {
        
        guard var components = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true)
        else { fatalError("Couldn't create URLComponents") }
        components.queryItems = [URLQueryItem(name: "view", value: "g"), URLQueryItem(name: "group_id", value: group_id), URLQueryItem(name: "f_id", value: f_id)]
        
        let request = URLRequest(url: components.url!)
        
        print("url = \(components.url!)")
        
        return apiClient.run(request)
            .map(\.value)
            .eraseToAnyPublisher()
    }
}


class ScheduleViewModel: ObservableObject {
    @Published var schedule_r: APIJsons.Test_Schedule? = nil // 1
    var isAvailable:Bool {schedule_r != nil}
    private var cancellationToken: AnyCancellable? = nil // 2
    
    @Published var performingFetch:Bool = false
    
    //@Published var b_error_on_login:Bool = false
    
    @Published var fetch_error_message:String = ""
    @Published var error_string:String = ""
    
    private let login_no_error = ""
    
    private let login_error_wrong_login = "Wrong login or password"
    private let login_error_empty_login = "Empty login or password"
    private let login_error_no_internet = "No internet connection"
    private let login_error_no_data = "API sent no data in response"
    private let login_error_recv_failed = "Revieve failed"
    private let login_error_json_parse_failed = "API retured null. Try again."
    private let login_error_unknown_error = "Unknown error"
}

extension ScheduleViewModel
{
    func daysFiltered(_ subgroup: String, _ days_shown_str:String) ->[APIJsons.Test_Day.Test_DayDataFlat]
    {
        print("daysFiltered")
        //TODO: setting to limit number of schedule days shown
        //return Array(schedule_r!.days.compactMap{ APIJsons.Test_Day.Test_DayDataFlat($0, subgroup)}[0...7*3-1])
        let arr = schedule_r!.days.compactMap{ APIJsons.Test_Day.Test_DayDataFlat($0, subgroup)}
            .filter{
                guard let last_lesson = $0.Lessons.last
                else
                {
                    return false
                }
                
                let date_now = Date()
                
                let formatter = DateFormatter()
                formatter.dateFormat = "dd.MM.yyyy'T'HH:mm"
                formatter.locale = Locale.current
                formatter.calendar = Calendar.current
                formatter.timeZone = TimeZone.autoupdatingCurrent
                
                let calendar = Calendar.current
                
                let time = last_lesson.end_time
                
                let year = ".\(calendar.component(.year, from: date_now))T\(time)"
                
                let sect_date = formatter.date(from: $0.date + year)!
                
                return sect_date >= date_now
            }
        if days_shown_str != "All", let days_count = Int(days_shown_str)
        {
            return Array(arr[0...days_count-1])
        }
        else
        {
            return arr
        }
        
    }
    
    func validateResponce(_ r:APIJsons.Test_Schedule) -> Bool
    {
        if r.sectionNumber == 0
        {
            self.fetch_error_message = self.login_error_wrong_login
            return false
        }
        else
        {
            return true
        }
    }
    
    func getSchedule(_ group_id: String, _ f_id: String)
    {
        schedule_r = nil
        error_string = login_no_error
        fetch_error_message = login_no_error
        
        if group_id.isEmpty || f_id.isEmpty
        {
            self.fetch_error_message = self.login_error_empty_login
            self.performingFetch = false
            return
        }
        
        self.performingFetch = true
        
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
        
        let publisher = ScheduleService.request(group_id, f_id)
        cancellationToken = publisher.share()
            .tryCatch({error -> AnyPublisher<APIJsons.Test_Schedule, Error> in
                print(error)
                throw error
            })
            .retry(1)
            .mapError({ (error) -> Error in
                print(error)
                if let urlError = error as? URLError
                {
                    switch urlError.code
                    {
                    case .notConnectedToInternet:
                        self.fetch_error_message = self.login_error_no_internet
                    case .dataNotAllowed:
                        self.fetch_error_message = self.login_error_no_internet
                    case .cannotDecodeRawData:
                        self.fetch_error_message = self.login_error_no_data
                    default:
                        self.fetch_error_message = self.login_error_unknown_error
                    }
                    
                    self.performingFetch = false
                    return urlError
                }
                else
                if let derror = error as? DecodingError
                {
                    self.error_string = "JSON Error: \(derror)"
                    self.fetch_error_message = self.login_error_json_parse_failed
                    
                    self.performingFetch = false
                    return derror
                }
                else
                {
                    self.fetch_error_message = self.login_error_unknown_error
                }
                self.performingFetch = false
                return error
            })
            .sink(receiveCompletion: { _ in },
                  receiveValue: { val in
                    let isValid = self.validateResponce(val)
                    if isValid
                    {
                        self.fetch_error_message = self.login_no_error
                        self.schedule_r = val
                    }
                    else
                    {
                        self.fetch_error_message = self.login_error_wrong_login
                    }
                    self.performingFetch = false
                  })
    }
    
}
