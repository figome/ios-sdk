//
//  User.swift
//  Figo
//
//  Created by Christian König on 23.11.15.
//  Copyright © 2015 CodeStage. All rights reserved.
//

import Unbox


public struct User: Unboxable {
    
    /// Internal figo Connect user ID. Only available when calling with scope user=ro or better.
    public let userID: String?

    /// First and last name
    public let name: String
    
    /// Email address
    public let email: String
    
    /// Postal address for bills, etc. Only available when calling with scope user=ro or better.
    public let address: Address?
    
    /// This flag indicates whether the email address has been verified. Only available when calling with scope user=ro or better.
    public let verifiedEmail: Bool?

    /// This flag indicates whether the user has agreed to be contacted by email. Only available when calling with scope user=ro or better.
    public let sendNewsletter: Bool?
    
    /// Timestamp of figo Account registration. Only available when calling with scope user=ro or better.
    public let joinDate: FigoDate?
    
    /// Two-letter code of preferred language. Only available when calling with scope user=ro or better.
    public let language: String?
    
    /// This flag indicates whether the figo Account plan is free or premium. Only available when calling with scope user=ro or better.
    public let premium: Bool?
    
    /// Timestamp of premium figo Account expiry. Only available when calling with scope user=ro or better.
    public let premiumExpiresOn: FigoDate?
    
    /// Provider for premium subscription or Null if no subscription is active. Only available when calling with scope user=ro or better.
    public let premiumSubscription: String?
    
    /// If this flag is set then all local data must be cleared from the device and re-fetched from the figo Connect server. Only available when calling with scope user=ro or better.
    public let forceReset: Bool?
    
    /// Auto-generated recovery password. This response parameter will only be set once and only for the figo iOS app and only for legacy figo Accounts. The figo iOS app must display this recovery password to the user. Only available when calling with scope user=ro or better.
    public let recoveryPassword: String?
    
    /// Array of filters defined by the user
    public let filters: [AnyObject]?
    
    
    public init(unboxer: Unboxer) throws {
        userID                 = try unboxer.unbox(key: "user_id")
        name                    = try unboxer.unbox(key: "name")
        email                   = try unboxer.unbox(key: "email")
        address                 = try unboxer.unbox(key: "address")
        verifiedEmail          = try unboxer.unbox(key: "verified_email")
        sendNewsletter         = try unboxer.unbox(key: "send_newsletter")
        joinDate               = try unboxer.unbox(key: "join_date")
        language                = try unboxer.unbox(key: "language")
        premium                 = try unboxer.unbox(key: "premium")
        premiumExpiresOn      = try unboxer.unbox(key: "premium_expires_on")
        premiumSubscription    = try unboxer.unbox(key: "premium_subscription")
        forceReset             = try unboxer.unbox(key: "force_reset")
        recoveryPassword       = try unboxer.unbox(key: "recovery_password")
        filters                 = try unboxer.unbox(key: "filters")
    }
}


