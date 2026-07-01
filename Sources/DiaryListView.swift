import SwiftUI

struct DiaryListView: View {
    @EnvironmentObject var recordStore: RecordStore
    @State private var visibleCount = 0

    var body: some View {
        let diaryRecords = recordStore.records(of: .diary)

        ZStack {
            OldMoneyBackground()

            if diaryRecords.isEmpty {
                EmptyArchiveView(icon: "book.closed", title: "No entries yet")
            }

            List {
                ForEach(Array(diaryRecords.enumerated()), id: \.element.id) { index, record in
                    RecordRowView(record: record)
                        .contextMenu {
                            Button(role: .destructive) {
                                withAnimation(DesignSystem.fadeEase) {
                                    recordStore.deleteRecord(record)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 4, leading: DesignSystem.screenPadding, bottom: 4, trailing: DesignSystem.screenPadding))
                        .listRowBackground(Color.clear)
                        .opacity(index < visibleCount ? 1 : 0)
                        .offset(x: index < visibleCount ? 0 : -24)
                        .animation(DesignSystem.entranceSpring, value: visibleCount)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .opacity(diaryRecords.isEmpty ? 0 : 1)
        }
        .navigationTitle("Diary")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .animation(DesignSystem.fadeEase, value: recordStore.records)
        .onAppear {
            guard visibleCount == 0 else { return }
            let count = diaryRecords.count
            guard count > 0 else { return }
            for i in 0..<count {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * DesignSystem.staggerDelay) {
                    withAnimation(DesignSystem.entranceSpring) {
                        visibleCount = i + 1
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        DiaryListView()
            .environmentObject(RecordStore())
    }
}
