//
//  Constant.swift
//  AwesomePhotos
//
//  Created by Trung on 4/16/19.
//  Copyright © 2019 Minh Quang Pham. All rights reserved.
//

import Foundation

enum SharingPermissionConstants: String {
    case OwnerPermission = "owner"
    case ViewerPermission = "viewer"
}

enum Limits : Int {
    case OwnersLimit = 5
}

let ScopeConstants = ["adminScope":"0","userScope":"1"]

let PhotoTypesConstants = ["OriginalPhoto": "og", "WatermarkPhoto": "wm", "NoWatermarkPhoto": "nwm"]

