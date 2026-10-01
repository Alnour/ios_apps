import XCTest

/// Launches with the seeded sample customer open and checks the detail page scrolls down to the facts.
final class CustomerDetailScrollTests: XCTestCase {
    @MainActor
    func testFactsAreReachableByScrolling() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-open-seeded"]
        app.launch()

        XCTAssertTrue(app.navigationBars["Kate Bell"].waitForExistence(timeout: 15), "seeded customer page should open")
        let factsHeader = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH[c] 'Facts'")).firstMatch
        var swipes = 0
        while !(factsHeader.exists && factsHeader.isHittable), swipes < 6 {
            app.swipeUp()
            swipes += 1
        }
        XCTAssertTrue(factsHeader.exists && factsHeader.isHittable, "Facts header should be visible after scrolling (swipes: \(swipes))")
        let budget = app.staticTexts["$50,000"].firstMatch
        XCTAssertTrue(budget.waitForExistence(timeout: 3), "a fact row should be visible")
        let shot = XCTAttachment(screenshot: app.screenshot()); shot.lifetime = .keepAlways; add(shot)
    }
}
