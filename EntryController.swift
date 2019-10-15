//
//  EntryController.swift
//  JournalCloudKit
//
//  Created by Michael Flowers on 10/14/19.
//  Copyright © 2019 Michael Flowers. All rights reserved.
//

import Foundation
import CloudKit

class EntryController {
    static let shared = EntryController()
    
    var entries: [Entry] = []
    //create your cloudKit container
    let cloudKitContainer = CKContainer.default().privateCloudDatabase
    
    func saveEntry(entry: Entry, completion: @escaping (Bool) -> Void){
        //Before we can save the entry to the cloud, we have to turn it into a ckrecord. Encode it into a ckRecord
        let entryToCKRecord = CKRecord(entry: entry)
        
        cloudKitContainer.save(entryToCKRecord) { (record, error) in
            if let error = error {
                print("Error saving entry to cloudKiit: \(error.localizedDescription) ///\(#function)")
                completion(false)
                return
            }
            
            //If the entry has been saved properly, then we can turn that back into our  model and then finally save it to  our data source  of truth
            guard let savedRecord  = record else {
                print("Error with savedRecord from cloudKit")
                completion(false)
                return
            }
            
            //now we can decode savedRecord back into our model
            guard let CKRecordToEntry = Entry(ckRecord: savedRecord) else {
                print("Error turning ckRecord back into our model object")
                completion(false)
                return
            }
            
            //append our data source of truth with the new model object we've initialized with the  CKRecord
            self.entries.append(CKRecordToEntry)
            print("Saved Model successfully")
            completion(true)
        }
        
    }
    
    func addEntryWith(title: String, bodyText: String, completion: @escaping(Bool) -> Void){
        let newEntry = Entry(title: title, bodyText: bodyText)
        saveEntry(entry: newEntry) { (success) in
            if success {
                completion(true)
            } else {
                completion(false)
                return
            }
        }
    }
    
    func fetch(completion: @escaping (Bool) -> Void){
        
        //we want the predicate to reutrn all true values of our recordType
        let predicate =  NSPredicate(value: true)
        //recordType, if you remember in the model file, it is just the string representation of our model object class: Entry
        let query = CKQuery(recordType: EntryStrings.typeKey, predicate: predicate)
        cloudKitContainer.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("Error fetching all entries from cloudKiit: \(error.localizedDescription) ///\(#function)")
                completion(false)
                return
            }
            
            //unwrapp the records to make sure they have values
            guard let returnedRecordsFromCloudKit = records else {
                print("Error returning records from cloudKit")
                completion(false)
                return
            }
            
            //Turn all of those records into our data model object, the best way to loop and initialize is to use a compactMap because itll only  return the records that CAN BE initalized or turned into  our data model object
            let arrayOfReturnedRecordsFromCloudKit = returnedRecordsFromCloudKit.compactMap { Entry(ckRecord: $0) }
            
            //asigned that array  to our data source of truth
            self.entries = arrayOfReturnedRecordsFromCloudKit
            print("Fetched all entries from cloud kit successfully")
            completion(true)
        }
    }
    
    
    func delete(entry: Entry, completion: @escaping (Bool) -> Void){
        //delete locally
        guard let index = entries.firstIndex(of: entry) else { return }
        self.entries.remove(at: index)
        
        //delete on cloudkit
        cloudKitContainer.delete(withRecordID: entry.ckRecordID) { (recordID, error) in
            if let error = error {
                print("Error deleting entry from cloudKiit: \(error.localizedDescription) ///\(#function)")
                completion(false)
                return
            }
            for entry in self.entries {
                //if the recordId we get back  matches an entry's in our data source of truth, then deleting in cloudkit didn't work
                if entry.ckRecordID == recordID {
                    completion(false)
                    return
                } else {
                    //if we can't match the record ids locally and on cloudKit then the deletion worked
                    completion(true)
                }
            }
        }
    }
    
    //ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)
    func update(entry: Entry, withNewTitle: String, withNewBodyText: String, newTimestamp: Date = Date(), completion: @escaping (Bool)  -> Void){
        entry.title = withNewTitle
        entry.bodyText = withNewBodyText
        entry.timestamp = newTimestamp

    
    //turn the model into a ckRecord
        let recordFromEntry =  CKRecord(entry: entry)
        
        //pass in the newRecord into the function
       let operation = CKModifyRecordsOperation(recordsToSave: [recordFromEntry], recordIDsToDelete: nil)
        
        //we want to update and save the changes to the ckRecord for only the keys that have been changed.
        operation.savePolicy = .changedKeys //save only the changes of the keys values that have been changed
        
        //to delete an object with the desired priority
        operation.queuePriority = .high
        
        //the block to execute after the status of all changes is known
        operation.modifyRecordsCompletionBlock = { (records, recordIDs, error) -> Void in
            
        }
    }
    
    
}




























