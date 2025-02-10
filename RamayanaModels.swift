import Foundation

// MARK: - Main Data Structure
struct RamayanaData: Codable {
    var kandas: [Kanda]
    
    enum CodingKeys: String, CodingKey {
        case kandas
    }
}

// MARK: - Kanda (काण्ड)
struct Kanda: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    var sargas: [Sarga]
    let colorTheme: String // Store as hex string, convert to Color in UI
    
    enum CodingKeys: String, CodingKey {
        case id = "Kanda_Number"
        case name = "Sanskrit_Name"
        case description = "Description"
        case sargas = "Sargas"
        case colorTheme = "Theme_Color"
    }
}

// MARK: - Sarga (सर्ग)
struct Sarga: Codable, Identifiable {
    let id: String
    let description: String
    let shlokaCount: Int
    var shlokas: [Shloka]
    
    enum CodingKeys: String, CodingKey {
        case id = "Sarga_Number"
        case description = "Description"
        case shlokaCount = "Sloka_Count"
        case shlokas = "Shlokas"
    }
}

// MARK: - Shloka (श्लोक)
struct Shloka: Codable, Identifiable {
    let id: String
    let sanskrit: String
    let romanTransliteration: String
    let meaning: String
    
    enum CodingKeys: String, CodingKey {
        case id = "Shloka_Number"
        case sanskrit = "Sanskrit"
        case romanTransliteration = "Roman_Transliteration"
        case meaning = "Meaning"
    }
}

// MARK: - Sample JSON Data
extension RamayanaData {
    static let sampleJSON = """
    {
        "kandas": [
            {
                "Kanda_Number": "1",
                "Sanskrit_Name": "बालकाण्ड",
                "Description": "Bāla Kāṇḍa - The Book of Youth",
                "Theme_Color": "#FFA500",
                "Sargas": [
                    {
                        "Sarga_Number": "1",
                        "Description": "First chapter of Bala Kanda",
                        "Sloka_Count": 40,
                        "Shlokas": [
                            {
                                "Shloka_Number": "1.1.1",
                                "Sanskrit": "तपःस्वाध्यायनिरतं तपस्वी वाग्विदां वरम् । नारदं परिपप्रच्छ वाल्मीकिर्मुनिपुङ्गवम् ॥",
                                "Roman_Transliteration": "tapaḥsvādhyāyaniratam tapasvī vāgvidāṃ varam । nāradaṃ paripapraccha vālmīkirmunipuṅgavam ॥",
                                "Meaning": "Vālmīki, engaged in penance and study, asked Nārada, the best among speakers and sages."
                            }
                        ]
                    }
                ]
            }
        ]
    }
    """
}

// MARK: - Data Manager
@globalActor actor RamayanaDataActor {
    static let shared = RamayanaDataActor()
}

@RamayanaDataActor
final class RamayanaDataManager: @unchecked Sendable {
    static let shared = RamayanaDataManager()
    
    private init() {}
    
    func loadData() async -> RamayanaData? {
        guard let jsonData = RamayanaData.sampleJSON.data(using: .utf8) else {
            print("Failed to convert JSON string to data")
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(RamayanaData.self, from: jsonData)
        } catch {
            print("Error decoding JSON: \(error)")
            return nil
        }
    }
    
    func loadFromFile() async -> RamayanaData? {
        guard let url = Bundle.main.url(forResource: "ramayana_data", withExtension: "json") else {
            print("JSON file not found")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode(RamayanaData.self, from: data)
        } catch {
            print("Error loading or decoding JSON: \(error)")
            return nil
        }
    }
}

// MARK: - Color Extension
import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Model
@MainActor
class RamayanaViewModel: ObservableObject {
    @Published var ramayanaData: RamayanaData?
    
    init() {
        Task {
            await loadData()
        }
    }
    
    func loadData() async {
        // Try loading from file first
        if let data = await withCheckedContinuation({ continuation in
            Task.detached {
                let manager = await RamayanaDataManager.shared
                let result = await manager.loadFromFile()
                continuation.resume(returning: result)
            }
        }) {
            self.ramayanaData = data
        } else {
            // Fall back to sample data
            if let sampleData = await withCheckedContinuation({ continuation in
                Task.detached {
                    let manager = await RamayanaDataManager.shared
                    let result = await manager.loadData()
                    continuation.resume(returning: result)
                }
            }) {
                self.ramayanaData = sampleData
            }
        }
    }
    
    func getKandaColor(_ hexString: String) -> Color {
        return Color(hex: hexString)
    }
}

// MARK: - Preview Helpers
extension RamayanaData {
    static var preview: RamayanaData {
        // Create a simple preview data
        let previewData = RamayanaData(kandas: [])
        return previewData
    }
}
