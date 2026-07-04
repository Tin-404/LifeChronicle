import SwiftUI

// MARK: - Film List View (Film Archive)

struct FilmListView: View {
    @EnvironmentObject var recordStore: RecordStore
    @State private var selectedFilm: Record?
    @State private var visibleCount = 0

    private var films: [Record] {
        recordStore.records(of: .film)
    }

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ZStack {
            MistBlueBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Title — serif large
                    Text("Film Archive")
                        .font(DesignSystem.largeTitle)
                        .foregroundColor(DesignSystem.textPrimary)
                        .tracking(2)
                        .padding(.horizontal, DesignSystem.screenPadding)

                    if films.isEmpty {
                        EmptyArchiveView(icon: "film.stack", title: "No films yet")
                    } else {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(Array(films.enumerated()), id: \.element.id) { index, film in
                                FilmArchiveCell(record: film, recordStore: recordStore)
                                    .onTapGesture {
                                        withAnimation(DesignSystem.fadeEase) {
                                            selectedFilm = film
                                        }
                                    }
                                    .opacity(index < visibleCount ? 1 : 0)
                                    .offset(y: index < visibleCount ? 0 : 20)
                                    .animation(DesignSystem.entranceSpring, value: visibleCount)
                            }
                        }
                        .padding(.horizontal, DesignSystem.screenPadding)
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationDestination(item: $selectedFilm) { record in
            FilmDetailView(record: record)
        }
        .onAppear {
            guard visibleCount == 0 else { return }
            let count = films.count
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

// MARK: - Film Archive Cell

/// Two-column square image grid cell. Each image has a 3px white inset border
/// and a 2pt gold horizontal line beneath — pure visual, no text.
struct FilmArchiveCell: View {
    let record: Record
    let recordStore: RecordStore

    @State private var isPressed = false
    @State private var hapticTrigger = 0

    var body: some View {
        VStack(spacing: 0) {
            // Square image — fills container, 3px white inset border
            Group {
                if let firstImagePath = record.images?.first,
                   let image = recordStore.loadImage(at: firstImagePath) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Rectangle()
                        .fill(DesignSystem.inputBackground)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 22))
                                .foregroundColor(DesignSystem.textSecondary.opacity(0.4))
                        )
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .clipped()
            .overlay(
                Rectangle()
                    .stroke(DesignSystem.cardBackground, lineWidth: 3)
            )

            // 2pt sky-blue horizontal line, 20pt wide, centred — mood indicator
            Rectangle()
                .fill(DesignSystem.accent)
                .frame(width: 20, height: 2)
                .padding(.top, 10)
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(DesignSystem.pressSpring, value: isPressed)
        .sensoryFeedback(.impact(weight: .light), trigger: hapticTrigger)
        .contentShape(Rectangle())
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
            if pressing { hapticTrigger += 1 }
        }, perform: {})
    }
}

#Preview {
    NavigationStack {
        FilmListView()
            .environmentObject(RecordStore())
    }
}
