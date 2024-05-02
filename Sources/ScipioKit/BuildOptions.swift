import Foundation
import OrderedCollections

struct BuildOptions: Hashable, Codable {
    init(
        buildConfiguration: BuildConfiguration,
        isDebugSymbolsEmbedded: Bool,
        frameworkType: FrameworkType,
        sdks: Set<SDK>,
        extraFlags: ExtraFlags?,
        extraBuildParameters: ExtraBuildParameters?,
        enableLibraryEvolution: Bool
    ) {
        self.buildConfiguration = buildConfiguration
        self.isDebugSymbolsEmbedded = isDebugSymbolsEmbedded
        self.frameworkType = frameworkType
        self.sdks = OrderedSet(sdks.sorted(by: { $0.rawValue < $1.rawValue }))
        self.extraFlags = extraFlags
        self.extraBuildParameters = extraBuildParameters
        self.enableLibraryEvolution = enableLibraryEvolution
    }

    let buildConfiguration: BuildConfiguration
    let isDebugSymbolsEmbedded: Bool
    let frameworkType: FrameworkType
    let sdks: OrderedSet<SDK>
    let extraFlags: ExtraFlags?
    let extraBuildParameters: ExtraBuildParameters?
    let enableLibraryEvolution: Bool
}

public struct ExtraFlags: Hashable, Codable {
    public var cFlags: [String]?
    public var cxxFlags: [String]?
    public var swiftFlags: [String]?
    public var linkerFlags: [String]?

    public init(
        cFlags: [String]? = nil,
        cxxFlags: [String]? = nil,
        swiftFlags: [String]? = nil,
        linkerFlags: [String]? = nil
    ) {
        self.cFlags = cFlags
        self.cxxFlags = cxxFlags
        self.swiftFlags = swiftFlags
        self.linkerFlags = linkerFlags
    }
}

public typealias ExtraBuildParameters = [String: String]

public enum BuildConfiguration: String, Codable {
    case debug
    case release

    var settingsValue: String {
        switch self {
        case .debug: return "Debug"
        case .release: return "Release"
        }
    }
}

public enum FrameworkType: String, Codable {
    case dynamic
    case `static`
}

public enum SDK: String, Codable, Hashable {
    case macOS
    case macCatalyst
    case iOS
    case iOSSimulator
    case tvOS
    case tvOSSimulator
    case watchOS
    case watchOSSimulator
    case visionOS
    case visionOSSimulator

    init?(platformName: String) {
        switch platformName {
        case "macos":
            self = .macOS
        case "ios":
            self = .iOS
        case "maccatalyst":
            self = .macCatalyst
        case "tvos":
            self = .tvOS
        case "watchos":
            self = .watchOS
        case "visionos":
            self = .visionOS
        default:
            return nil
        }
    }

    func extractForSimulators() -> Set<SDK> {
        switch self {
        case .macOS: return [.macOS]
        case .iOS: return [.iOS, .iOSSimulator]
        case .tvOS: return [.tvOS, .tvOSSimulator]
        case .watchOS: return [.watchOS, .watchOSSimulator]
        case .visionOS: return [.visionOS, .visionOSSimulator]
        default: return [self]
        }
    }

    var displayName: String {
        switch self {
        case .macOS:
            return "macOS"
        case .macCatalyst:
            return "Catalyst"
        case .iOS:
            return "iOS"
        case .iOSSimulator:
            return "iPhone Simulator"
        case .watchOS:
            return "watchOS"
        case .watchOSSimulator:
            return "Watch Simulator"
        case .tvOS:
            return "tvOS"
        case .tvOSSimulator:
            return "TV Simulator"
        case .visionOS:
            return "visionOS"
        case .visionOSSimulator:
            return "visionOS Simulator"
        }
    }

    var settingValue: String {
        switch self {
        case .macOS:
            return "macosx"
        case .macCatalyst:
            return "maccatalyst"
        case .iOS:
            return "iphoneos"
        case .iOSSimulator:
            return "iphonesimulator"
        case .tvOS:
            return "appletvos"
        case .tvOSSimulator:
            return "appletvsimulator"
        case .watchOS:
            return "watchos"
        case .watchOSSimulator:
            return "watchsimulator"
        case .visionOS:
            return "xros"
        case .visionOSSimulator:
            return "xrsimulator"
        }
    }

    var platformFilterValue: String {
        switch self {
        case .macOS:
            return "macos"
        case .macCatalyst:
            return "ios-maccatalyst"
        case .iOS:
            return "ios"
        case .iOSSimulator:
            return "ios-simulator"
        case .tvOS:
            return "tvos"
        case .tvOSSimulator:
            return "tvos-simulator"
        case .watchOS:
            return "watchos"
        case .watchOSSimulator:
            return "watchos-simulator"
        case .visionOS:
            return "visionos"
        case .visionOSSimulator:
            return "visionos-simulator"
        }
    }
}

extension ExtraFlags {
    func concatenating(_ otherExtraFlags: Self?) -> Self {
        func concatenating(_ key: KeyPath<Self, [String]?>) -> [String]? {
            return (self[keyPath: key] ?? []) + (otherExtraFlags?[keyPath: key] ?? [])
        }

        return .init(
            cFlags: concatenating(\.cFlags),
            cxxFlags: concatenating(\.cxxFlags),
            swiftFlags: concatenating(\.swiftFlags),
            linkerFlags: concatenating(\.linkerFlags)
        )
    }
}
