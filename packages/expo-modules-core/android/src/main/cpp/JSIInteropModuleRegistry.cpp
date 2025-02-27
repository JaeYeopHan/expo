// Copyright © 2021-present 650 Industries, Inc. (aka Expo)

#include "JSIInteropModuleRegistry.h"
#include "ExpoModulesHostObject.h"

#include <fbjni/detail/Meta.h>
#include <fbjni/fbjni.h>

#include <memory>

namespace jni = facebook::jni;
namespace jsi = facebook::jsi;

namespace expo {
jni::local_ref<JSIInteropModuleRegistry::jhybriddata>
JSIInteropModuleRegistry::initHybrid(jni::alias_ref<jhybridobject> jThis) {
  return makeCxxInstance(jThis);
}

void JSIInteropModuleRegistry::registerNatives() {
  registerHybrid({
                   makeNativeMethod("initHybrid", JSIInteropModuleRegistry::initHybrid),
                   makeNativeMethod("installJSI", JSIInteropModuleRegistry::installJSI)
                 });
}

JSIInteropModuleRegistry::JSIInteropModuleRegistry(jni::alias_ref<jhybridobject> jThis)
  : javaPart_(jni::make_global(jThis)) {}

void JSIInteropModuleRegistry::installJSI(
  jlong jsRuntimePointer,
  jni::alias_ref<react::CallInvokerHolder::javaobject> jsInvokerHolder,
  jni::alias_ref<react::CallInvokerHolder::javaobject> nativeInvokerHolder
) {
  auto runtime = reinterpret_cast<jsi::Runtime *>(jsRuntimePointer);
  runtimeHolder = std::make_unique<JavaScriptRuntime>(runtime);
  jsInvoker = jsInvokerHolder->cthis()->getCallInvoker();
  nativeInvoker = nativeInvokerHolder->cthis()->getCallInvoker();

  auto expoModules = std::make_shared<ExpoModulesHostObject>(this);
  auto expoModulesObject = jsi::Object::createFromHostObject(*runtime, expoModules);

  runtime
    ->global()
    .setProperty(
      *runtime,
      "ExpoModules",
      std::move(expoModulesObject)
    );
}

jni::local_ref<JavaScriptModuleObject::javaobject>
JSIInteropModuleRegistry::callGetJavaScriptModuleObjectMethod(const std::string &moduleName) const {
  const static auto method = expo::JSIInteropModuleRegistry::javaClassLocal()
    ->getMethod<jni::local_ref<JavaScriptModuleObject::javaobject>(
      std::string)>(
      "getJavaScriptModuleObject"
    );

  return method(javaPart_, moduleName);
}

jni::local_ref<JavaScriptModuleObject::javaobject>
JSIInteropModuleRegistry::getModule(const std::string &moduleName) const {
  return callGetJavaScriptModuleObjectMethod(moduleName);
}
} // namespace expo
