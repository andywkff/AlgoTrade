//
//  DBUSER.swift
//  AlgoTrade
//
//  Created by fung on 12/7/2021.
//

import Foundation
import UIKit
import SwiftUI

class DBUSER: ObservableObject, Codable {
    
    @Published var user_id: String = "TEST_WITH_DEFAULT_USER_ID"
    @Published var instruments: [DBUSER_Instrument] = [DBUSER_Instrument]()
    @Published var devices: [DBUSER_Device] = [DBUSER_Device]()
    @Published var last_updated: Int = 0
    @Published var last_updated_devices: Int = 0
    
    
    func saveToFIR(){
        self.deviceCheck()
        self.user_id = PreferenceService.shared.getID()
        if self.user_id != "TEST_WITH_DEFAULT_USER_ID" {
            DispatchQueue.main.async {
                FirebaseService.shared.update(user: self)
            }
        }
    }
    
    func deviceCheck(){
        let thisDevice = GeneralManager.shared.getDBDevice()
        var isExist = false
        for item in self.devices {
            if thisDevice.device_id == item.device_id{
                isExist = true
                break
            }
        }
        if !isExist && thisDevice.device_id != ""{
            self.devices.append(thisDevice)
        }
    }
    
    func start(completion: @escaping (String) -> Void){
        FirebaseService.shared.checkExist(){ exist in
            debugPrint(exist)
            if exist {
                self.getFireLatest{ value in
                    debugPrint(value)
                    let defaults = UserDefaults()
                    self.user_id = defaults.string(forKey: "user_id") ?? "TEST_WITH_DEFAULT_USER_ID"
                    FirebaseService.shared.setObserver(user_id: self.user_id)
                    debugPrint("after setObserver")
                    self.deviceCheck()
                }
            }
            else {
                debugPrint("new user")
                self.deviceCheck()
                self.user_id = PreferenceService.shared.getID()
                FirebaseService.shared.create(user: self)
                FirebaseService.shared.setObserver(user_id: self.user_id)
                completion("SUCCESS")
                return
            }
        }
    }
    
    func getFireLatest(completion: @escaping (String) -> Void){
        debugPrint("reading")
        FirebaseService.shared.read() { user in
            guard let user = user else {
                completion("error")
                return
            }
            self.instruments = user.instruments
            self.devices = user.devices
            self.user_id = user.user_id
            self.last_updated = user.last_updated
            self.last_updated_devices = user.last_updated_devices
            debugPrint("changed to firebase realtime database")
            completion("SUCCESS")
        }
    }
    
    enum CodingKeys: CodingKey {
        case user_id, instruments, devices, last_updated, last_updated_devices
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        user_id = try container.decodeIfPresent(String.self, forKey: .user_id) ?? "TEST_WITH_DEFAULT_USER_ID"
        instruments = try container.decodeIfPresent([DBUSER_Instrument].self, forKey: .instruments) ?? [DBUSER_Instrument]()
        devices = try container.decodeIfPresent([DBUSER_Device].self, forKey: .devices) ?? [DBUSER_Device]()
        last_updated = try container.decodeIfPresent(Int.self, forKey: .last_updated) ?? 0
        last_updated_devices = try container.decodeIfPresent(Int.self, forKey: .last_updated_devices) ?? 0
        
    }
    init(){}
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(user_id, forKey: .user_id)
        try container.encode(instruments, forKey: .instruments)
        try container.encode(devices, forKey: .devices)
        try container.encode(last_updated, forKey: .last_updated)
        try container.encode(last_updated_devices, forKey: .last_updated_devices)
        
    }
}

class DBUSER_Instrument: ObservableObject, Codable{
    @Published var instrument: String = ""
    @Published var config: DBUSER_InstrumentsConfig = DBUSER_InstrumentsConfig()
    @Published var transactions: [DBUSER_Transaction] = [DBUSER_Transaction]()
    @Published var config_simulation_history: [DBUSER_InstrumentsConfig] = [DBUSER_InstrumentsConfig]()
    @Published var config_history: [DBUSER_InstrumentsConfig] = [DBUSER_InstrumentsConfig]()
    @Published var last_updated_best: Int = 0
    @Published var last_updated_transactions: Int = 0
    enum CodingKeys: CodingKey {
        case instrument, config, transactions, config_simulation_history, config_history, last_updated_transactions, last_updated_best
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        instrument = try container.decodeIfPresent(String.self, forKey: .instrument) ?? ""
        config = try container.decodeIfPresent(DBUSER_InstrumentsConfig.self, forKey: .config) ?? DBUSER_InstrumentsConfig()
        transactions = try container.decodeIfPresent([DBUSER_Transaction].self, forKey: .transactions) ?? [DBUSER_Transaction]()
        config_history = try container.decodeIfPresent([DBUSER_InstrumentsConfig].self, forKey: .config_history) ?? [DBUSER_InstrumentsConfig]()
        config_simulation_history = try container.decodeIfPresent([DBUSER_InstrumentsConfig].self, forKey: .config_simulation_history) ?? [DBUSER_InstrumentsConfig]()
        last_updated_transactions = try container.decodeIfPresent(Int.self, forKey: .last_updated_transactions) ?? 0
        last_updated_best = try container.decodeIfPresent(Int.self, forKey: .last_updated_best) ?? 0
    }
    init(){}
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(instrument, forKey: .instrument)
        try container.encode(config, forKey: .config)
        try container.encode(transactions, forKey: .transactions)
        try container.encode(config_history, forKey: .config_history)
        try container.encode(config_simulation_history, forKey: .config_simulation_history)
        try container.encode(last_updated_transactions, forKey: .last_updated_transactions)
        try container.encode(last_updated_best, forKey: .last_updated_best)
    }
}

class DBUSER_Transaction: ObservableObject, Codable{
    @Published var date: String = ""
    @Published var instrument: String = ""
    @Published var share: Int = 0
    @Published var price: Double = 0.0
    @Published var direction: String = ""
    @Published var done: Bool = false
    @Published var final_price: Double = 0.0
    @Published var final_share: Int = 0
    @Published var last_updated: Int = 0
    @Published var created: Int = 0
    enum CodingKeys: CodingKey {
        case instrument, share, price, direction, done, final_price, final_share, last_updated, created, date
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        instrument = try container.decodeIfPresent(String.self, forKey: .instrument) ?? ""
        date = try container.decodeIfPresent(String.self, forKey: .date) ?? ""
        direction = try container.decodeIfPresent(String.self, forKey: .direction) ?? ""
        share = try container.decodeIfPresent(Int.self, forKey: .share) ?? 0
        price = try container.decodeIfPresent(Double.self, forKey: .price) ?? 0.0
        done = try container.decodeIfPresent(Bool.self, forKey: .done) ?? false
        final_price = try container.decodeIfPresent(Double.self, forKey: .final_price) ?? 0.0
        final_share = try container.decodeIfPresent(Int.self, forKey: .final_share) ?? 0
        last_updated = try container.decodeIfPresent(Int.self, forKey: .last_updated) ?? 0
        created = try container.decodeIfPresent(Int.self, forKey: .created) ?? 0
    }
    init(){}
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(instrument, forKey: .instrument)
        try container.encode(date, forKey: .date)
        try container.encode(direction, forKey: .direction)
        try container.encode(share, forKey: .share)
        try container.encode(price, forKey: .price)
        try container.encode(done, forKey: .done)
        try container.encode(final_share, forKey: .final_share)
        try container.encode(final_price, forKey: .final_price)
        try container.encode(last_updated, forKey: .last_updated)
        try container.encode(created, forKey: .created)
    }
}

class DBUSER_InstrumentsConfig: ObservableObject, Codable{
    @Published var instrument: String = ""
    @Published var rules: String = ""
    @Published var value: Int = 0
    @Published var slowEMA: Int = 0
    @Published var fastEMA: Int = 0
    @Published var signalEMA: Int = 0
    @Published var test_period: String = ""
    @Published var portfolio: Double = 0.0
    @Published var active: Bool = false
    @Published var last_updated: Int = 0
    @Published var created: Int = 0
    enum CodingKeys: CodingKey {
        case instrument, last_updated, created, rules, value, test_period, portfolio, active, slowEMA, fastEMA, signalEMA
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        instrument = try container.decodeIfPresent(String.self, forKey: .instrument) ?? ""
        rules = try container.decodeIfPresent(String.self, forKey: .rules) ?? ""
        value = try container.decodeIfPresent(Int.self, forKey: .value) ?? 0
        slowEMA = try container.decodeIfPresent(Int.self, forKey: .slowEMA) ?? 0
        fastEMA = try container.decodeIfPresent(Int.self, forKey: .fastEMA) ?? 0
        signalEMA = try container.decodeIfPresent(Int.self, forKey: .signalEMA) ?? 0
        test_period = try container.decodeIfPresent(String.self, forKey: .test_period) ?? ""
        portfolio = try container.decodeIfPresent(Double.self, forKey: .portfolio) ?? 0.0
        active = try container.decodeIfPresent(Bool.self, forKey: .active) ?? false
        last_updated = try container.decodeIfPresent(Int.self, forKey: .last_updated) ?? 0
        created = try container.decodeIfPresent(Int.self, forKey: .created) ?? 0
    }
    init(){}
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(last_updated, forKey: .last_updated)
        try container.encode(created, forKey: .created)
        try container.encode(instrument, forKey: .instrument)
        try container.encode(rules, forKey: .rules)
        try container.encode(value, forKey: .value)
        try container.encode(slowEMA, forKey: .slowEMA)
        try container.encode(fastEMA, forKey: .fastEMA)
        try container.encode(signalEMA, forKey: .signalEMA)
        try container.encode(test_period, forKey: .test_period)
        try container.encode(portfolio, forKey: .portfolio)
        try container.encode(active, forKey: .active)
    }
}

class DBUSER_Device: ObservableObject, Codable {
    @Published var user_id: String = "TEST_WITH_DEFAULT_USER_ID"
    @Published var device_id: String = ""
    @Published var device_type: String = ""
    @Published var last_updated: Int? = 0
    enum CodingKeys: CodingKey {
        case device_id, device_type, last_updated, user_id
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(user_id, forKey: .user_id)
        try container.encode(device_id, forKey: .device_id)
        try container.encode(device_type, forKey: .device_type)
        try container.encode(last_updated, forKey: .last_updated)
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        user_id = try container.decodeIfPresent(String.self, forKey: .user_id) ?? ""
        last_updated = try container.decodeIfPresent(Int.self, forKey: .last_updated) ?? 0
        device_id = try container.decodeIfPresent(String.self, forKey: .device_id) ?? ""
        device_type = try container.decodeIfPresent(String.self, forKey: .device_type) ?? ""
    }
    init(){}
}
