import UIKit

struct DiaryEntry: Codable {
    let date: Date
    let text: String
    let mood: String
    let imageData: Data?
    let tags: [String]
    let color: String?
}
class DiaryStorage {

    static let shared = DiaryStorage()
    private let key = "diary_entries"

    private init() {}

    func save(entry: DiaryEntry) {
        var entries = loadEntries()
        entries.insert(entry, at: 0)

        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func loadEntries() -> [DiaryEntry] {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let entries = try? JSONDecoder().decode([DiaryEntry].self, from: data)
        else {
            return []
        }
        return entries
    }
    
    func delete(entry: DiaryEntry) {
        var entries = loadEntries()
        entries.removeAll { $0.date == entry.date }

        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

}
