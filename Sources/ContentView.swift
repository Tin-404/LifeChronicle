import SwiftUI

struct ContentView: View {
    @EnvironmentObject var recordStore: RecordStore
    @State private var showConfirmationDialog = false
    @State private var selectedCreateType: RecordType?
    @State private var cardsVisible = 0

    @Namespace private var navigationNamespace

    var body: some View {
        NavigationStack {
            ZStack {
                OldMoneyBackground()

                VStack(spacing: 0) {
                    // MARK: Header — centred brand mark
                    VStack(spacing: 4) {
                        Text("LifeChronicle")
                            .font(.system(.largeTitle, design: .serif))
                            .fontWeight(.bold)
                            .foregroundColor(DesignSystem.accent)
                            .tracking(2)

                        Text("Your private archive")
                            .font(.caption)
                            .foregroundColor(DesignSystem.textSecondary)
                            .tracking(DesignSystem.bodyTracking)
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 36)

                    // MARK: Gallery Entry Cards — horizontal bars, 78pt
                    VStack(spacing: DesignSystem.cardSpacing) {
                        // Diary
                        NavigationLink(value: "diary") {
                            GalleryEntryCard(
                                icon: "book.closed",
                                title: "Diary",
                                count: recordStore.count(of: .diary),
                                unit: "entries"
                            )
                        }
                        .buttonStyle(.plain)
                        .zoomSource(id: "diary", namespace: navigationNamespace)
                        .opacity(cardsVisible >= 1 ? 1 : 0)
                        .offset(y: cardsVisible >= 1 ? 0 : 16)

                        // Photos
                        NavigationLink(value: "photos") {
                            GalleryEntryCard(
                                icon: "photo",
                                title: "Photos",
                                count: recordStore.count(of: .photo),
                                unit: "moments"
                            )
                        }
                        .buttonStyle(.plain)
                        .zoomSource(id: "photos", namespace: navigationNamespace)
                        .opacity(cardsVisible >= 2 ? 1 : 0)
                        .offset(y: cardsVisible >= 2 ? 0 : 16)

                        // Film
                        NavigationLink(value: "film") {
                            GalleryEntryCard(
                                icon: "film",
                                title: "Film",
                                count: recordStore.count(of: .film),
                                unit: "rolls"
                            )
                        }
                        .buttonStyle(.plain)
                        .zoomSource(id: "film", namespace: navigationNamespace)
                        .opacity(cardsVisible >= 3 ? 1 : 0)
                        .offset(y: cardsVisible >= 3 ? 0 : 16)
                    }
                    .padding(.horizontal, DesignSystem.screenPadding)

                    Spacer()
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Left: Settings gear
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(DesignSystem.accent)
                    }
                }
                // Right: Create (+)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showConfirmationDialog = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 21, weight: .medium))
                            .foregroundColor(DesignSystem.accent)
                    }
                }
            }
            .confirmationDialog("Add to Archive", isPresented: $showConfirmationDialog, titleVisibility: .visible) {
                Button("New Note")  { selectedCreateType = .diary }
                Button("New Photo") { selectedCreateType = .photo }
                Button("New Film")  { selectedCreateType = .film }
                Button("Cancel", role: .cancel) {}
            }
            .navigationDestination(for: String.self) { id in
                switch id {
                case "diary":  DiaryListView().zoomDestination(sourceID: "diary", namespace: navigationNamespace)
                case "photos": PhotoListView().zoomDestination(sourceID: "photos", namespace: navigationNamespace)
                case "film":   FilmListView().zoomDestination(sourceID: "film", namespace: navigationNamespace)
                default:       EmptyView()
                }
            }
            .navigationDestination(item: $selectedCreateType) { type in
                switch type {
                case .diary: CreateDiaryView()
                case .photo: CreatePhotoView()
                case .film:  CreateFilmView()
                }
            }
        }
        .onAppear {
            guard cardsVisible == 0 else { return }
            for i in 1...3 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * DesignSystem.staggerDelay * 3) {
                    withAnimation(DesignSystem.entranceSpring) {
                        cardsVisible = i
                    }
                }
            }
        }
    }
}

// MARK: - Gallery Entry Card (Old Money horizontal bar)

/// Equal-width horizontal bar: icon + title on the left, fine gold vertical line on the right.
/// 78pt tall, 12pt gap between cards, 1px border, no shadow.
struct GalleryEntryCard: View {
    let icon: String
    let title: String
    let count: Int
    let unit: String

    @State private var isPressed = false
    @State private var hapticTrigger = 0

    var body: some View {
        HStack(spacing: 14) {
            // Left: SF Symbol icon — deep navy
            Image(systemName: icon)
                .font(.system(size: 22, weight: .regular))
                .foregroundColor(DesignSystem.accent)
                .frame(width: 28)

            // Centre: title + count subtitle
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(.headline, design: .serif))
                    .foregroundColor(DesignSystem.textPrimary)
                Text("\(count) \(unit)")
                    .font(.caption)
                    .foregroundColor(DesignSystem.textSecondary)
                    .tracking(DesignSystem.bodyTracking)
            }

            Spacer()

            // Right: fine gold vertical line (1px × 28pt)
            Rectangle()
                .fill(DesignSystem.gold)
                .frame(width: DesignSystem.goldLineWidth, height: DesignSystem.goldLineHeight)
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .frame(height: DesignSystem.cardHeight)
        .background(DesignSystem.cardBackground)
        .overlay(
            Rectangle()
                .stroke(DesignSystem.border, lineWidth: 1)
        )
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
    ContentView()
        .environmentObject(RecordStore())
}
