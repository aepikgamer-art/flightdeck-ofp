import SwiftUI
import UIKit

enum FlightDeckFontStyle: String, CaseIterable, Identifiable, Codable {
    case system = "System"
    case rounded = "Rounded"
    case serif = "Serif"
    case monospaced = "Monospaced"

    var id: String { rawValue }
    var design: Font.Design {
        switch self {
        case .system: .default
        case .rounded: .rounded
        case .serif: .serif
        case .monospaced: .monospaced
        }
    }
}

struct SavedFlightDeckTheme: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var accentHex: String
    var buttonHex: String
    var fontStyle: FlightDeckFontStyle
}

@MainActor
final class FlightDeckTheme: ObservableObject {
    @Published var accentHex: String { didSet { persist() } }
    @Published var buttonHex: String { didSet { persist() } }
    @Published var fontStyle: FlightDeckFontStyle { didSet { persist() } }
    @Published private(set) var savedThemes: [SavedFlightDeckTheme] { didSet { persistThemes() } }

    var accentColor: Color { Color(hex: accentHex) }
    var buttonColor: Color { Color(hex: buttonHex) }
    var buttonTextColor: Color {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 1
        UIColor(buttonColor).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let brightness = (red * 299 + green * 587 + blue * 114) / 1000
        return brightness > 0.58 ? .black : .white
    }

    init() {
        let defaults = UserDefaults.standard
        accentHex = defaults.string(forKey: "theme.accent") ?? "45D5F2"
        buttonHex = defaults.string(forKey: "theme.button") ?? "45D5F2"
        fontStyle = FlightDeckFontStyle(rawValue: defaults.string(forKey: "theme.font") ?? "Rounded") ?? .rounded
        if let data = defaults.data(forKey: "theme.saved"), let themes = try? JSONDecoder().decode([SavedFlightDeckTheme].self, from: data) {
            savedThemes = themes
        } else {
            savedThemes = []
        }
    }

    func setAccent(_ color: Color) { accentHex = color.hexString }
    func setButton(_ color: Color) { buttonHex = color.hexString }

    func saveTheme(named name: String) {
        let cleaned = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return }
        let theme = SavedFlightDeckTheme(name: cleaned, accentHex: accentHex, buttonHex: buttonHex, fontStyle: fontStyle)
        if let index = savedThemes.firstIndex(where: { $0.name.caseInsensitiveCompare(cleaned) == .orderedSame }) {
            savedThemes[index] = theme
        } else {
            savedThemes.append(theme)
        }
    }

    func apply(_ theme: SavedFlightDeckTheme) {
        accentHex = theme.accentHex
        buttonHex = theme.buttonHex
        fontStyle = theme.fontStyle
    }

    func delete(_ theme: SavedFlightDeckTheme) { savedThemes.removeAll { $0.id == theme.id } }

    private func persist() {
        let defaults = UserDefaults.standard
        defaults.set(accentHex, forKey: "theme.accent")
        defaults.set(buttonHex, forKey: "theme.button")
        defaults.set(fontStyle.rawValue, forKey: "theme.font")
    }

    private func persistThemes() {
        guard let data = try? JSONEncoder().encode(savedThemes) else { return }
        UserDefaults.standard.set(data, forKey: "theme.saved")
    }
}

extension Color {
    init(hex: String) {
        let value = UInt64(hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted), radix: 16) ?? 0x45D5F2
        self.init(.sRGB,
                  red: Double((value >> 16) & 0xFF) / 255,
                  green: Double((value >> 8) & 0xFF) / 255,
                  blue: Double(value & 0xFF) / 255,
                  opacity: 1)
    }

    var hexString: String {
        let color = UIColor(self)
        guard let components = color.cgColor.components, components.count >= 3 else { return "45D5F2" }
        return String(format: "%02X%02X%02X", Int(components[0] * 255), Int(components[1] * 255), Int(components[2] * 255))
    }
}

