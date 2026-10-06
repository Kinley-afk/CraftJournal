//
//  EntryDetailView.swift
//  CraftJournal
//
//  Created by iMac15 on 9/29/26.
//

import SwiftUI

struct EntryDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var entry: CraftEntry
    @State private var showingEdit = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if let data = entry.photo, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                Text(entry.title ?? "Untitled")
                    .font(.largeTitle)
                    .bold()
                Text(entry.craftType ?? "")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                if let name = entry.artisanName, !name.isEmpty {
                    Text("By \(name)")
                        .foregroundStyle(.secondary)
                }
                if let date = entry.date {
                    Text(date, style: .date)
                }
                if let notes = entry.notes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Notes")
                            .font(.headline)
                            .bold()
                        Text(notes)                             
                    }
                    .padding(.top, 8)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") { showingEdit = true }
            }
        }
        .sheet(isPresented: $showingEdit) {
            EditEntryView(entry: entry)
                .environment(\.managedObjectContext, viewContext)
        }
    }
}
