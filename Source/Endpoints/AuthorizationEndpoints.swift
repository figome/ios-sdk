//
//  Authorization.swift
//  Figo
//
//  Created by Christian König on 27.11.15.
//  Copyright © 2015 CodeStage. All rights reserved.
//

import Foundation


extension FigoSession {
    
    /**
     CREDENTIAL LOGIN
     
     Requests authorization with credentials. Authorization can be obtained as long
     as the user has not revoked the access granted to your application.
     
     The returned refresh token can be stored by the client for future logins, but only
     in a securely encryped store like the keychain or a SQLCipher database.
     
     - Parameter username: The figo account email address
     - Parameter password: The figo account password
     - Parameter clientID: Client ID
     - Parameter clientSecret: Client secret
     - Parameter completionHandler: Returns refresh token or error
     */
    public func loginWithUsername(username: String, password: String, clientID: String, clientSecret: String, _ completionHandler: (FigoResult<String>) -> Void) {
        self.basicAuthSecret = base64Encode(clientID, clientSecret)
        request(.LoginUser(username: username, password: password)) { response in
            let decoded: FigoResult<Authorization> = decodeObjectResponse(response)
            switch decoded {
            case .Success(let authorization):
                self.accessToken = authorization.access_token
                self.refreshToken = authorization.refresh_token
                completionHandler(.Success(authorization.refresh_token!))
                break
            case .Failure(let error):
                completionHandler(.Failure(error))
                break
            }
        }
    }
    
    /**
     EXCHANGE REFRESH TOKEN
     
     Requests new access token with refresh token. New access tokens can be obtained as long
     as the user has not revoked the access granted to your application.
     
     - Parameter refreshToken: The refresh token returned from a previous CREDENTIAL LOGIN
     - Parameter clientID: Client ID
     - Parameter clientSecret: Client secret
     - parameter completionHandler: Returns nothing or error
     */
    public func loginWithRefreshToken(refreshToken: String, clientID: String, clientSecret: String, _ completionHandler: VoidCompletionHandler) {
        self.basicAuthSecret = base64Encode(clientID, clientSecret)
        request(Endpoint.RefreshToken(token: refreshToken)) { response in
            let decoded: FigoResult<Authorization> = decodeObjectResponse(response)
            switch decoded {
            case .Success(let authorization):
                self.accessToken = authorization.access_token
                self.refreshToken = authorization.refresh_token
                completionHandler(.Success())
                break
            case .Failure(let error):
                completionHandler(.Failure(error))
                break
            }
        }
    }
    
    /**
     REVOKE TOKEN
     
     Invalidates the session's access token for simulating an expired access token.
     
     After revoking the access token, with the next API call a new one is fetched automatically if the refresh token is still valid.
     
     - Parameter completionHandler: Returns nothing or error
     */
    public func revokeAccessToken(completionHandler: VoidCompletionHandler) {
        guard let accessToken = self.accessToken else {
            completionHandler(.Failure(FigoError.NoActiveSession))
            return
        }
        request(.RevokeToken(token: accessToken)) { response in
            completionHandler(decodeVoidResponse(response))
        }
    }
    
    /**
     REVOKE TOKEN
     
     Invalidates access token and refresh token, after that CREDENTIAL LOGIN is required.
     
     You might call this **LOGOUT**.
     
     - Parameter refreshToken: The client's refresh token, defaults to the session's refresh token
     - Parameter completionHandler: Returns nothing or error
     */
    public func revokeRefreshToken(refreshToken: String, _ completionHandler: VoidCompletionHandler) {
        request(.RevokeToken(token: refreshToken)) { response in
            completionHandler(decodeVoidResponse(response))
        }
    }
    
}

