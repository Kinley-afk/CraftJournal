import SwiftUI
import CoreData

enum EntrySort: String, CaseIterable, Identifiable {       // C3: the three sort choices
    case newest = "Newest first"
    case oldest = "Oldest first"
    case title = "A-Z"

    var id: String { rawValue }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CraftEntry.date, ascending: false)],
        animation: .default)
    private var entries: FetchedResults<CraftEntry>

    @State private var showingAddEntry = false
    @State private var searchText = ""                     // C2: what the user types in the search bar
    @State private var sortOption: EntrySort = .newest     // C3: the currently chosen sort

    var body: some View {
        NavigationStack {
            Group {
                if entries.isEmpty && searchText.isEmpty {
                    ContentUnavailableView(
                        "No Entries Yet",
                        systemImage: "camera",
                        description: Text("Tap + to photograph your first craft item.")
                    )
                } else if entries.isEmpty {                // C2: nothing matches the search
                    ContentUnavailableView.search(text: searchText)
                } else {
                    List {
                        ForEach(entries) { entry in
                            NavigationLink {
                                EntryDetailView(entry: entry)
                            } label: {
                                EntryRow(entry: entry)
                            }
                        }
                        .onDelete(perform: deleteEntries)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search by title")   // C2: adds the search bar
            .onChange(of: searchText) { _, _ in            // C2: update the filter whenever the text changes
                updateFilter()
            }
            .onChange(of: sortOption) { _, _ in            // C3: update the sort whenever the choice changes
                updateSort()
            }
            .navigationTitle("Craft Journal")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text(entries.count == 1 ? "1 entry" : "\(entries.count) entries")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Menu {                                 // C3: the sort menu
                        Picker("Sort", selection: $sortOption) {
                            ForEach(EntrySort.allCases) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                    Button {
                        showingAddEntry = true
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddEntry) {
                AddEntryView()
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }

    private func updateFilter() {                          // C2: sets the predicate on the fetch request
        if searchText.isEmpty {
            entries.nsPredicate = nil
        } else {
            entries.nsPredicate = NSPredicate(format: "title CONTAINS[cd] %@", searchText)
        }
    }

    private func updateSort() {                            // C3: sets the sort descriptors on the fetch request
        switch sortOption {
        case .newest:
            entries.nsSortDescriptors = [NSSortDescriptor(keyPath: \CraftEntry.date, ascending: false)]
        case .oldest:
            entries.nsSortDescriptors = [NSSortDescriptor(keyPath: \CraftEntry.date, ascending: true)]
        case .title:
            entries.nsSortDescriptors = [NSSortDescriptor(keyPath: \CraftEntry.title, ascending: true)]
        }
    }

    private func deleteEntries(offsets: IndexSet) {
        offsets.map { entries[$0] }.forEach(viewContext.delete)
        do {
            try viewContext.save()
        } catch {
            print("Could not delete: \(error)")
        }
    }
}

struct EntryRow: View {
    @ObservedObject var entry: CraftEntry

    var body: some View {
        HStack {
            if let data = entry.photo, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: "photo")
                    .frame(width: 60, height: 60)
                    .foregroundStyle(.secondary)
            }
            VStack(alignment: .leading) {
                Text(entry.title ?? "Untitled")
                    .font(.headline)
                Text(entry.craftType ?? "")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(entry.artisanName ?? "")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext,
                     PersistenceController.preview.container.viewContext)
}
