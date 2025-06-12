//
//  FlareStore.swift
//  flareup
//
//  Created by Dalton Silverman on 6/6/25.
//


import Foundation


struct Flare: Identifiable {
    let id = UUID()
    let statusMessage: String
    let note: String
    let recipients: [String]
}


class FlareStore: ObservableObject {
    @Published var flares: [Flare] = []
}
