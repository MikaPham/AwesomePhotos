//
//  SettingsSectionHeader.swift
//  AwesomePhotos
//
//  Created by Kha, Pham Minh on 4/24/19.
//
import UIKit

protocol SectionType: CustomStringConvertible {
    var containsSwitch: Bool { get }
}

enum SettingsSection: Int, CaseIterable, CustomStringConvertible {
    
    // List of SectionHeaders in Settings
    case Option
    case Login
    case More
    
    var description: String{
        switch self {
        case .Option: return "OPTIONS"
        case .Login: return "LOGIN"
        case .More: return "MORE"
        }
    }
}

// Describes options for Options section
enum OptionOptions: Int, CaseIterable, SectionType {
    case cameraUpload
    case cameraUploadSubtitle
    case spacing1
    case saveToPhotos
    case saveToPhotosSubtitle
    
    var containsSwitch: Bool {
        switch self {
        case .cameraUpload: return true
        case .cameraUploadSubtitle: return false
        case .saveToPhotos: return true
        case .saveToPhotosSubtitle: return false
        default : return false

        }
    }
    
    var description: String{
        switch self {
        case .cameraUpload: return "Camera Upload"
        case .cameraUploadSubtitle: return "Turn on to automatically upload photos and videos to your storage."
        case .saveToPhotos: return "Save To Photos"
        case .saveToPhotosSubtitle: return "Turn on to automatically save photos and videos to your camera roll."
        default : return ""

        }
    }
    
}

// Describes option for Login section
enum LoginOptions: Int, CaseIterable, SectionType{
    case resetPassword
    
    var containsSwitch: Bool { return false }
    
    var description: String{
        switch self {
        case .resetPassword: return "Reset Password"
        }
    }
}

// Describes options for More section
enum MoreOptions: Int, CaseIterable, SectionType{
    case version
    case contactUs
    case rateThisApp
    case spacing
    case deleteAccount
    case signOut
    

    var containsSwitch: Bool { return false }
    
    var description: String{
        switch self {
        case .version: return "Version"
        case .contactUs: return "Contact Us"
        case .rateThisApp: return "Rate This App"
        case .deleteAccount: return "Delete account"
        case .signOut: return "Sign Out"
        default : return ""

        }
    }
}

