//
//  Photo.swift
//  AwesomePhotos
//
//  Created by Trung on 4/16/19.
//  Copyright © 2019 Minh Quang Pham. All rights reserved.
//

import Foundation

class Photo: NSObject {
    @objc var uid: String?
    @objc var pathToog: String?
    @objc var pathTowm: String?
    @objc var pathTonwm: String?
    @objc var owners: [String]?
    @objc var sharedWith: [String]?
    @objc var sharedWM: [String]?
    @objc var size: NSNumber?
    @objc var name: String?
    @objc var width: NSNumber?
    @objc var height: NSNumber?
    @objc var createdDate: NSDate?
    @objc var location: [String: String]?
    @objc var lastViewed: NSDate?
}
