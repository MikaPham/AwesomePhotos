//
//  FirebaseFunctions.swift
//  AwesomePhotos
//
//  Created by Trung on 4/16/19.
//  Copyright © 2019 Minh Quang Pham. All rights reserved.
//

import Foundation

import Firebase
let db = Firestore.firestore()

func createOrUpdate(collection: String, docId: String, data: Any) {
    db.collection(collection).document(docId).setData(data as! [String : Any])
}
