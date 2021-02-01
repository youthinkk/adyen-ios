//
//  AdyenWeChatTests.swift
//  AdyenWeChatTests
//
//  Created by Vladimir Abramichev on 27/01/2021.
//  Copyright © 2021 Adyen. All rights reserved.
//

import XCTest
import Adyen
@testable import AdyenActions

class AdyenWeChatTests: XCTestCase {

    let weChatActionResponse = """
    {
      "timestamp" : "x",
      "partnerid" : "x",
      "noncestr" : "x",
      "packageValue" : "Sign=WXPay",
      "sign" : "x",
      "appid" : "x",
      "prepayid" : "x"
    }
    """

    func testWeChatAction() {
        let sut = AdyenActionHandler()
        sut.clientKey = "SOME_KLIENT_KEY"

        let weChatData = try! JSONDecoder().decode(WeChatPaySDKData.self, from: weChatActionResponse.data(using: .utf8)!)
        let action = Action.sdk(.weChatPay(WeChatPaySDKAction.init(sdkData: weChatData, paymentData: "SOME_DATA") ))
        sut.perform(action)

        let waitExpectation = expectation(description: "Expect in app browser to be presented and then dismissed")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {

            XCTAssertNotNil(sut.weChatPaySDKActionComponent)
            waitExpectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)
    }

}
