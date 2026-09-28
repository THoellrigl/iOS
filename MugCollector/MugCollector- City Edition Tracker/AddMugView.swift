import SwiftUI
import SwiftData
import PhotosUI

struct AddMugView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // Stammdaten der Tasse
    @State private var title: String = ""
    @State private var country: String = ""
    @State private var countryCode: String = ""
    @State private var series: CupSeries = .beenThere
    @State private var releaseYear: String = ""
    @State private var estimatedValueText: String = ""

    // Eigene Sammlungsdaten
    @State private var purchasePriceText: String = ""
    @State private var purchaseDate: Date = Date()
    @State private var acquiredLocation: String = ""
    @State private var condition: CupCondition = .mintWithBox
    @State private var personalNotes: String = ""

    // Bild-Auswahl
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var userPhotoData: Data?

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !country.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                // 1. Foto-Bereich
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            photoPreview
                                .frame(maxHeight: 140)
                                .clipShape(RoundedRectangle(cornerRadius: 12))

                            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                                Label(userPhotoData == nil ? "Foto hinzufügen" : "Foto ändern", systemImage: "camera")
                                    .font(.subheadline)
                            }
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }

                // 2. Tassen-Details
                Section("Tassen-Details") {
                    TextField("Name / Stadt (z. B. Hawaii, Berlin)", text: $title)
                    TextField("Land (z. B. USA, Deutschland)", text: $country)
                    TextField("Ländercode (z. B. US, DE)", text: $countryCode)
                        #if os(iOS)
                        .textInputAutocapitalization(.characters)
                        #endif
                    
                    Picker("Serie", selection: $series) {
                        ForEach(CupSeries.allCases, id: \.self) { s in
                            Text(s.rawValue).tag(s)
                        }
                    }

                    TextField("Erscheinungsjahr (z. B. 2024)", text: $releaseYear)
                        #if os(iOS)
                        .keyboardType(.numberPad)
                        #endif

                    TextField("Geschätzter Marktwert (€)", text: $estimatedValueText)
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                }

                // 3. Eigener Kauf & Zustand
                Section("Dein Kauf") {
                    TextField("Kaufpreis (€)", text: $purchasePriceText)
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif

                    DatePicker("Kaufdatum", selection: $purchaseDate, displayedComponents: .date)

                    TextField("Kaufort (z. B. Store Honolulu, Flughafen)", text: $acquiredLocation)

                    Picker("Zustand", selection: $condition) {
                        ForEach(CupCondition.allCases, id: \.self) { c in
                            Text(c.rawValue).tag(c)
                        }
                    }
                }

                // 4. Notizen
                Section("Notizen") {
                    TextField("z. B. Urlaub mit der Familie, Geschenk von...", text: $personalNotes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Neue Tasse")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        saveMug()
                    }
                    .disabled(!isValid)
                    .fontWeight(.bold)
                }
            }
            .task(id: selectedPhotoItem) {
                if let selectedPhotoItem {
                    if let data = try? await selectedPhotoItem.loadTransferable(type: Data.self) {
                        userPhotoData = data
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var photoPreview: some View {
        #if canImport(UIKit)
        if let userPhotoData, let uiImage = UIImage(data: userPhotoData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
        } else {
            placeholderIcon
        }
        #elseif canImport(AppKit)
        if let userPhotoData, let nsImage = NSImage(data: userPhotoData) {
            Image(nsImage: nsImage)
                .resizable()
                .scaledToFit()
        } else {
            placeholderIcon
        }
        #else
        placeholderIcon
        #endif
    }

    private var placeholderIcon: some View {
        Image(systemName: "cup.and.saucer.fill")
            .font(.system(size: 50))
            .foregroundStyle(.teal.opacity(0.7))
            .frame(height: 100)
    }

    private func saveMug() {
        let cleanTitle = title.trimmingCharacters(in: .whitespaces)
        let cleanCountry = country.trimmingCharacters(in: .whitespaces)
        let cleanCode = countryCode.trimmingCharacters(in: .whitespaces).uppercased()

        let codePrefix = cleanCode.isEmpty ? "XX" : cleanCode
        let generatedId = "\(series.rawValue.prefix(3))-\(cleanTitle.uppercased())-\(codePrefix)"

        let estValue = Double(estimatedValueText.replacingOccurrences(of: ",", with: "."))
        let purPrice = Double(purchasePriceText.replacingOccurrences(of: ",", with: "."))
        let yearInt = Int(releaseYear)

        let cupDef = CupDefinition(
            id: generatedId,
            title: cleanTitle,
            country: cleanCountry,
            countryCode: cleanCode,
            series: series,
            releaseYear: yearInt,
            estimatedValue: estValue,
            imageURL: nil
        )
        modelContext.insert(cupDef)

        let userItem = UserCupItem(
            cupDefinition: cupDef,
            isOwned: true,
            purchasePrice: purPrice,
            purchaseDate: purchaseDate,
            condition: condition,
            acquiredLocation: acquiredLocation.isEmpty ? nil : acquiredLocation,
            personalNotes: personalNotes.isEmpty ? nil : personalNotes,
            userPhotoData: userPhotoData
        )
        modelContext.insert(userItem)

        dismiss()
    }
}
