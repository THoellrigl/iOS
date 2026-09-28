import SwiftUI
import SwiftData
import PhotosUI

struct MyMugsView: View {
    @Environment(\.modelContext) private var modelContext
    
    // Fragt alle Tassen ab, die du besitzt
    @Query(filter: #Predicate<UserCupItem> { $0.isOwned }, sort: \.purchaseDate, order: .reverse)
    private var ownedMugs: [UserCupItem]
    
    @State private var showingAddSheet = false
    
    // Zweispaltiges adaptives Raster
    private let columns = [
        GridItem(.adaptive(minimum: 165, maximum: 200), spacing: 16)
    ]
    
    // Berechnete Kennzahlen für den Header
    private var totalValue: Double {
        ownedMugs.reduce(0) { sum, item in
            sum + (item.cupDefinition?.estimatedValue ?? item.purchasePrice ?? 0.0)
        }
    }
    
    private var distinctCountriesCount: Int {
        Set(ownedMugs.compactMap { $0.cupDefinition?.countryCode }).count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 1. Kennzahlen-Header (Dashboard)
                    StatsHeaderView(
                        totalCount: ownedMugs.count,
                        countriesCount: distinctCountriesCount,
                        totalValue: totalValue
                    )
                    .padding(.horizontal)

                    // 2. Tassen-Grid
                    if ownedMugs.isEmpty {
                        ContentUnavailableView(
                            "Sammlung ist leer",
                            systemImage: "cup.and.saucer",
                            description: Text("Füge über das Plus deine erste Tasse hinzu.")
                        )
                        .padding(.top, 40)
                    } else {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(ownedMugs) { item in
                                MugCardView(item: item)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(white: 0.96))
            .navigationTitle("Meine Sammlung")
            .toolbar {
                Button {
                    showingAddSheet = true
                } label: {
                    Label("Tasse hinzufügen", systemImage: "plus")
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddMugView()
            }
        }
    }
}

// MARK: - Dashboard Header
struct StatsHeaderView: View {
    let totalCount: Int
    let countriesCount: Int
    let totalValue: Double

    var body: some View {
        HStack(spacing: 12) {
            StatCard(title: "Tassen", value: "\(totalCount)", icon: "cup.and.saucer.fill", color: .teal)
            StatCard(title: "Länder", value: "\(countriesCount)", icon: "globe.americas.fill", color: .indigo)
            StatCard(title: "Wert ca.", value: totalValue.formatted(.currency(code: "EUR")), icon: "chart.line.uptrend.xyaxis", color: .emeraldGreen)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.background)
        )
    }
}

// MARK: - Mug Card View mit Foto-Picker
struct MugCardView: View {
    @Bindable var item: UserCupItem
    @State private var selectedPhotoItem: PhotosPickerItem?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Bild-Bereich mit weichem Verlauf
            ZStack(alignment: .bottomTrailing) {
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.teal.opacity(0.12), Color.cyan.opacity(0.04)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 145)

                    // Thumbnail des Tassenbilds
                    mugImageDisplay
                        .frame(maxWidth: .infinity, maxHeight: 125)
                        .shadow(color: .black.opacity(0.10), radius: 6, x: 0, y: 4)
                        .padding(.top, 10)

                    // Serien-Badge (oben rechts)
                    Text(item.cupDefinition?.series.rawValue ?? "")
                        .font(.system(size: 9, weight: .bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(.ultraThinMaterial, in: Capsule())
                        .padding(8)
                }

                // Kamera/Bilder-Icon (unten rechts im Bildbereich)
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    Image(systemName: "camera.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                        .font(.system(size: 26))
                        .foregroundStyle(.teal)
                        .background(Circle().fill(.background))
                }
                .padding(8)
            }

            // Metadaten
            VStack(alignment: .leading, spacing: 3) {
                Text(item.cupDefinition?.title ?? "Unbenannt")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(item.cupDefinition?.country ?? "Unbekannt")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 4)

            // Fußzeile: Kaufpreis & Zustand
            HStack {
                if let price = item.purchasePrice {
                    Text(price, format: .currency(code: "EUR"))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                }
                Spacer()
                Text(item.condition.rawValue)
                    .font(.system(size: 8))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.secondary.opacity(0.15), in: RoundedRectangle(cornerRadius: 4))
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 4)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
        )
        // Aktualisiert das Foto sofort beim Auswählen
        .task(id: selectedPhotoItem) {
            if let selectedPhotoItem {
                if let data = try? await selectedPhotoItem.loadTransferable(type: Data.self) {
                    item.userPhotoData = data
                }
            }
        }
    }

    @ViewBuilder
    private var mugImageDisplay: some View {
        #if canImport(UIKit)
        if let photoData = item.userPhotoData, let uiImage = UIImage(data: photoData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
        } else if let assetImage = UIImage(named: "hawaii_yah"), item.cupDefinition?.id == "YAH-HAWAII-US" {
            Image(uiImage: assetImage)
                .resizable()
                .scaledToFit()
        } else if let urlStr = item.cupDefinition?.imageURL, let url = URL(string: urlStr) {
            AsyncImage(url: url) { img in
                img.resizable().scaledToFit()
            } placeholder: {
                ProgressView()
            }
        } else {
            placeholder
        }
        #elseif canImport(AppKit)
        if let photoData = item.userPhotoData, let nsImage = NSImage(data: photoData) {
            Image(nsImage: nsImage)
                .resizable()
                .scaledToFit()
        } else if let assetImage = NSImage(named: "hawaii_yah"), item.cupDefinition?.id == "YAH-HAWAII-US" {
            Image(nsImage: assetImage)
                .resizable()
                .scaledToFit()
        } else {
            placeholder
        }
        #else
        placeholder
        #endif
    }

    private var placeholder: some View {
        Image(systemName: "cup.and.saucer.fill")
            .resizable()
            .scaledToFit()
            .foregroundStyle(.teal.gradient)
            .padding(32)
    }
}

private extension Color {
    static let emeraldGreen = Color(red: 0.05, green: 0.65, blue: 0.45)
}

#Preview {
    MyMugsView()
        .modelContainer(for: [CupDefinition.self, UserCupItem.self], inMemory: true)
}
