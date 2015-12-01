//
//  TaskEndpoints.swift
//  Figo
//
//  Created by Christian König on 28.11.15.
//  Copyright © 2015 CodeStage. All rights reserved.
//

import Foundation


extension FigoSession {
    
    private func delay(block: () -> Void) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, POLLING_INTERVAL_MSECS), dispatch_get_main_queue(), {
            block()
        })
    }
    
    /**
     POLL TASK STATE
     
     While the figo Connect server communicates with a bank server, the framework in monitoring its progress by periodically polling the task state.
     
     - Parameter parameters: PollTaskStateParameters
     - Parameter countdown: A counter utilized to implement a polling timeout
     - Parameter progressHandler: (optional) Is called periodically with a message from the server
     - Parameter pinHandler: Is called when the server needs a PIN
     - Parameter challengeHandler: Is called when the server needs a response to a challenge
     - Parameter completionHandler: Is called on completion returning nothing or error
     */
    func pollTaskState(parameters: PollTaskStateParameters, _ countdown: Int, _ progressHandler: ProgressUpdate? = nil, _ pinHandler: PinResponder?, _ challengeHandler: ChallengeResponder?, _ completionHandler: VoidCompletionHandler) {
        guard countdown > 0 else {
            completionHandler(.Failure(.TaskProcessingTimeout))
            return
        }

        request(Endpoint.PollTaskState(parameters)) { response in
            let decoded: FigoResult<TaskState> = responseUnboxed(response)
            
            switch decoded {
            case .Failure(let error):
                
                completionHandler(.Failure(error))
                break
            case .Success(let state):
                
                if let progressHandler = progressHandler {
                    progressHandler(message: state.message)
                }
                
                if state.is_ended {
                    if state.is_erroneous {
                        completionHandler(.Failure(.TaskProcessingError(accountID: state.account_id, message: state.message)))
                    } else {
                        completionHandler(.Success())
                    }
                }
                    
                else if state.is_waiting_for_pin {
                    guard let pinHandler = pinHandler else {
                        completionHandler(.Failure(FigoError.UnspecifiedError(reason: "No PinResponder")))
                        return
                    }
                    
                    let pin = pinHandler(message: state.message, accountID: state.account_id)
                    let nextParameters = PollTaskStateParameters(taskToken: parameters.taskToken, pin: pin.pin, savePin: pin.savePin)
                    self.pollTaskState(nextParameters, countdown - 1, progressHandler, pinHandler, challengeHandler, completionHandler)
                }
                    
                else if state.is_waiting_for_response {
                    guard let challengeHandler = challengeHandler else {
                        completionHandler(.Failure(FigoError.UnspecifiedError(reason: "No ChallengeResponder")))
                        return
                    }
                    guard let challenge = state.challenge else {
                        completionHandler(.Failure(FigoError.UnspecifiedError(reason: "Server is waiting for response but has not given a challenge")))
                        return
                    }
                    
                    let response = challengeHandler(message: state.message, accountID: state.account_id, challenge: challenge)
                    let nextParameters = PollTaskStateParameters(taskToken: parameters.taskToken, response: response)
                    self.pollTaskState(nextParameters, countdown - 1, progressHandler, pinHandler, challengeHandler, completionHandler)
                }
                    
                else {
                    self.delay() {
                        let nextParameters = PollTaskStateParameters(taskToken: parameters.taskToken)
                        self.pollTaskState(nextParameters, countdown - 1, progressHandler, pinHandler, challengeHandler, completionHandler)
                    }
                }
                break
            }
        }
    }
    
    
    /**
     CREATE NEW SYNCHRONIZATION TASK
     
     In order for figo to have up-to-date transaction and account information, it needs to query the bank servers, which is called synchronization. With this call you can create a new task, synchronizing all (or the specified) accounts with the state returned by the bank.
     
     - Parameter parameters: (optional) CreateSyncTaskParameters
     - Parameter progressHandler: (optional) Is called periodically with a message from the server
     - Parameter pinHandler: Is called when the server needs a PIN
     - Parameter completionHandler: Is called on completion returning nothing or error
     */
    public func synchronize(parameters: CreateSyncTaskParameters = CreateSyncTaskParameters(), progressHandler: ProgressUpdate? = nil, pinHandler: PinResponder, completionHandler: VoidCompletionHandler) {
        request(.Synchronize(parameters: parameters.JSONObject)) { response in
            
            switch decodeTaskTokenResponse(response) {
            case .Success(let taskToken):
                
                let nextParameters = PollTaskStateParameters(taskToken: taskToken)
                self.pollTaskState(nextParameters, self.POLLING_COUNTDOWN_INITIAL_VALUE, progressHandler, pinHandler, nil) { result in
                    completionHandler(result)
                }
                break
            case .Failure(let decodingError):
                
                completionHandler(.Failure(decodingError))
                break
            }
        }
    }
    
}

/**
 Parameters for the CREATE NEW SYNCHRONIZATION TASK endpoint
 */
public struct CreateSyncTaskParameters: JSONObjectConvertible {
    
    //// (optional) This flag indicates whether notifications should be sent to your application. Since your application will be notified by the callback URL anyway, you might want to disable any additional notifications.
    let disable_notifications: Bool?
    
    /// (optional) If this parameter is set, only those accounts will be synchronized, which have not been synchronized within the specified number of minutes.
    public let if_not_synced_since: Int?
    
    /// Any kind of string that will be forwarded in the callback response message. It serves two purposes: The value is used to maintain state between this request and the callback, e.g. it might contain a session ID from your application. The value should also contain a random component, which your application checks to mitigate cross-site request forgery.
    let state: String
    
    /// (optional) Automatically acknowledge and ignore any errors
    public let auto_continue: Bool?
    
    /// (optional) Only sync the accounts with these IDs
    public let account_ids: [String]?
    
    /// (optional) List of additional information to be fetched from the bank. Possible values are: standingOrders
    public let sync_tasks: [String]?

    
    public init () {
        self.init(ifNotSyncedSince: nil, autoContinue: nil, accountIDs: nil, syncTasks: nil)
    }
    
    /**
     - Parameter ifNotSyncedSince: (optional) If this parameter is set, only those accounts will be synchronized, which have not been synchronized within the specified number of minutes.
     - Parameter autoContinue: (optional) Automatically acknowledge and ignore any errors
     - Parameter accountIDs: (optional) Only sync the accounts with these IDs
     - Parameter syncTasks: (optional) List of additional information to be fetched from the bank. (Possible values are: standingOrders)
     */
    public init(ifNotSyncedSince: Int?, autoContinue: Bool?, accountIDs: [String]?, syncTasks: [String]?){
        disable_notifications = nil
        if_not_synced_since = ifNotSyncedSince
        auto_continue = autoContinue
        account_ids = accountIDs
        sync_tasks = syncTasks
        state = NSUUID().UUIDString
    }
    
    var JSONObject: [String: AnyObject] {
        var dict = Dictionary<String, AnyObject>()
        dict["disable_notifications"] = disable_notifications
        dict["if_not_synced_since"] = if_not_synced_since
        dict["state"] = state
        dict["auto_continue"] = auto_continue
        dict["account_ids"] = account_ids
        dict["sync_tasks"] = sync_tasks
        return dict
    }
}


