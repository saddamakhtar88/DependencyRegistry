import XCTest
@testable import DependencyRegistry

final class DependencyRegistryTests: XCTestCase {
    func testRegistryResolutions() {
        // Setup
        DependencyRegistry.reset()
        
        // Execute and assert
        DependencyRegistry.register ({ () -> Messaging in SMSService1() })
        let messagingService: Messaging = DependencyRegistry.resolve()
        XCTAssert(messagingService is SMSService1)
        
        // Execute and assert
        DependencyRegistry.register ({ () -> Messaging in SMSService2() }, tag: "Sms2")
        let newMessagingService: Messaging = DependencyRegistry.resolve(tag: "Sms2")
        XCTAssert(newMessagingService is SMSService2)
        
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
        DependencyRegistry.register { () -> Messaging in SMSService1() }
        XCTAssert(PropertyWrappersInstances().messaging is SMSService1)
        XCTAssertNil(PropertyWrappersInstances().publisher)
        
        // Execute and assert
        DependencyRegistry.register { () -> Publisher in EventPublisher() }
        XCTAssert(PropertyWrappersInstances().publisher is EventPublisher)
    }
    
    func testResetOnReregister() {
        // Setup
        DependencyRegistry.reset()
        
        // Execute and assert
        DependencyRegistry.register { () -> Publisher in EventPublisher() }
        let publisherService: Publisher = DependencyRegistry.resolve()
        XCTAssertNotNil(publisherService)
        
        // Execute and assert
        let reResolvedPublisherService: Publisher = DependencyRegistry.resolve()
        XCTAssert(publisherService === reResolvedPublisherService)
        
        // Execute and assert
        DependencyRegistry.register { () -> Publisher in EventPublisher() }
        let reRegisteredPublisherService: Publisher = DependencyRegistry.resolve()
        XCTAssert(publisherService !== reRegisteredPublisherService)
    }
    
    func testResetAll() {
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
        ("testResetOnReregister", testResetOnReregister),
        ("testResetAll", testResetAll),
    ]
}

// MARK:- Sample types

private protocol Messaging: AnyObject {}
private class SMSService1: Messaging {}
private class SMSService2: Messaging {}

private protocol Publisher: AnyObject {}
private class EventPublisher: Publisher {}
