import Foundation

@attached(memberAttribute)
public macro EnvironmentValuesProvider()
    = #externalMacro(module: "MyMacroMacros", type: "EnvironmentValuesProviderMacro")

@attached(accessor)
@attached(peer, names: prefixed(__Key__))
public macro EnvironmentValuesKey()
    = #externalMacro(module: "MyMacroMacros", type: "EnvironmentValuesKeyMacro")
