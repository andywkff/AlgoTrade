//
//  NetworkService.swift
//  AlgoTrade
//
//  Created by fung on 12/7/2021.
//

import Foundation
import SwiftyJSON

class NetworkService {
    
    private init(){}
    static let shared = NetworkService()
    let sessions = URLSession.shared
    
    func get_trigger_count(completionHandler: @escaping (Int?) -> Void){
        let fullURL = Constants.baseURL + Constants.check_count
        let checkCount = getURLComponent(baseUrl: fullURL, queryItems: [])
        guard let checkCount = checkCount else {
            completionHandler(nil)
            return
        }
        let url = checkCount.url!
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(Constants.api, forHTTPHeaderField: "x-api-key")
        let dataTask = sessions.dataTask(with: request, completionHandler: { data, response, error in
            if error != nil{
                debugPrint(error.debugDescription)
                completionHandler(nil)
                return
            }
            guard let data = data else {
                debugPrint("no data")
                completionHandler(nil)
                return
            }
            guard response != nil else{
                debugPrint("no response")
                completionHandler(nil)
                return
            }
            //MARK: Decode data to get the count
            debugPrint("have return data")
            debugPrint(data)
            let json = try! JSON(data: data)
            var count: Int? = 0
            count = json["trigger_count"].int
            debugPrint(json["trigger_count"].int)
            completionHandler(count)
        })
        dataTask.resume()
    }
    
    func add_trigger(user_id: String? = nil, instrument: String? = nil, reason: Int = 0){
        var queryItemList = [URLQueryItem]()
        if let user_id = user_id {
            let userIdQuery = URLQueryItem(name: "user_id", value: user_id)
            queryItemList.append(userIdQuery)
        }
        if let instrument = instrument {
            let instrumentQuery = URLQueryItem(name: "instrument", value: instrument)
            queryItemList.append(instrumentQuery)
        }
        let reasonQuery = URLQueryItem(name: "reason", value: String(reason))
        queryItemList.append(reasonQuery)
        let temp_url = getURLComponent(baseUrl: Constants.baseURL + Constants.new_trigger, queryItems: queryItemList)
        let url = temp_url?.url!
        var request = URLRequest(url: url!, cachePolicy: .reloadIgnoringLocalCacheData)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(Constants.api, forHTTPHeaderField: "x-api-key")
        let task = sessions.dataTask(with: request, completionHandler: { data, response, error in
            debugPrint("i am here now")
        })
        debugPrint("sent")
        debugPrint(url as Any)
        task.resume()
    }
    
    func getURLComponent(baseUrl: String, queryItems: [URLQueryItem]) -> URLComponents? {
        var component = URLComponents(string: baseUrl)
        if queryItems.count > 0{
            component?.queryItems = queryItems
        }
        return component
    }
}
