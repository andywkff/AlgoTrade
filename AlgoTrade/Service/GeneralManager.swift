//
//  GeneralManager.swift
//  AlgoTrade
//
//  Created by fung on 12/7/2021.
//

import Foundation

class GeneralManager{
    
    private init(){}
    static let shared = GeneralManager()
    
    func getDBDevice() -> DBUSER_Device{
        let thisDevice = DBUSER_Device()
        thisDevice.device_id = PreferenceService.shared.getDeviceToken() ?? ""
        thisDevice.device_type = getDeviceType()
        thisDevice.last_updated = Int(Date().timeIntervalSince1970)
        return thisDevice
    }
    
    func getDeviceType() -> String{
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else {
                return identifier
            }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
}
