//
//  LoginManagerTests.swift
//  CkaeStoreTests
//
//  Created by JIDTP1408 on 25/03/25.
//

import XCTest

final class LoginManagerUITests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    override func tearDownWithError() throws {
        app.terminate()
    }

    // ✅ Test: Google Login Button Exists and is Tapable
    func testGoogleLoginButtonExists() throws {
        let googleButton = app.buttons["Sign in with Google"]
        XCTAssertTrue(googleButton.exists, "❌ Google Sign-In button is missing.")
        XCTAssertTrue(googleButton.isHittable, "❌ Google Sign-In button is not tappable.")
    }
    
    // ✅ Test: Google Login Flow
    func testGoogleLoginFlow() throws {
        let googleButton = app.buttons["Sign in with Google"]
        XCTAssertTrue(googleButton.exists, "❌ Google Sign-In button is missing.")
        
        googleButton.tap()
        
        // ✅ Check if web Google sign-in page appears
        let webView = app.webViews.firstMatch
        XCTAssertTrue(webView.waitForExistence(timeout: 5), "❌ Google Sign-In WebView did not appear.")
    }

    // ✅ Test: Logout Button Exists After Login
    func testLogoutButtonAfterLogin() throws {
        let googleButton = app.buttons["Sign in with Google"]
        googleButton.tap()
        
        // ✅ Wait for authentication to complete
        sleep(5)
        
        let logoutButton = app.buttons["Sign Out"]
        XCTAssertTrue(logoutButton.exists, "❌ Sign Out button did not appear after login.")
        
        logoutButton.tap()
        
        XCTAssertTrue(googleButton.exists, "❌ Google button should be visible after logout.")
    }
}
