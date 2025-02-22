import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct EnvironmentValuesKeyMacro: AccessorMacro, PeerMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingAccessorsOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
        in _: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.AccessorDeclSyntax] {
        let name = try declaration.name()

        return [
            """
            get {
                self[__Key__\(raw: name).self]
            }

            set {
                self[__Key__\(raw: name).self] = newValue
            }
            """,
        ]
    }

    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        let name = try declaration.name()
        let fallback = try declaration.initializer() ?? "nil"
        let type = try declaration.type() ?? ""
        let typeSafe = type == "" ? "" : ": \(type)"
        return [
            """
            private struct __Key__\(raw: name): EnvironmentKey {
                static let defaultValue \(raw: typeSafe) = \(raw: fallback)
            }
            """,
        ]
    }
}

public struct EnvironmentValuesProviderMacro: MemberAttributeMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
        providingAttributesFor member: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.AttributeSyntax] {
        ["@EnvironmentValuesKey"]
    }
}

extension SwiftSyntax.DeclSyntaxProtocol {
    func name() throws -> String {
        guard let variableDecl = self.as(VariableDeclSyntax.self) else {
            throw MacroError.error("not variableDecl")
        }
        guard let identifier = variableDecl.bindings.first?.pattern.as(IdentifierPatternSyntax.self) else {
            throw MacroError.error("not identifier")
        }
        let name = identifier.identifier.text
        return name
    }

    func initializer() throws -> String? {
        guard let variableDecl = self.as(VariableDeclSyntax.self) else {
            throw MacroError.error("not variableDecl")
        }
        guard let identifier = variableDecl.bindings.first?.initializer else {
            return nil
        }
        return identifier.value.description.trimmingCharacters(in: .whitespaces)
    }

    func type() throws -> String? {
        guard let variableDecl = self.as(VariableDeclSyntax.self) else {
            throw MacroError.error("not variableDecl")
        }
        guard let typeAnnotation = variableDecl.bindings.first?.typeAnnotation else {
            return nil
        }
        return typeAnnotation.type.description
    }
}

enum MacroError: Error {
    case error(String)
}

@main
struct MyMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        EnvironmentValuesKeyMacro.self,
        EnvironmentValuesProviderMacro.self,
    ]
}
