# Dependency Registry

A small yet powerful API for managing dependencies in Swift based applications

## Installation

### Swift Package Manager

Once you have your Swift package set up, adding the library as a dependency is as easy as adding it to the dependencies value of your Package.swift.

dependencies: [
    .package(url: "https://github.com/saddamakhtar88/DependencyRegistry.git", .upToNextMajor(from: "1.0.0"))
]

## Usage

All the APIs are exposed as static functions 


### Registration

Giving a short name to the registry

```
public typealias DI = DependencyRegistry
```

Registering a concrete class against a protocol

```
DI.register { () -> AnalyticsService in
    AnalyticsServiceProvider() // A class confirming to AnalyticsService
}
```

Registering a service which requires another service

```
DI.register { () -> UserActionService in
    UserActionServiceProvider(nameService: DI.resolve())
}
```

**Note:** 
The registration API only registers a service. An instance of the service will be created lazily on resolution
Re-registering a service will remove any global instance of that service (if already available)



### Resolution
 
 Injecting  a required dependency
 
```
var analyticsServiceProvider: AnalyticsService = DI.resolve() // Required resolution

DI.resolve(scope: Scope.unique) // to resolve a new instance instead of a globally shared 
```

Injecting  an optional dependency

```
var userActionServiceProvider: UserActionService? = DI.optional() // Optional resolution

DI.optional(scope: Scope.unique) // to resolve a new instance instead of a globally shared
```

**Note:** 
The default .global scope is applicable only for reference types. A 'value' type will always be resolved to a new instance.

Injecting in a constructor

```
class UserViewModel {
    
    private let analyticsServiceProvider: AnalyticsService
    
    init(analyticsServiceProvider: AnalyticsService = DI.resolve()) {
        self.analyticsServiceProvider = analyticsServiceProvider
    }
}
``` 


### Using @propertyWrapper

```
@Inject var analyticsServiceProvider: AnalyticsService // Equivalent to DI.resolve()

@Inject(scope: Scope.unique)
```

```
@OptionalInject var userActionServiceProvider: UserActionService? // Equivalent to DI.optional()

@OptionalInject(scope: Scope.unique)
```

## Public APIs

### DependencyRegistry class

#### Enums

```
enum Scope {
    case global // default
    case unique
}
``` 

#### Typealias 

```
- Instantiator<Service> = () -> Service
```

Required by register API and internally used by resolve API to create an instance.


#### Functions 

```
- func register<Service>(instantiator: @escaping Instantiator<Service>)
```

- Registering an optional will always result in resolution to nil 
- Ensure to call register before resolving
- Reregistration for the same type will override the previous registration. Global instance if already resolved will still exist and will be resolved when requested. New registration will impact resolution for .unique scope

```
- func resolve<Service>(scope: Scope = .global) -> Service
```

- Resolves a registered type.
- Use this for non-optional dependencies
- Uses Swift's type inference to identify the type to resolve

```
- func optional<Service>(scope: Scope = .global) -> Service?
```

- Use this resolve optional dependencies

```
- func reset()
```

- Resets the registrations and service instances


#### Property Wrappers

```
@Inject
```

Equivalent to resolve() API

```
@OptionalInject
```

Equivalent to optional() API
