//
//  Constants.swift
//  Constants
//
//  Created by Munib Hamza on 30/08/2021.
//

import Foundation
import MapKit

struct Constants {
    static let sharedDefault = UserDefaults(suiteName: "group.app.vpnfast.com")!
    static let vpnStatusKey = "VPNStatus"
    static let isLoggedIn = "isLoggedIn"
    static let authToken = "authToken"
    static let appSecret = "af8c55a9807d45c5a823b30f4110a7ca"

}

internal struct AC {
    
    static let Error = "Error!"
    static let Alert = "Alert"
    static let DeviceType = "ios"
    static let Ok = "Ok"
    static let EmailNotValid = "Email is not valid."
    static let PhoneNotValid = "Phone number is not valid."
    static let EmailEmpty = "Email is empty."
    static let PhoneEmpty = "Phone number is empty"
    static let FirstNameEmpty = "First name is empty"
    static let LastNameEmpty = "Last name is empty"
    static let NameEmpty = "Name is empty"
    static let Empty = " is empty"
    static let PasswordsMisMatch = "Make sure your passwords match"
    static let LoginSuccess = "Login successful"
    static let SignUpSuccess = "Signup successful"
    static let emailPasswordInvalid = "Email or password is not valid"
    static let PasswordEmpty = "Password is empty"
    static let shortPassword = "Password must be atleast 6 digits"
    static let Success = "Success"
    static let InternetNotReachable = "Your phone does not appear to be connected to the internet. Please connect and try again"
    static let UserNameEmpty = "Username is empty"
    static let TermsAndCondition = "Terms and conditions have not been accepted"
    static let AllFieldNotFilled = "Make sure all fields are filled"
    static let fieldCanBeEmpty = "This field can not be empty"
    
    static let SomeThingWrong = "Some thing went wrong. Please try again."
    static let ParsingError = "Received data in wrong format"
    static let SelectFromDropDown = "Please select value from Dropdown"
}

enum Storyboards {
    case Main
    var id: String {
        return String(describing: self)
    }
}



var allServersList :
[(serverId: String, countryName: String, isSelected: Bool, coordinates : CLLocationCoordinate2D)] =
[("","Automatic", true, CLLocationCoordinate2D(latitude: 35.705677, longitude: 139.751389)),
 ("jp-free-02.protonvpn.net.tcp","Japan", false, CLLocationCoordinate2D(latitude: 35.705677, longitude: 139.751389)),
 ("jp-free-06.protonvpn.net.tcp","Japan", false, CLLocationCoordinate2D(latitude: 35.705677, longitude: 139.751389)),
 ("jp-free-08.protonvpn.net.tcp","Japan", false, CLLocationCoordinate2D(latitude: 35.705677, longitude: 139.751389)),
 ("jp-free-11.protonvpn.net.tcp","Japan", false, CLLocationCoordinate2D(latitude: 35.705677, longitude: 139.751389)),
 ("jp-free-14.protonvpn.net.tcp","Japan", false, CLLocationCoordinate2D(latitude: 35.705677, longitude: 139.751389)),
 ("nl-free-20.protonvpn.net.tcp","Netherlands", false, CLLocationCoordinate2D(latitude: 52.376514, longitude: 4.908542)),
 ("nl-free-41.protonvpn.net.tcp","Netherlands", false,CLLocationCoordinate2D(latitude: 52.376514, longitude: 4.908542)),
 ("nl-free-53.protonvpn.net.tcp","Netherlands", false,CLLocationCoordinate2D(latitude: 52.376514, longitude: 4.908542)),
 ("nl-free-96.protonvpn.net.tcp","Netherlands", false,CLLocationCoordinate2D(latitude: 52.376514, longitude: 4.908542)),
 ("nl-free-114.protonvpn.net.tcp","Netherlands", false,CLLocationCoordinate2D(latitude: 52.376514, longitude: 4.908542)),
 ("nl-free-116.protonvpn.net.tcp","Netherlands", false,CLLocationCoordinate2D(latitude: 52.376514, longitude: 4.908542)),
 ("nl-free-146.protonvpn.net.tcp","Netherlands", false,CLLocationCoordinate2D(latitude: 52.376514, longitude: 4.908542)),
 ("us-free-02.protonvpn.net.tcp","USA", false,CLLocationCoordinate2D(latitude: 38.892060, longitude: -77.019910)),
 ("us-free-13.protonvpn.net.tcp","USA", false,CLLocationCoordinate2D(latitude: 38.892060, longitude: -77.019910)),
 ("us-free-31.protonvpn.net.tcp","USA", false,CLLocationCoordinate2D(latitude: 38.892060, longitude: -77.019910)),
 ("us-free-44.protonvpn.net.tcp","USA", false,CLLocationCoordinate2D(latitude: 38.892060, longitude: -77.019910)),
 ("us-free-54.protonvpn.net.tcp","USA", false,CLLocationCoordinate2D(latitude: 38.892060, longitude: -77.019910)),
 ("jp-free-02.protonvpn.net.tcp","Japan", false, CLLocationCoordinate2D(latitude: 35.705677, longitude: 139.751389)),
 ("jp-free-06.protonvpn.net.tcp","Japan", false, CLLocationCoordinate2D(latitude: 35.705677, longitude: 139.751389))
]

#if DEBUG
var bannerId = "ca-app-pub-3940256099942544/2934735716"
var instertialId = "ca-app-pub-3940256099942544/4411468910"
#else
var bannerId = "ca-app-pub-4622923970437216/9634802817"
var instertialId = "ca-app-pub-4622923970437216/4765619512"
#endif

enum webViewURL : String {
    case privacy = "https://sites.google.com/view/vpn-fast-proxy/"
    case terms = "https://sites.google.com/view/vpn-terms-services/"
    
}
