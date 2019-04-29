//
//  User.swift
//  RxSwiftExample
//
//  Created by Apple on 3/30/19.
//  Copyright © 2019 Minh Quang Pham. All rights reserved.
//

import UIKit

class User: NSObject {
    @objc var createdAt: NSObject?
    @objc var email: String?
    @objc var scope: String?
    @objc var uid: String?
    @objc var ownedPhotos: [String]?
    @objc var ownedVideos: [String]?
}
