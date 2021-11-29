import Foundation

public enum Scope {
    case global
    case unique
}

public class DependencyRegistry {
    
    public typealias Instantiator<Service> = () -> Service
    
    static private var registrations: [String: Instantiator<Any>] = [:]
    static private var instances: [String: Any] = [:]
    
    static public func register<Service>(_ instantiator: @escaping Instantiator<Service>, tag: String? = nil) {
        remove(type: Service.self, tag: tag)
        registrations[identifier(type: Service.self, tag: tag)] = instantiator
    }
    
    static public func resolve<Service>(scope: Scope = .global, tag: String? = nil) -> Service {
        guard let instance = resolve(type: Service.self, scope: scope, tag: tag) else {
            fatalError("Required dependency: '\(Service.self)' not resolved. Ensure the service is registered. Use optional() instead of resolve() to resolve optional dependencies.")
        }
        
        return instance
    }
    
    static public func resolve<Service>(tag: String?) -> Service {
        return DependencyRegistry.resolve(scope: .global, tag: tag)
    }
    
    static public func optional<Service>(scope: Scope = .global, tag: String? = nil) -> Service? {
        resolve(type: Service.self, scope: scope, tag: tag)
    }
    
    static public func reset() {
        registrations = [:]
        instances = [:]
    }
    
    static private func resolve<Service>(type: Service.Type, scope: Scope, tag: String?) -> Service? {
        var instance: Service?
        if scope == .unique {
            instance = instantiate(type: Service.self, tag: tag)
        }
        
        if let existingInstance = instances[identifier(type: Service.self, tag: tag)] as? Service {
            instance = existingInstance
        } else {
            guard let newInstance = instantiate(type: Service.self, tag: tag) else {
                return nil
            }
            persist(type: type, instance: newInstance, tag: tag)
            instance = newInstance
        }
        
        return instance
    }
    
    static private func instantiate<Service>(type: Service.Type, tag: String?) -> Service? {
        var instance: Service?
        if let instantiator = registrations[identifier(type: type, tag: tag)] {
            if let newInstance = instantiator() as? Service {
                instances[identifier(type: type, tag: tag)] = newInstance
                instance = newInstance
            }
        }
        
        return instance
    }
    
    static private func persist<Service>(type: Service.Type, instance: Service, tag: String?) {
        instances[identifier(type: type, tag: tag)] = instance
    }
    
    static private func remove<Service>(type: Service.Type, tag: String?) {
        guard let index = instances.index(forKey: identifier(type: type, tag: tag)) else {
            return
        }
        instances.remove(at: index)
    }
    
    static private func identifier<Service>(type: Service.Type, tag: String?) -> String  {
        "\(ObjectIdentifier(Service.self).hashValue)\(tag ?? "")"
    }
}

@propertyWrapper
public struct Inject<Service> {
    private var service: Service
    public init(scope: Scope = .global, tag: String? = nil) { service = DependencyRegistry.resolve(scope: scope, tag: nil) }
    public init(tag: String?) { service = DependencyRegistry.resolve(scope: .global, tag: tag) }
    public var wrappedValue: Service {
        get { service }
    }
}

@propertyWrapper
public struct OptionalInject<Service> {
    private var service: Service?
    public init(scope: Scope = .global, tag: String? = nil) { service = DependencyRegistry.optional(scope: scope, tag: tag) }
    public init(tag: String?) { service = DependencyRegistry.optional(scope: .global, tag: tag) }
    public var wrappedValue: Service? {
        get { service }
    }
}
