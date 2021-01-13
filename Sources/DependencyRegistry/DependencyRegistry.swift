import Foundation

public enum Scope {
    case global
    case unique
}

public class DependencyRegistry {
    
    public typealias Instantiator<Service> = () -> Service
    
    static private var registrations: [Int: Instantiator<Any>] = [:]
    static private var instances: [Int: Any] = [:]
    
    static public func register<Service>(instantiator: @escaping Instantiator<Service>) {
        registrations[identifier(type: Service.self)] = instantiator
    }
    
    static public func resolve<Service>(scope: Scope = .global) -> Service {
        guard let instance = resolve(type: Service.self, scope: scope) else {
            fatalError("Required dependency: '\(Service.self)' not resolved. Ensure the service is registered. Use optional() instead of resolve() to resolve optional dependencies.")
        }
        
        return instance
    }
    
    static public func optional<Service>(scope: Scope = .global) -> Service? {
        resolve(type: Service.self, scope: scope)
    }
    
    static public func reset() {
        registrations = [:]
        instances = [:]
    }
    
    static private func resolve<Service>(type: Service.Type, scope: Scope) -> Service? {
        var instance: Service?
        if scope == .unique {
            instance = instantiate(type: Service.self)
        }
        
        if let existingInstance = instances[identifier(type: Service.self)] as? Service {
            instance = existingInstance
        } else {
            guard let newInstance = instantiate(type: Service.self) else {
                return nil
            }
            persist(type: type, instance: newInstance)
            instance = newInstance
        }
        
        return instance
    }
    
    static private func instantiate<Service>(type: Service.Type) -> Service? {
        var instance: Service?
        if let instantiator = registrations[identifier(type: type)] {
            if let newInstance = instantiator() as? Service {
                instances[identifier(type: type)] = newInstance
                instance = newInstance
            }
        }
        
        return instance
    }
    
    static private func persist<Service>(type: Service.Type, instance: Service) {
        instances[identifier(type: type)] = instance
    }
    
    static private func identifier<Service>(type: Service.Type) -> Int  {
        ObjectIdentifier(Service.self).hashValue
    }
}

@propertyWrapper
public struct Inject<Service> {
    private var service: Service
    public init(scope: Scope = .global) { service = DependencyRegistry.resolve(scope: scope) }
    public var wrappedValue: Service {
        get { service }
    }
}

@propertyWrapper
public struct OptionalInject<Service> {
    private var service: Service?
    public init(scope: Scope = .global) { service = DependencyRegistry.optional(scope: scope) }
    public var wrappedValue: Service? {
        get { service }
    }
}
