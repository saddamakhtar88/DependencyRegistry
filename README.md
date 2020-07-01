# DependencyRegistry

A small yet powerful API for managing Swift based application dependencies

## Installation

### Swift Package Manager

Once you have your Swift package set up, adding the library as a dependency is as easy as adding it to the dependencies value of your Package.swift.

dependencies: [
    .package(url: "https://github.com/saddamakhtar88/DependencyRegistry.git", .upToNextMajor(from: "1.0.0"))
]

## Usage

All the APIs are exposed as static functions 


### Registering a service

This only registers a service. An instance of the service will be created on resolution.

```
// Giving a short name to the registry. (Optional)
public typealias DI = DependencyRegistry

DI.register { () -> AnalyticsService in
    AnalyticsServiceProvider() // A class confirming ot NameService
}

DI.register { () -> UserActionService in
    UserActionServiceProvider(nameService: DI.resolve())
}
```

** Note: ** Do not register an optional type.


### Resolving a service

resolve() and optional() can be used to resolve any registered service.
 
```
// Injecting  in a property
var analyticsServiceProvider: AnalyticsService = DI.resolve() // Required resolution
DI.resolve(scope: Scope.unique) // to resolve a new instance instead of a globally shared 

var userActionServiceProvider: UserActionService? = DI.optional() // Optional resolution
DI.optional(scope: Scope.unique) // to resolve a new instance instead of a globally shared

// Injecting  in a constructor
class UserViewModel {
    private let analyticsServiceProvider: AnalyticsService
    init(analyticsServiceProvider: AnalyticsService = DI.resolve()) {
        self.analyticsServiceProvider = analyticsServiceProvider
    }
}

``` 


### Resolving a service using @propertyWrapper

```
@Inject var analyticsServiceProvider: AnalyticsService // Equivalent to DI.resolve()
@Inject(scope: Scope.unique)

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

#### Functions 
```
- func register<Service>(instantiator: @escaping Instantiator<Service>)
- func resolve<Service>(scope: Scope = .global) -> Service
- func optional<Service>(scope: Scope = .global) -> Service?
- func reset()
```

#### Property Wrappers
```
@Inject
@OptionalInject
```
