//
//  MugModel.swift
//  MugCollector- City Edition Tracker
//
//  Created by Thorsten Höllrigl on 25.09.26.
//
import Foundation
import SwiftData

enum CupSeries: String, Codable, CaseIterable {
    case youAreHere = "You Are Here"
    case beenThere = "Been There"
    case discoverySeries = "Discovery Series"
    case icon = "Icon Series"
    case ornament = "Ornament / Mini"
    case special = "Special / Edition"
}

enum CupCondition: String, Codable, CaseIterable {
    case mintWithBox = "Neu mit Box"
    case mintNoBox = "Neu ohne Box"
    case used = "Gebraucht"
}

@Model
final class CupDefinition {
    @Attribute(.unique) var id: String
    var title: String
    var country: String
    var countryCode: String
    var series: CupSeries
    var releaseYear: Int?
    var estimatedValue: Double?
    var imageURL: String?
    var barcode: String?
    
    // Beziehung: Eine Definition kann mehrfach in Sammlungen vorkommen (z. B. doppelt gekauft)
    @Relationship(deleteRule: .cascade, inverse: \UserCupItem.cupDefinition)
    var userItems: [UserCupItem]? = []

    init(
        id: String,
        title: String,
        country: String,
        countryCode: String,
        series: CupSeries,
        releaseYear: Int? = nil,
        estimatedValue: Double? = nil,
        imageURL: String? = nil,
        barcode: String? = nil
    ) {
        self.id = id
        self.title = title
        self.country = country
        self.countryCode = countryCode
        self.series = series
        self.releaseYear = releaseYear
        self.estimatedValue = estimatedValue
        self.imageURL = imageURL
        self.barcode = barcode
    }
}

@Model
final class UserCupItem {
    @Attribute(.unique) var id: UUID
    var isOwned: Bool                  // true = Sammlung, false = Wunschliste
    var purchasePrice: Double?
    var purchaseDate: Date?
    var acquiredLocation: String?
    var condition: CupCondition
    var personalNotes: String?
    
    @Attribute(.externalStorage)
    var userPhotoData: Data?           // Fotos werden automatisch effizient ausgelagert
    
    var cupDefinition: CupDefinition?

    init(
        cupDefinition: CupDefinition? = nil,
        isOwned: Bool = true,
        purchasePrice: Double? = nil,
        purchaseDate: Date? = Date(),
        condition: CupCondition = .mintWithBox,
        acquiredLocation: String? = nil,
        personalNotes: String? = nil,
        userPhotoData: Data? = nil
    ) {
        self.id = UUID()
        self.cupDefinition = cupDefinition
        self.isOwned = isOwned
        self.purchasePrice = purchasePrice
        self.purchaseDate = purchaseDate
        self.condition = condition
        self.acquiredLocation = acquiredLocation
        self.personalNotes = personalNotes
        self.userPhotoData = userPhotoData
    }
}
