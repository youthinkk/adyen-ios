//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenDropIn
import XCTest

class PaymentMethodListComponentTests: XCTestCase {

    lazy var method1 = PaymentMethodMock(type: "test_stored_type_1", name: "test_stored_name_1")
    lazy var method2 = PaymentMethodMock(type: "test_stored_type_2", name: "test_stored_name_2")
    lazy var storedComponent = PaymentComponentMock(paymentMethod: method1)
    lazy var regularComponent = PaymentComponentMock(paymentMethod: method2)

    func testRequiresKeyboardInput() {
        let section = ComponentsSection(components: [storedComponent])
        let sectionedComponents = [section]
        let sut = PaymentMethodListComponent(apiContext: Dummy.context, components: sectionedComponents)

        let navigationViewController = DropInNavigationController(rootComponent: sut, style: NavigationStyle(), cancelHandler: { _, _ in })

        XCTAssertFalse((navigationViewController.topViewController as! WrapperViewController).requiresKeyboardInput)
    }
    
    func testLocalizationWithCustomTableName() {
        let storedSection = ComponentsSection(components: [storedComponent])
        let regularSectionHeader = ListSectionHeader(title: "title", style: ListSectionHeaderStyle())
        let regularSection = ComponentsSection(header: regularSectionHeader, components: [regularComponent])
        let sut = PaymentMethodListComponent(apiContext: Dummy.context, components: [storedSection, regularSection])
        sut.localizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)
        
        let listViewController = sut.listViewController
        XCTAssertEqual(listViewController.title, localizedString(.paymentMethodsTitle, sut.localizationParameters))
        XCTAssertEqual(listViewController.sections.count, 2)
        XCTAssertEqual(listViewController.sections[1].header?.title, "title")
    }
    
    func testLocalizationWithCustomKeySeparator() {
        let storedSection = ComponentsSection(components: [storedComponent])
        let regularSectionHeader = ListSectionHeader(title: "title", style: ListSectionHeaderStyle())
        let regularSection = ComponentsSection(header: regularSectionHeader, components: [regularComponent])
        let sut = PaymentMethodListComponent(apiContext: Dummy.context, components: [storedSection, regularSection])
        sut.localizationParameters = LocalizationParameters(tableName: "AdyenUIHostCustomSeparator", keySeparator: "_")
        
        let listViewController = sut.listViewController
        XCTAssertEqual(listViewController.title, localizedString(LocalizationKey(key: "adyen_paymentMethods_title"), sut.localizationParameters))
        XCTAssertEqual(listViewController.sections.count, 2)
        XCTAssertEqual(listViewController.sections[1].header?.title, "title")
    }

    func testStartStopLoading() {
        let section = ComponentsSection(components: [storedComponent])
        let sut = PaymentMethodListComponent(apiContext: Dummy.context, components: [section])

        let expectation = XCTestExpectation(description: "Dummy Expectation")
        UIApplication.shared.keyWindow?.rootViewController = sut.listViewController

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let cell = sut.listViewController.tableView.visibleCells[0] as! ListCell
            XCTAssertFalse(cell.showsActivityIndicator)
            sut.startLoading(for: self.storedComponent)
            XCTAssertTrue(cell.showsActivityIndicator)
            sut.stopLoadingIfNeeded()
            XCTAssertFalse(cell.showsActivityIndicator)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }
    
}
