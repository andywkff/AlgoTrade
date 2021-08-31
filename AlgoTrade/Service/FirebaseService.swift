//
//  FirebaseService.swift
//  AlgoTrade
//
//  Created by fung on 12/7/2021.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseDatabaseSwift
import CloudKit
import CodableFirebase

class FirebaseService {
    private init(){}
    static let shared = FirebaseService()
    
    private var db_ref: DatabaseReference? = nil
    private var user_id: String? = "TEST_WITH_DEFAULT_USER_ID"
    private var user:DBUSER = DBUSER()

    func start(completion: @escaping (String) -> Void){
        fetchID { id in
            Database.database().isPersistenceEnabled = true
            self.makeReference(user_id: self.user_id ?? "TEST_WITH_DEFAULT_USER_ID")
            let scoresRef = Database.database().reference(withPath: "\(self.user_id)")
            scoresRef.keepSynced(true)
            debugPrint("set FIR ref")
            completion("SUCCESS")
        }
    }
    
    func read(completion: @escaping (DBUSER?) -> Void){
            self.db_ref?.getData { (error, snapshot) in
                if let error = error {
                    debugPrint("Error getting data \(error)")
                    completion(nil)
                }
                else if snapshot.exists() {
                    debugPrint("Got data \(snapshot.value!)")
                    guard let value = snapshot.value else { return }
                        do {
                            let model = try FirebaseDecoder().decode(DBUSER.self, from: value)
                            completion(model)
                        } catch let error {
                            debugPrint(error)
                            completion(nil)
                        }
                }
                else {
                    debugPrint("No data available")
                    completion(nil)
                }
            }
    }
    
    func checkExist(completion: @escaping (Bool) -> Void){
        debugPrint("Check Exist")
            self.db_ref?.getData { (error, snapshot) in
                if let error = error {
                    debugPrint("Error getting data \(error)")
                    completion(false)
                }
                else if snapshot.exists() {
                    debugPrint("Got data \(snapshot.value!)")
                    guard let value = snapshot.value else { return }
                        do {
                            let _ = try FirebaseDecoder().decode(DBUSER.self, from: value)
                            completion(true)
                        } catch let error {
                            debugPrint(error)
                            completion(false)
                        }
                }
                else {
                    debugPrint("No data available")
                    completion(false)
                }
            }
    }
    
    func create(user: DBUSER){
        let data = try? FirebaseEncoder().encode(user)
        self.db_ref?.setValue(data)
    }
    
    func update(user: DBUSER){
        let data = try? FirebaseEncoder().encode(user)
        self.db_ref?.setValue(data)
    }
    
    func delete(completion: @escaping (String) -> Void){
        self.db_ref?.removeValue()
    }
    
    func setObserver(user_id: String){
        self.db_ref?.observe(.value, with: { snapshot in
            guard let value = snapshot.value else { return }
                do {
                    let model = try FirebaseDecoder().decode(DBUSER.self, from: value)
                    debugPrint(model)
                    FirebasePublisher.shared.publisher.send(true)
                } catch let error {
                    debugPrint(error)
                }
        })
    }
    
    func makeReference(user_id: String){
        db_ref = Database.database().reference().child("users/\(user_id)")
        debugPrint(db_ref as Any)
    }
    
    func fetchID(completion: @escaping (String?)-> Void){
        CKContainer.default().fetchUserRecordID { recordId, error in
            if error != nil {
                debugPrint(error as Any)
                let defaults = UserDefaults()
                if defaults.object(forKey: "user_id") == nil {
                    let uuid = UUID().uuidString
                    self.user_id = uuid
                    PreferenceService.shared.setID(id: uuid)
                    debugPrint(self.user_id as Any)
                    completion(self.user_id)
                }
                else {
                    let id = defaults.string(forKey: "user_id") ?? "TEST_WITH_DEFAULT_USER_ID"
                    self.user_id = id
                    debugPrint(self.user_id as Any)
                    completion(self.user_id)
                }
            }
            else {
                debugPrint("icloud id")
                self.user_id = recordId?.recordName
                debugPrint(recordId?.recordName as Any)
                PreferenceService.shared.setID(id: self.user_id ?? "TEST_WITH_DEFAULT_USER_ID")
                completion(self.user_id)
            }
        }
    }
}
