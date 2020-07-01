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
        if let instance = resolve(type: Service.self, scope: scope) {
            return instance
        }
        
        fatalError("Required dependency: '\(Service.self)' not resolved. Ensure the service is registered. Use optional() instead of resolve() to resolve optional dependencies.")
    }
    
    static public func optional<Service>(scope: Scope = .global) -> Service? {
        resolve(type: Service.self, scope: scope)
    }
    
    static public func reset() {
        registrations = [:]
        instances = [:]
    }
    
    static private func resolve<Service>(type: Service.Type, scope: Scope) -> Service? {
        if scope == .unique {
            return instantiate(type: Service.self)
        } else {
            if let instance = instances[identifier(type: Service.self)] as? Service {
                return instance
            } else {
                guard let newInstance = instantiate(type: Service.self) else {
                    return nil
                }
                persist(type: type, instance: newInstance)
                return newInstance
            }
        }
    }
    
    static private func instantiate<Service>(type: Service.Type) -> Service? {
        if let instantiator = registrations[identifier(type: type)] {
            if let instance = instantiator() as? Service {
                instances[identifier(type: type)] = instance
                return instance
            }
        }
        
        return nil
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
        set { service =  newValue}
    }
}

@propertyWrapper
public struct OptionalInject<Service> {
    private var service: Service?
    public init(scope: Scope = .global) { service = DependencyRegistry.optional(scope: scope) }
    public var wrappedValue: Service? {
        get { service }
        set { service =  newValue}
    }
}
