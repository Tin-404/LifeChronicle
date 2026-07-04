import SwiftUI

struct PhotoListView: View {
    @EnvironmentObject var recordStore: RecordStore
    @State private var visibleCount = 0

    var body: some View {
        let photoRecords = recordStore.records(of: .photo)

        ZStack {
            MistBlueBackground()

            if photoRecords.isEmpty {
                EmptyArchiveView(icon: "photo.on.rectangle.angled", title: "No photos yet")
            }

            List {
                ForEach(Array(photoRecords.enumerated()), id: \.element.id) { index, record in
                    PhotoRowView(record: record, recordStore: recordStore)
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
            .opacity(photoRecords.isEmpty ? 0 : 1)
        }
        .navigationTitle("Photos")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .animation(DesignSystem.fadeEase, value: recordStore.records)
        .onAppear {
            guard visibleCount == 0 else { return }
            let count = photoRecords.count
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

// MARK: - Photo Row View (Old Money archive card)

/// Archive-style card mirroring RecordRowView: 1px left mood line, no dividers,
/// whitespace for hierarchy, restrained press spring.
struct PhotoRowView: View {
    let record: Record
    let recordStore: RecordStore

    @State private var isPressed = false
    @State private var hapticTrigger = 0

    var body: some View {
        HStack(spacing: 0) {
            // Content area with thumbnail
            HStack(alignment: .top, spacing: 12) {
                // Thumbnail — sharp square, no rounded corners
                if let imageUrl = record.imageUrl,
                   let image = recordStore.loadImage(at: imageUrl) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 64, height: 64)
                        .clipped()
                }

                // Text + meta
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top, spacing: 8) {
                        Text(record.content)
                            .font(DesignSystem.body)
                            .foregroundColor(DesignSystem.textBody)
                            .lineSpacing(DesignSystem.bodyLineSpacing)
                            .tracking(DesignSystem.bodyTracking)
                            .lineLimit(2)

                        Spacer(minLength: 8)

                        // Mood tag — rounded, pastel fill + dark text
                        if let mood = record.mood {
                            Text(moodEnglishName(for: mood))
                                .font(.system(.caption, design: .rounded))
                                .fontWeight(.medium)
                                .foregroundColor(textColorForMood(mood))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: DesignSystem.cornerRadiusSmall)
                                        .fill(colorForMood(mood).opacity(0.5))
                                )
                        }
                    }

                    // Timestamp right-aligned
                    HStack {
                        Spacer()
                        Text(formatDateEnglish(record.createdAt))
                            .font(.caption2)
                            .foregroundColor(DesignSystem.textSecondary)
                    }
                }
            }
            .padding(.leading, 12)
            .padding(.trailing, 16)
            .padding(.vertical, 16)
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.cornerRadiusLarge)
                .fill(DesignSystem.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.cornerRadiusLarge)
                .stroke(DesignSystem.border, lineWidth: 1)
        )
        .shadow(color: DesignSystem.cardShadowColor, radius: DesignSystem.cardShadowRadius, x: 0, y: DesignSystem.cardShadowY)
        .overlay(alignment: .leading) {
            // 1px mood-coloured vertical line
            RoundedRectangle(cornerRadius: 1)
                .fill(colorForMood(record.mood))
                .frame(width: DesignSystem.moodLineWidth)
                .padding(.vertical, 12)
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
        PhotoListView()
            .environmentObject(RecordStore())
    }
}
