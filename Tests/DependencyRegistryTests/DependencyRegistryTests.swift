import XCTest
@testable import DependencyRegistry

final class DependencyRegistryTests: XCTestCase {
    func testRegistryResolutions() {
        // Setup
        DependencyRegistry.reset()
        
        // Execute and assert
        DependencyRegistry.register { () -> Messaging in SMSService() }
        let messagingService: Messaging = DependencyRegistry.resolve()
        XCTAssert(messagingService is SMSService)
        
        // Execute and assert
        let reResolvedMessagingService: Messaging = DependencyRegistry.resolve()
        XCTAssert(reResolvedMessagingService === messagingService)
        
        // Execute and assert
        let uniquelyResolvedMessagingService: Messaging = DependencyRegistry.resolve(scope: .unique)
        XCTAssert(uniquelyResolvedMessagingService !== messagingService)
        
        var publisherService: Publisher? = DependencyRegistry.optional()
        XCTAssertNil(publisherService)
        
        DependencyRegistry.register { () -> Publisher in EventPublisher() }
        
        publisherService = DependencyRegistry.optional()
        XCTAssert(publisherService is EventPublisher)
    }
    
    func testPropertyWrappers() {
        // Setup
        DependencyRegistry.reset()
        struct PropertyWrappersInstances {
            @Inject var messaging: Messaging
            @OptionalInject var publisher: Publisher?
        }
        
        // Execute and assert
        DependencyRegistry.register { () -> Messaging in SMSService() }
        XCTAssert(PropertyWrappersInstances().messaging is SMSService)
        XCTAssertNil(PropertyWrappersInstances().publisher)
        
        // Execute and assert
        DependencyRegistry.register { () -> Publisher in EventPublisher() }
        XCTAssert(PropertyWrappersInstances().publisher is EventPublisher)
    }
    
    func testReset() {
        // Setup
        DependencyRegistry.reset()
        
        // Execute and assert
        DependencyRegistry.register { () -> Publisher in EventPublisher() }
        var publisherService: Publisher? = DependencyRegistry.optional()
        XCTAssertNotNil(publisherService)
        
        // Execute and assert
        DependencyRegistry.reset()
        publisherService = DependencyRegistry.optional()
        XCTAssertNil(publisherService)
    }

    static var allTests = [
        ("testRegistryResolutions", testRegistryResolutions),
        ("testPropertyWrappers", testPropertyWrappers),
        ("testReset", testReset),
    ]
}

// MARK:- Sample types

private protocol Messaging: class {}
private class SMSService: Messaging {}

private protocol Publisher: class {}
private class EventPublisher: Publisher {}
