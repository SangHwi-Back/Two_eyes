//
//  LoginView+Keychain.swift
//  iosApp
//
//  Created by SangHwiBack on 4/27/26.
//

import Foundation
import AuthenticationServices
import GoogleSignIn

protocol KeychainSendable {
    static var service: String { get }
    static var account: String { get }
    static var accessGroup: String? { get }
}

struct AppleUserData: Codable, KeychainSendable {
    static var service: String {
        Bundle.main.bundleIdentifier ?? "com.example.twoeyesproject.TwoEyesProject"
    }
    
    static var account: String {
        String(describing: AppleUserData.self)
    }
    
    static var accessGroup: String? { nil }
    
    /// User's Apple userId
    let user: String
    /// Password used when apple sign in
    let password: String?
    let nameComponents: PersonNameComponents?
    let email: String?
    let identityToken: String?
    let authorizationCode: String?
    var name: String {
        (nameComponents?.familyName ?? "") + (nameComponents?.givenName ?? "")
    }
    
    init(credential: ASAuthorizationAppleIDCredential) {
        self.user = credential.user
        self.password = nil
        self.nameComponents = credential.fullName
        self.email = credential.email
        self.identityToken = credential.identityToken?.utf8String
        self.authorizationCode = credential.authorizationCode?.utf8String
    }
    
    init(credential: ASPasswordCredential) {
        self.user = credential.user
        self.password = nil
        self.nameComponents = nil
        self.email = nil
        self.identityToken = nil
        self.authorizationCode = nil
    }
}

struct GoogleUserData: Codable & KeychainSendable {
    static var service: String {
        Bundle.main.bundleIdentifier ?? "com.example.twoeyesproject.TwoEyesProject"
    }
    
    static var account: String {
        String(describing: GoogleUserData.self)
    }
    
    static var accessGroup: String? { nil }
    
    let url: URL?
    let name: String
    let givenName: String?
    let familyName: String?
    let email: String
    
    init(profile: GIDProfileData) {
        self.url = profile.imageURL(withDimension: 180)
        self.name = profile.name
        self.email = profile.email
        self.givenName = profile.givenName
        self.familyName = profile.familyName
    }
}
