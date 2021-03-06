//
//  MobileConnectManagerMock.swift
//  MobileConnectSDK
//
//  Created by jenkins on 27/06/2016.
//  Copyright © 2016 GSMA. All rights reserved.
//

import UIKit

@testable import MobileConnectSDK

class MobileConnectManagerMock: MobileConnectManager {
    
    var error : NSError?
    var context : String?
    var scopes : [ProductType]?
    var bindingMessage : String?
    
    override func getTokenWithMobileConnectService(mobileConnectService: MobileConnectService, inWebController webController: BaseWebController?, withOperatorsData operatorsData: DiscoveryResponse, isAuthorization: Bool) {
        
        var mobileConnectServiceMock : MobileConnectServiceMock
        
        if let context = context, scopes = scopes
        {
            let configuration : MCAuthorizationConfiguration = MCAuthorizationConfiguration(discoveryResponse: operatorsData, context: context, bindingMessage: "bla bla", authorizationScopes: scopes, config: nil, loginHint: nil)
            
            mobileConnectServiceMock = MobileConnectServiceMock(configuration: configuration)
        }
        else
        {
            mobileConnectServiceMock = MobileConnectServiceMock(configuration: MobileConnectServiceConfiguration(discoveryResponse: operatorsData, authorizationScopes : [], loginHint: nil))
        }
        
        if let error = error
        {
            mobileConnectServiceMock.error = error
        }
        else
        {
            mobileConnectServiceMock.response = Mocker.tokenResponseModel.tokenData
        }
        
        super.getTokenWithMobileConnectService(mobileConnectServiceMock, inWebController: webController, withOperatorsData: operatorsData, isAuthorization : isAuthorization)
    }
    
    override var tokenResponseModel : (tokenModel : TokenModel?, operatorsData : DiscoveryResponse?) -> TokenResponseModel?
    {
        return { (tokenModel : TokenModel?, operatorsData : DiscoveryResponse?) -> TokenResponseModel? in
            return self.error == .None ? Mocker.tokenResponseModel : nil
        }
    }
}
