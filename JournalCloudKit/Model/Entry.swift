//
//  Entry.swift
//  JournalCloudKit
//
//  Created by Michael Flowers on 10/14/19.
//  Copyright © 2019 Michael Flowers. All rights reserved.
//

import Foundation
import CloudKit

struct EntryStrings {
    static let typeKey = "Entry"
    fileprivate static let titleKey = "title"
    fileprivate static let bodyTextKey = "bodyText"
    fileprivate static let timestampKey = "timestamp"
    fileprivate static let ckRecordID = "ckRecordID"
}

class Entry {
    var title: String
    var bodyText: String
    var timestamp: Date
    var ckRecordID: CKRecord.ID
    
    init(title: String, bodyText: String, timestamp: Date =  Date(), ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)){
        self.title = title
        self.bodyText =  bodyText
        self.timestamp = timestamp
        //Giving the ckRecord.ID a default value will allow  you  to refer back to entry objects CKRecord without an optional CKRecord.ID
        self.ckRecordID = ckRecordID
    }
}

//This is decoding a CkRecord and turning/initializing or data model
//DECODE our CKRecord into our Model
extension Entry {
    //Add a failable convenince initializer that takes in ckRecord
    convenience init?(ckRecord: CKRecord){
        //because we are getting this ckrecord from a database it might return as nil
        guard let title =  ckRecord[EntryStrings.titleKey] as? String,
            let bodyText = ckRecord[EntryStrings.bodyTextKey] as? String,
            let timestamp = ckRecord[EntryStrings.timestampKey] as? Date
            else { print("Error unwrapping CKRecord from database and turning it into our data model object") ; return nil }
        //    let ckRecordID = ckRecord[EntryStrings.ckRecordID as CKRecord.ID
        
        
        //Call the member initializer to make your data model object and passing in the values pulled from the ckRecord as arguments
        self.init(title: title, bodyText: bodyText, timestamp: timestamp, ckRecordID: ckRecord.recordID)
    }
}


//ENCODE OUR MODEL into a ckrecord
extension CKRecord {
    convenience init(entry: Entry){
        //because  we are going to update we need the ID to identify the model/record
        //call the designated CKRecord Initializer which takes in a recordType and a recordID.
        //The recordType will  be the string representation of your Model class: Entry.
        //The recordID is going to be the ckRecordID property on the entry (variable that we passed in as a parameter) your initializer takes as a parameter
        self.init(recordType: EntryStrings.typeKey, recordID: entry.ckRecordID)
        
        //Because we are creating a CKRecord, which is a dictionary, we have to set its keys and values, basically make the dictionary on the backend
        //CKRecord instance method ( value : key ) we get the value from the model we passed in as a parameter in the CK's initalizer
         self.setValue(entry.title, forKey: EntryStrings.titleKey)
         self.setValue(entry.bodyText, forKey: EntryStrings.bodyTextKey)
         self.setValue(entry.timestamp, forKey: EntryStrings.timestampKey)
    }
}

extension Entry: Equatable  {
    static func == (lhs: Entry, rhs: Entry) -> Bool {
        return lhs.ckRecordID == rhs.ckRecordID
    }
    
    
}
