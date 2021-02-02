//
//  EntryController.swift
//  CloudKitJournal
//
//  Created by Devin Flora on 2/1/21.
//  Copyright © 2021 Zebadiah Watson. All rights reserved.
//

import CloudKit

class EntryController {
    
    // MARK: - Properties
    static let shared = EntryController()
    var entries: [Entry] = []
    let privateDB = CKContainer.default().privateCloudDatabase
    
    // MARK: - Methods
    func createEntryWith(title: String, body: String, completion: @escaping (Result<Entry?,EntryError>) -> Void) {
        let newEntry = Entry(title: title, body: body)
        save(entry: newEntry, completion: completion)
    }
    
    func save(entry: Entry, completion: @escaping (Result<Entry?,EntryError>) -> Void) {
        let entry = CKRecord(entry: entry)
        privateDB.save(entry) { (record, error) in
            if let error = error {
                print("===== ERROR =====")
                print("Function: \(#function)")
                print(error)
                print("Description: \(error.localizedDescription)")
                print("===== ERROR =====")
                return completion(.failure(.ckError(error)))
            }
            guard let record = record,
                  let savedRecord = Entry(ckRecord: record) else { return completion(.failure(.unableToUnwrap)) }
            self.entries.append(savedRecord)
            completion(.success(savedRecord))
        }
    }
    
    func fetchEntriesWith(completion: @escaping (Result<[Entry]?,EntryError>) -> Void) {
        let fetchPredicate = NSPredicate(value: true)
        let query = CKQuery(recordType: EntryConstants.recordType, predicate: fetchPredicate)
        
        CKContainer.default().privateCloudDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("===== ERROR =====")
                print("Function: \(#function)")
                print(error)
                print("Description: \(error.localizedDescription)")
                print("===== ERROR =====")
                return completion(.failure(.ckError(error)))
            }
            guard let records = records else { return completion(.failure(.unableToUnwrap)) }
            let fetchedEntries = records.compactMap { Entry(ckRecord: $0) }
            self.entries = fetchedEntries
            completion(.success(fetchedEntries))
        }
    }
    
    func delete(entry: Entry, completion: @escaping (Result<String,EntryError>) -> Void) {
        let ckRecord = CKRecord(entry: entry)
        privateDB.delete(withRecordID: ckRecord.recordID) { (record, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("===== ERROR =====")
                    print("Function: \(#function)")
                    print(error)
                    print("Description: \(error.localizedDescription)")
                    print("===== ERROR =====")
                    return completion(.failure(.ckError(error)))
                }
                guard let index = self.entries.firstIndex(of: entry) else { return completion(.failure(.unableToUnwrap)) }
                self.entries.remove(at: index)
                completion(.success("Entry Removed"))
            }
        }
    }
}//End of Class
