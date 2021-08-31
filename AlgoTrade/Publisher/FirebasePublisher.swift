//
//  FirebasePublisher.swift
//  AlgoTrade
//
//  Created by fung on 12/7/2021.
//

import Foundation
import Combine

class FirebasePublisher {
    
    // to trigger View to update its information
    static let shared = FirebasePublisher()
    let publisher = PassthroughSubject<Bool, Never>()
    
    private init() {}
    
    func send(value: Bool){
        DispatchQueue.main.async {
            self.publisher.send(value)
        }
    }
}
