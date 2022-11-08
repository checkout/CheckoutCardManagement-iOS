import XCTest
@testable import CheckoutCardManagement
@testable import CheckoutCardNetwork

final class CardManagementDesignSystemTests: XCTestCase {
    
    func testSimpleInitialiser() {
        let testFont = UIFont.monospacedDigitSystemFont(ofSize: 20, weight: .ultraLight)
        let testColor = UIColor.green.withAlphaComponent(0.123)
        
        let designSystem = CardManagementDesignSystem(font: testFont, textColor: testColor)
        XCTAssertEqual(designSystem.pinFont, testFont)
        XCTAssertEqual(designSystem.pinTextColor, testColor)
        XCTAssertEqual(designSystem.panFont, testFont)
        XCTAssertEqual(designSystem.panTextColor, testColor)
        XCTAssertEqual(designSystem.panTextSeparator, " ")
        XCTAssertEqual(designSystem.securityCodeFont, testFont)
        XCTAssertEqual(designSystem.securityCodeTextColor, testColor)
    }
    
    func testCompleteInitialiser() {
        let testFontPin = UIFont.monospacedDigitSystemFont(ofSize: 20, weight: .ultraLight)
        let testFontPan = UIFont.monospacedDigitSystemFont(ofSize: 17, weight: .ultraLight)
        let testFontCVV = UIFont.boldSystemFont(ofSize: 43)
        let testColorPin = UIColor.green.withAlphaComponent(0.123)
        let testColorPan = UIColor.orange.withAlphaComponent(0.54)
        let testColorCVV = UIColor.purple.withAlphaComponent(0.64)
        
        let designSystem = CardManagementDesignSystem(pinFont: testFontPin,
                                                      pinTextColor: testColorPin,
                                                      panFont: testFontPan,
                                                      panTextColor: testColorPan,
                                                      securityCodeFont: testFontCVV,
                                                      securityCodeTextColor: testColorCVV)
        XCTAssertEqual(designSystem.pinFont, testFontPin)
        XCTAssertEqual(designSystem.pinTextColor, testColorPin)
        XCTAssertEqual(designSystem.panFont, testFontPan)
        XCTAssertEqual(designSystem.panTextColor, testColorPan)
        XCTAssertEqual(designSystem.panTextSeparator, " ")
        XCTAssertEqual(designSystem.securityCodeFont, testFontCVV)
        XCTAssertEqual(designSystem.securityCodeTextColor, testColorCVV)
    }
    
    func testPinViewDesignOutput() {
        let testFontPin = UIFont.monospacedDigitSystemFont(ofSize: 20, weight: .ultraLight)
        let testFontPan = UIFont.monospacedDigitSystemFont(ofSize: 17, weight: .ultraLight)
        let testFontCVV = UIFont.boldSystemFont(ofSize: 43)
        let testColorPin = UIColor.green.withAlphaComponent(0.123)
        let testColorPan = UIColor.orange.withAlphaComponent(0.54)
        let testColorCVV = UIColor.purple.withAlphaComponent(0.64)
        
        let designSystem = CardManagementDesignSystem(pinFont: testFontPin,
                                                      pinTextColor: testColorPin,
                                                      panFont: testFontPan,
                                                      panTextColor: testColorPan,
                                                      securityCodeFont: testFontCVV,
                                                      securityCodeTextColor: testColorCVV)
        let pinViewDesign = designSystem.pinViewDesign
        XCTAssertEqual(pinViewDesign.font, testFontPin)
        XCTAssertEqual(pinViewDesign.textColor, testColorPin)
    }
    
    func testPanViewDesignOutput() {
        let testFontPin = UIFont.monospacedDigitSystemFont(ofSize: 20, weight: .ultraLight)
        let testFontPan = UIFont.monospacedDigitSystemFont(ofSize: 17, weight: .ultraLight)
        let testFontCVV = UIFont.boldSystemFont(ofSize: 43)
        let testColorPin = UIColor.green.withAlphaComponent(0.123)
        let testColorPan = UIColor.orange.withAlphaComponent(0.54)
        let testColorCVV = UIColor.purple.withAlphaComponent(0.64)
        let testPanSeparator = " - "
        
        var designSystem = CardManagementDesignSystem(pinFont: testFontPin,
                                                      pinTextColor: testColorPin,
                                                      panFont: testFontPan,
                                                      panTextColor: testColorPan,
                                                      securityCodeFont: testFontCVV,
                                                      securityCodeTextColor: testColorCVV)
        designSystem.panTextSeparator = testPanSeparator
        let panViewDesign = designSystem.panViewDesign
        XCTAssertEqual(panViewDesign.font, testFontPan)
        XCTAssertEqual(panViewDesign.textColor, testColorPan)
        XCTAssertEqual(panViewDesign.formatSeparator, testPanSeparator)
    }
    
    func testCVVViewDesignOutput() {
        let testFontPin = UIFont.monospacedDigitSystemFont(ofSize: 20, weight: .ultraLight)
        let testFontPan = UIFont.monospacedDigitSystemFont(ofSize: 17, weight: .ultraLight)
        let testFontCVV = UIFont.boldSystemFont(ofSize: 43)
        let testColorPin = UIColor.green.withAlphaComponent(0.123)
        let testColorPan = UIColor.orange.withAlphaComponent(0.54)
        let testColorCVV = UIColor.purple.withAlphaComponent(0.64)
        
        let designSystem = CardManagementDesignSystem(pinFont: testFontPin,
                                                      pinTextColor: testColorPin,
                                                      panFont: testFontPan,
                                                      panTextColor: testColorPan,
                                                      securityCodeFont: testFontCVV,
                                                      securityCodeTextColor: testColorCVV)
        let cvvViewDesign = designSystem.securityCodeViewDesign
        XCTAssertEqual(cvvViewDesign.font, testFontCVV)
        XCTAssertEqual(cvvViewDesign.textColor, testColorCVV)
    }
    
    func testFormattingToDictionary() {
        let testFontPin = UIFont.monospacedDigitSystemFont(ofSize: 20, weight: .ultraLight)
        let testFontPan = UIFont(name: "ZapfDingbatsITC", size: 24)!
        let testFontCVV = UIFont.boldSystemFont(ofSize: 43)
        let testColorPin = UIColor.green.withAlphaComponent(0.123)
        let testColorPan = UIColor.orange.withAlphaComponent(0.54)
        let testColorCVV = UIColor.purple.withAlphaComponent(0.64)
        
        let designSystem = CardManagementDesignSystem(pinFont: testFontPin,
                                                      pinTextColor: testColorPin,
                                                      panFont: testFontPan,
                                                      panTextColor: testColorPan,
                                                      securityCodeFont: testFontCVV,
                                                      securityCodeTextColor: testColorCVV)
        let designSerialized = try! designSystem.mapToLogDictionary()
        XCTAssertEqual(designSerialized.count, 7)
        XCTAssertEqual(designSerialized["securityCodeTextColor"]?.value as? [String: String], ["hex": "#800080A3"])
        XCTAssertEqual(designSerialized["pinTextColor"]?.value as? [String: String], ["hex": "#00FF001F"])
        XCTAssertEqual(designSerialized["panTextColor"]?.value as? [String: String], ["hex": "#FF80008A"])
        XCTAssertEqual(designSerialized["panTextSeparator"]?.value as? String, " ")
        
        let receivedPinFont = designSerialized["pinFont"]?.value as? [String: Any]
        XCTAssertEqual(receivedPinFont?["weight"] as? String, "UltraLight")
        XCTAssertEqual(receivedPinFont?["name"] as? String, ".SFUI-Ultralight")
        XCTAssertEqual(receivedPinFont?["size"] as? Int, 20)
        
        
        let receivedPanFont = designSerialized["panFont"]?.value as? [String: Any]
        XCTAssertEqual(receivedPanFont?["weight"] as? String, "Regular")
        XCTAssertEqual(receivedPanFont?["name"] as? String, "ZapfDingbatsITC")
        XCTAssertEqual(receivedPanFont?["size"] as? Int, 24)
        
        let receivedCVVFont = designSerialized["securityCodeFont"]?.value as? [String: Any]
        XCTAssertEqual(receivedCVVFont?["weight"] as? String, "Semibold")
        XCTAssertEqual(receivedCVVFont?["name"] as? String, ".SFUI-Semibold")
        XCTAssertEqual(receivedCVVFont?["size"] as? Int, 43)
    }
}
