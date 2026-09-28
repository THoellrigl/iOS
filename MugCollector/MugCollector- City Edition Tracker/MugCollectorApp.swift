import SwiftUI
import SwiftData

@main
struct MugCollectorApp: App {
    var body: some Scene {
        WindowGroup {
            MyMugsView()
        }
        // Registriert beide Models im persistenten SQLite-Speicher
        .modelContainer(for: [CupDefinition.self, UserCupItem.self])
    }
}
