//
//  EditEntryView.swift
//  CraftJournal
//

import SwiftUI

struct EditEntryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var entry: CraftEntry

    @State private var title: String
    @State private var craftType: String
    @State private var artisanName: String
    @State private var notes: String

    init(entry: CraftEntry) {
        self.entry = entry
        _title = State(initialValue: entry.title ?? "")
        _craftType = State(initialValue: entry.craftType ?? crafts[0])
        _artisanName = State(initialValue: entry.artisanName ?? "")
        _notes = State(initialValue: entry.notes ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                TextField("Artisan name", text: $artisanName)
                TextField("Notes", text: $notes, axis: .vertical)
                Picker("Craft", selection: $craftType) {
                    ForEach(crafts, id: \.self) { craft in
                        Text(craft)
                    }
                }
            }
            .navigationTitle("Edit Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveChanges() }
                        .disabled(title.isEmpty)
                }
            }
        }
    }

    private func saveChanges() {
        entry.title = title
        entry.craftType = craftType
        entry.artisanName = artisanName
        entry.notes = notes

        do {
            try viewContext.save()                       
            dismiss()
        } catch {
            print("Could not save changes: \(error)")
        }
    }
}
