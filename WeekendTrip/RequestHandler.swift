//
//  Caller.swift
//  WeekendTrip
//
//  Created by Justin Rodriguez on 7/13/19.
//  Copyright © 2019 Justin Rodriguez. All rights reserved.
//

import Foundation

class RequestHandler : NSObject {
    
    var responseLinks: [String] = []
    let dispatchGroupCreateSession = DispatchGroup()
    let dispatchGroupPollSession = DispatchGroup()
    var sessionResultsArray: [ResultWithOriginAndDestination] = []
    var searchIsFinished: Bool = false
    var res: [RoundTrip] = []
    
    func search(origin: String, outboundDate: String, inboundDate: String) -> [ResultWithOriginAndDestination]{
        requestForAllDestinations(origin: origin, outboundDate: outboundDate, inboundDate: inboundDate)
        pollForAllDestinations()
        return sessionResultsArray
    }
    
    func requestForAllDestinations(origin: String, outboundDate: String, inboundDate: String) -> Bool {
        responseLinks = []
        for destination in possibleDestinations[origin]! {
            createSession(origin: origin, destination: destination, inboundDate: inboundDate, outboundDate: outboundDate)
        }
//        dispatchGroupCreateSession.notify(queue: .main) {
////            self.pollForAllDestinations()
//            print("waiting")
//            semaphore.signal()
//        }
        dispatchGroupCreateSession.wait()
        print("Awesome")
        return true
    }
    
    func pollForAllDestinations() -> Bool {
        sessionResultsArray = []
        for responseLink in responseLinks {
            pollSessionResults(sessionKey: responseLink)
        }
//        dispatchGroupPollSession.notify(queue: .main) {
//            self.searchIsFinished = true
//            print("Finished polling data2")
//        }
        dispatchGroupPollSession.wait()
        return true
    }

    func createSession(origin: String, destination: String, inboundDate: String, outboundDate: String) {
        
        print("creating session for " + origin + ", " + destination)
        dispatchGroupCreateSession.enter()
        var responseLink: String = ""
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
            
            if let err = error {
//                self.handleError()
                print("Leaving dispatch Group Create Session with Error")
                self.dispatchGroupCreateSession.leave()
                return
            }
            guard let data = data else { return }
            guard let formattedResponse = response as? HTTPURLResponse else { return }
            if let keyGiven = formattedResponse.allHeaderFields[AnyHashable("Location")] {
                responseLink =  keyGiven as! String
            } else {
                responseLink = ""
            }
            self.responseLinks.append(responseLink.sessionKey)
            print("Leaving dispatch Group Create Session")
            self.dispatchGroupCreateSession.leave()
        }
        task.resume()
    }

    func pollSessionResults(sessionKey: String) {
        
        if sessionKey != "" {
            print("polling session for " + sessionKey)
            dispatchGroupPollSession.enter()
            let url = URL(string: "https://skyscanner-skyscanner-flight-search-v1.p.rapidapi.com/apiservices/pricing/uk2/v1.0/" + sessionKey + "?pageIndex=0&pageSize=10")!
            var request = URLRequest(url: url)
            request.setValue("skyscanner-skyscanner-flight-search-v1.p.rapidapi.com", forHTTPHeaderField: "X-RapidAPI-Host")
            request.setValue("355a5d425dmsh69871ab7a8b6922p19ec12jsnec5b7a0ac703", forHTTPHeaderField: "X-RapidAPI-Key")
            
            URLSession.shared.dataTask(with: request) { (data, response, err) in
                
                guard let data = data else { return }
                
                do {
                    let r = try JSONDecoder().decode(SessionResults.self, from: data)
                    let destination = self.nameOfDestination(sessionResult: r)
                    let origin = self.nameOfOrigin(sessionResult: r)
                    self.sessionResultsArray.append(ResultWithOriginAndDestination(sessionResults: r, originCode: origin[0], destinationCode: destination[0], originName: origin[1], destinationName: destination[1]))
                    print("Leaving dispatch Group Create Session")
                    self.dispatchGroupPollSession.leave()
                }
                catch let jsonErr {
                    print("bummer error:", jsonErr)
                    print("Leaving dispatch Group Create Session")
                    self.dispatchGroupPollSession.leave()
                }
            }.resume()
        }
    }
    
    func nameOfDestination(sessionResult: SessionResults) -> [String] {
        print("Finding place code")
        let destinationID = Int(sessionResult.Query.DestinationPlace)
        let places = sessionResult.Places
        print("target: " + sessionResult.Query.DestinationPlace)
        for place in places {
            if place.Id == destinationID {
                let code = place.Code
                let name = place.Name
                return [code!, name]
            }
        }
        print("couldn't find place code")
        return ["",""]
    }

    func nameOfOrigin(sessionResult: SessionResults) -> [String] {
        print("Finding place code")
        let originID = Int(sessionResult.Query.OriginPlace)
        let places = sessionResult.Places
        print("target: " + sessionResult.Query.OriginPlace)
        for place in places {
            if place.Id == originID {
                let code = place.Code
                let name = place.Name
                return [code!, name]
            }
        }
        print("couldn't find place code")
        return ["",""]
    }
    
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
