//
//  PreferenceService.swift
//  AlgoTrade
//
//  Created by fung on 12/7/2021.
//

import Foundation

class PreferenceService {
    
    private init (){}
    static let shared = PreferenceService()
    let defaults = UserDefaults()
    
    func set_badge_count(count: Int){
        defaults.setValue(count, forKey: "badge_count")
    }
    
    func get_badge_count() -> Int{
        return defaults.integer(forKey: "badge_count")
    }
    
    func setDeviceToken(hexString: String){
        defaults.setValue(hexString, forKey: "device_token")
    }
    
    func getDeviceToken() -> String? {
        return defaults.string(forKey: "device_token")
    }
    
    func setID(id: String){
        defaults.setValue(id, forKey: "user_id")
    }
    
    func getID() -> String{
        return defaults.string(forKey: "user_id") ?? "TEST_WITH_DEFAULT_USER_ID"
    }
}
