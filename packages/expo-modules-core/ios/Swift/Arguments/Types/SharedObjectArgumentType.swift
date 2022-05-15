// Copyright 2022-present 650 Industries. All rights reserved.

internal struct SharedObjectArgumentType: AnyArgumentType {
  let innerType: SharedObject.Type

  func wraps<IntrinsicType>(_ type: IntrinsicType.Type) -> Bool {
    return innerType == IntrinsicType.self
  }

  func equals(_ type: AnyArgumentType) -> Bool {
    if let sharedObjectType = type as? Self {
      return sharedObjectType.innerType == innerType
    }
    return false
  }

  func cast<ArgType>(_ value: ArgType) throws -> Any {
    if let jsObject = try (value as? JavaScriptValue)?.asObject(),
       let nativeSharedObject = SharedObjectRegistry.toNativeObject(jsObject) {
      return nativeSharedObject
    }
    throw NativeSharedObjectNotFoundException()
  }

  var description: String {
    return "SharedObject<\(innerType)>"
  }
}

internal final class NativeSharedObjectNotFoundException: Exception {
  override var reason: String {
    "Unable to find the native shared object associated with given JavaScript object"
  }
}
