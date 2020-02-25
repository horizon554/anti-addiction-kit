
#import <XCTest/XCTest.h>

@interface AntiAddictionKitSampleUITests : XCTestCase

@end

@implementation AntiAddictionKitSampleUITests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.

    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;

    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    if (@available(iOS 9.0, *)) {
        XCUIApplication *app = [[XCUIApplication alloc] init];
        [app launch];
    }
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testGuestLoginTimeAlertValid {
    if (@available(iOS 9.0, *)) {
        NSString *guestId = @"guest";
        NSInteger guestType = 0;

        XCUIApplication *app = [[XCUIApplication alloc] init];
        XCUIElementQuery *collectionViewsQuery = app.collectionViews;
        [collectionViewsQuery.staticTexts[@"初始化✅"] tap];
        [collectionViewsQuery.staticTexts[@"设置 User（id，type）"] tap];

        XCUIElement *textField1 = app.textFields[@"账号ID"];
        XCTAssertTrue(textField1.exists);
        [textField1 tap];
        [textField1 typeText:guestId];

        XCUIElement *textField2 = app.textFields[@"账号类型"];
        XCTAssertTrue(textField2.exists);
        [textField2 tap];
        [textField2 typeText:[NSString stringWithFormat:@"%ld", (long)guestType]];

        [app.buttons[@"登录"] tap];
        
        XCUIElement *authButton = app.buttons[@"去实名"];
        XCTAssertTrue([authButton waitForExistenceWithTimeout:1]);

        XCUIElement *gameButton = app.buttons[@"进入游戏"];
        XCTAssertTrue([gameButton waitForExistenceWithTimeout:1]);
        
        [gameButton tap];
    }
}

- (void)testLaunchPerformance {
    if (@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)) {
        // This measures how long it takes to launch your application.
        [self measureWithMetrics:@[XCTOSSignpostMetric.applicationLaunchMetric] block:^{
            [[[XCUIApplication alloc] init] launch];
        }];
    }
}

@end
