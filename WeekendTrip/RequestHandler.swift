//
//  Caller.swift
//  WeekendTrip
//
//  Created by Justin Rodriguez on 7/13/19.
//  Copyright © 2019 Justin Rodriguez. All rights reserved.
//

import Foundation

var timeToTimeout: Double = 3

func searchRouteData(origin: String, destination: String, date: String) throws -> RouteSearchData? {
    
    print("loading web services")
    let browseRoutesUrlString = "https://skyscanner-skyscanner-flight-search-v1.p.rapidapi.com/apiservices/browseroutes/v1.0/US/USD/en-US/" + origin + "-sky/" + destination + "-sky/" + date
    let browseRoutesUrl = URL(string: browseRoutesUrlString)!
    var request = URLRequest(url: browseRoutesUrl)
    request.setValue("skyscanner-skyscanner-flight-search-v1.p.rapidapi.com", forHTTPHeaderField: "X-RapidAPI-Host")
    request.setValue("355a5d425dmsh69871ab7a8b6922p19ec12jsnec5b7a0ac703", forHTTPHeaderField: "X-RapidAPI-Key")
    
    var routeSearchData: RouteSearchData?
    let semaphore = DispatchSemaphore(value: 0)
    
    URLSession.shared.dataTask(with: request) { (data, response, err) in
        
        guard let data = data else { return }
        
        do {
            let r = try JSONDecoder().decode(RouteSearchData.self, from: data)
            var prices: [Int] = []
            for quote in r.Quotes {
                prices.append(quote.MinPrice)
            }
            prices.sort()
            routeSearchData = r
            semaphore.signal()
        }
        catch let jsonErr {
            print("bummer error:", jsonErr)
            semaphore.signal()
        }
        
        }.resume()
    semaphore.wait(wallTimeout: .distantFuture)
    return routeSearchData
}

func createSession(origin: String, destination: String, inboundDate: String, outboundDate: String) -> String {
    
    print("creating session for " + origin + ", " + destination)
    var responseLink: String = ""
    let semaphore = DispatchSemaphore(value: 0)
    let url = URL(string: "https://skyscanner-skyscanner-flight-search-v1.p.rapidapi.com/apiservices/pricing/v1.0")!
    var request = URLRequest(url: url)
    request.setValue("skyscanner-skyscanner-flight-search-v1.p.rapidapi.com", forHTTPHeaderField: "X-RapidAPI-Host")
    request.setValue("355a5d425dmsh69871ab7a8b6922p19ec12jsnec5b7a0ac703", forHTTPHeaderField: "X-RapidAPI-Key")
    request.httpMethod = "POST"
    let parameters: [String: Any] = [
        "inboundDate": inboundDate,
        "cabinClass": "economy",
        "children": 0,
        "infants": 0,
        "country": "US",
        "currency": "USD",
        "locale": "en-US",
        "originPlace": origin + "-sky",
        "destinationPlace": destination + "-sky",
        "outboundDate": outboundDate,
        "adults": 1
    ]
    request.httpBody = parameters.percentEscaped().data(using: .utf8)
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        
        guard let data = data else { return }
        guard let formattedResponse = response as? HTTPURLResponse else { return }
//        print(formattedResponse)
        if let keyGiven = formattedResponse.allHeaderFields[AnyHashable("Location")] {
            responseLink =  keyGiven as! String
        } else {
            responseLink = ""
        }
        semaphore.signal()
    }
    task.resume()
    let dispatchTime: DispatchTime
    semaphore.wait(timeout: DispatchTime.now() + timeToTimeout)
    
    if responseLink == "" {
        print("response did not come")
        return ""
    }
    print("session key obtain successful")
    return responseLink.sessionKey
}

func pollSessionResults(sessionKey: String) -> SessionResults {
    
    print("polling session for " + sessionKey)
    let url = URL(string: "https://skyscanner-skyscanner-flight-search-v1.p.rapidapi.com/apiservices/pricing/uk2/v1.0/" + sessionKey + "?pageIndex=0&pageSize=10")!
    var request = URLRequest(url: url)
    request.setValue("skyscanner-skyscanner-flight-search-v1.p.rapidapi.com", forHTTPHeaderField: "X-RapidAPI-Host")
    request.setValue("355a5d425dmsh69871ab7a8b6922p19ec12jsnec5b7a0ac703", forHTTPHeaderField: "X-RapidAPI-Key")
    
    var sessionResults: SessionResults?
    let semaphore = DispatchSemaphore(value: 0)
    
    URLSession.shared.dataTask(with: request) { (data, response, err) in
        
        guard let formattedResponse = response as? HTTPURLResponse else { return }
        print(formattedResponse)
        guard let data = data else { return }
        
        do {
            let r = try JSONDecoder().decode(SessionResults.self, from: data)
            sessionResults = r
            semaphore.signal()
        }
        catch let jsonErr {
            print("bummer error:", jsonErr)
            semaphore.signal()
        }
        
    }.resume()
    semaphore.wait(wallTimeout: .distantFuture)
    print("finished polling")
    return sessionResults!
}


func getNearestWeekendDates() -> [String] {
    let today = Date()
    let calendar = Calendar.current
    let todayComponents = calendar.dateComponents([.year, .month, .day, .weekday], from: today)
    var daysUntilNextFriday: Int = 0
    switch todayComponents.weekday {
    case 1:
        daysUntilNextFriday = 5
        print("it's sunday")
        break
    case 2:
        daysUntilNextFriday = 4
        print("it's monday")
        break
    case 3:
        daysUntilNextFriday = 3
        print("it's tuesday")
        break
    case 4:
        daysUntilNextFriday = 2
        print("it's wednesday")
        break
    case 5:
        daysUntilNextFriday = 1
        print("it's thursday")
        break
    case 6:
        daysUntilNextFriday = 7
        print("it's friday")
        break
    case 7:
        daysUntilNextFriday = 6
        print("it's saturday")
        break
    default:
        break
    }
    
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    var nextWeekendDates: [String] = []
    
    var nextFriday: String
    if let nextFridayDate = calendar.date(byAdding: .day, value: daysUntilNextFriday, to: today) {
        nextFriday = formatter.string(from: nextFridayDate)
        print(nextFriday)
        nextWeekendDates.append(nextFriday)
    }
    
    var nextSunday: String
    if let nextSundayDate = calendar.date(byAdding: .day, value: daysUntilNextFriday + 2, to: today) {
        nextSunday = formatter.string(from: nextSundayDate)
        print(nextSunday)
        nextWeekendDates.append(nextSunday)
    }
    
    return nextWeekendDates
    
}

extension Dictionary {
    func percentEscaped() -> String {
        return map { (key, value) in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
            }
            .joined(separator: "&")
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}

extension String {
    var sessionKey: String {
        if self.components(separatedBy: "/").count >= 7 {
            return self.components(separatedBy: "/")[7]
        } else {
            print("error finding session key")
            return ""
        }
    }
}
