import XCTest

class TransactionTests: XCTestCase {
  override func setUp() {
    super.setUp()
    continueAfterFailure = false
    XCUIApplication().launch()
  }

  override func tearDown() {
    super.tearDown()
  }

  func testCreateTransactionWithoutType() {
    let app = XCUIApplication()
    let randomAmount = arc4random()
    app.navigationBars["收支記錄"].buttons["Add"].tap()
    app.textFields.containing(.staticText, identifier: "金額：").firstMatch.typeText("\(randomAmount)")
    app.navigationBars.firstMatch.buttons["Save"].tap()

    XCTAssertTrue(app.staticTexts.containing(.staticText, identifier: "$\(randomAmount)").firstMatch.exists)
  }
}
