//
//  MobileConnectService.swift
//  MobileConnectSDK
//
//  Created by Andoni Dan on 09/06/16.
//  Copyright © 2016 GSMA. All rights reserved.
//

import UIKit
import Alamofire

/**
 The Mobile Connect response received in methods which do not require a presenter view controller
 - Parameter tokenModel: The data received from the Mobile Connect service. Can be nil in case an error occured.
 - Parameter error: The error which is sent in case the operatorsData is nil.
 */
public typealias MobileConnectDataResponse = (tokenModel : TokenModel?, error : NSError?) -> Void

/**
 The Mobile Connect response received in methods which require a presenter view controller
 - Parameter controller: The Mobile Connect controller which contains the web view. Should be dismissed by the developer.
 - Parameter tokenModel: The data received from the Mobile Connect service. Can be nil in case an error occured.
 - Parameter error: The error which is sent in case the operatorsData is nil.
 */
public typealias MobileConnectControllerResponse = (controller : BaseWebController?, tokenModel : TokenModel?, error : NSError?) -> Void

public class MobileConnectService: BaseMobileConnectService<TokenModel, AuthorizationModel> {
    
    let levelOfAssurance : MCLevelOfAssurance
    let clientId : String
    let authorizationURL : String
    let tokenURL : String
    
    lazy var requestConstructor : MCRequestConstructor =
    {
        return MCRequestConstructor(clientKey : self.clientKey, clientSecret: self.clientSecret, redirectURL : self.redirectURL)
    }()
    
    //MARK: init
    init(levelOfAssurance : MCLevelOfAssurance,clientId : String,
         authorizationURL : String,
         tokenURL : String,
         redirectURL : NSURL,
         clientKey : String,
         clientSecret : String)
    {
        self.levelOfAssurance = levelOfAssurance
        self.clientId = clientId
        self.authorizationURL = authorizationURL
        self.tokenURL = tokenURL
        
        super.init(redirectURL: redirectURL, clientKey: clientKey, clientSecret: clientSecret)
    }
    
    ///The constructor to be used in case a specific level of assurance is needed.
    public convenience init(levelOfAssurance : MCLevelOfAssurance,
                            clientId : String, authorizationURL : String,
                            tokenURL : String)
    {
        self.init(levelOfAssurance: levelOfAssurance, clientId: clientId, authorizationURL: authorizationURL, tokenURL:  tokenURL, redirectURL: MobileConnectSDK.getRedirectURL(), clientKey: MobileConnectSDK.getClientKey(), clientSecret: MobileConnectSDK.getClientSecret())
    }
    
    /**
        This constructor will default the levelOfAssurance to Level 2.
        - Parameter clientId: the client id received from the discovery OperatorData model
        - Parameter authorizationURL: the authorization url received from the discovery OperatorData model
        - Parameter tokenURL: the token url received from the discovery OperatorData model
    */
    public convenience init(clientId : String, authorizationURL : String, tokenURL : String)
    {
        self.init(levelOfAssurance: MCLevelOfAssurance.Level2, clientId: clientId, authorizationURL:  authorizationURL, tokenURL:  tokenURL)
    }
    
    //MARK: Main mobile connect service method
    /**
     Gets the token by presenting the loading web view Mobile Connect controller. In case a subscriber id is not provided the user will first see a page for entering his phone number.
     - Parameter controller: the controller in which the Mobile Connect should present the web view controller
     - Parameter subscriberId: the subscriber id received from the Discovery service operatorData model
     - Parameter completionHandler: the closure which will be called upon the method completion in order to pass the resultant Mobile Connect data.
     */
    public func getTokenInController(controller : UIViewController, subscriberId : String? = nil, completionHandler : MobileConnectControllerResponse)
    {
        startServiceInController(controller, withRequest: requestConstructor.authorizationRequestWithClientId(self.clientId, acreditationValue: self.levelOfAssurance, subscriberId: subscriberId, atURL: self.authorizationURL, shouldNotStartImmediately: true), completitionHandler: completionHandler)
    }
    
    //MARK: Secondary methods
    func getTokenWithCode(code : String, completionHandler : MobileConnectDataResponse)
    {
        processRequest(requestConstructor.tokenRequestAtURL(tokenURL, withCode: code), withParameters: [(code, MCErrorCode.NilCode)], inHandler: completionHandler)
    }
    
    //MARK: WebController methods
    override func didReceiveResponseFromController(webController: BaseWebController?, withRedirectModel redirectModel: AuthorizationModel?, error: NSError?)
    {
        //the server causes redirect with code parameter even after sending the token, which causes the relaunch of this method
        getTokenWithCode(redirectModel?.code ?? "") { (tokenModel, error) in
            self.controllerResponse?(controller: webController, model: tokenModel, error: error)
        }
    }
    
    //MARK: Helper
    override func startInHandler(handler: () -> Void, withParameters parameters: [(String?, MCErrorCode)], completitionHandler completionHandler: (error: NSError) -> Void)
    {
        let localParameters : [(String?, MCErrorCode)] = parameters + [(clientId, MCErrorCode.NilClientId), (authorizationURL, MCErrorCode.NilAuthorizationURL), (tokenURL, MCErrorCode.NilTokenURL)]
        
        super.startInHandler(handler, withParameters: localParameters, completitionHandler: completionHandler)
    }
}
