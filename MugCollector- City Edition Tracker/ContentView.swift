import SwiftUI
import SwiftData

struct ContentView: View {
    // Zugriff auf den Kontext zum Speichern/Löschen
    @Environment(\.modelContext) private var modelContext
    
    // Automatisch aktualisierte Liste aus SwiftData
    @Query(filter: #Predicate<UserCupItem> { $0.isOwned }, sort: \.purchaseDate, order: .reverse)
    private var myMugs: [UserCupItem]

    var body: some View {
        NavigationStack {
            List {
                if myMugs.isEmpty {
                    ContentUnavailableView(
                        "Keine Tassen vorhanden",
                        systemImage: "cup.and.saucer.fill",
                        description: Text("Füge deine erste Starbucks-Tasse hinzu.")
                    )
                } else {
                    ForEach(myMugs) { item in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.cupDefinition?.title ?? "Unbekannte Tasse")
                                    .font(.headline)
                                Text("\(item.cupDefinition?.country ?? "") • \(item.cupDefinition?.series.rawValue ?? "")")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if let price = item.purchasePrice {
                                Text(price, format: .currency(code: "EUR"))
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onDelete(perform: deleteMugs)
                }
            }
            .navigationTitle("Meine Sammlung")
            .toolbar {
                Button("Test-Tasse", systemImage: "plus") {
                    addSampleMug()
                }
            }
        }
    }

    private func addSampleMug() {
        // Beispiel-Definition anlegen
        let sampleDef = CupDefinition(
            id: "BT-BERLIN-DE",
            title: "Berlin",
            country: "Deutschland",
            countryCode: "DE",
            series: .beenThere,
            releaseYear: 2018,
            estimatedValue: 28.50
        )
        modelContext.insert(sampleDef)

        // Als Sammlungs-Eintrag speichern
        let newItem = UserCupItem(
            cupDefinition: sampleDef,
            isOwned: true,
            purchasePrice: 16.95,
            condition: .mintWithBox
        )
        modelContext.insert(newItem)
    }

    private func deleteMugs(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(myMugs[index])
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [CupDefinition.self, UserCupItem.self], inMemory: true)
}
