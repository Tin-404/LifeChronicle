import SwiftUI

struct FilmDetailView: View {
    let record: Record
    @EnvironmentObject var recordStore: RecordStore
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage: Int = 0
    @State private var isPressed = false

    var body: some View {
        ZStack {
            // Dark archive background — immersive, no chrome
            DesignSystem.darkBackground
                .ignoresSafeArea()

            if let imagePaths = record.images, !imagePaths.isEmpty {
                VStack(spacing: 0) {
                    // Swipeable images — original ratio, fade transition between pages
                    TabView(selection: $currentPage) {
                        ForEach(imagePaths.indices, id: \.self) { index in
                            if let image = recordStore.loadImage(at: imagePaths[index]) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .tag(index)
                                    .transition(.opacity)
                            } else {
                                // Graceful fallback for failed loads
                                VStack {
                                    Image(systemName: "photo")
                                        .font(.system(size: 48))
                                        .foregroundColor(DesignSystem.textSecondary)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .tag(index)
                                .transition(.opacity)
                            }
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.easeInOut(duration: 0.3), value: currentPage)

                    // Custom gold page indicator dots
                    HStack(spacing: 6) {
                        ForEach(imagePaths.indices, id: \.self) { index in
                            Circle()
                                .fill(currentPage == index
                                    ? DesignSystem.gold
                                    : DesignSystem.gold.opacity(0.25))
                                .frame(width: 6, height: 6)
                        }
                    }
                    .padding(.bottom, 48)
                }

                // Top-left close button — refined circle with press spring
                VStack {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(10)
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(isPressed ? 0.25 : 0.15))
                                )
                        }
                        .scaleEffect(isPressed ? 0.92 : 1.0)
                        .animation(DesignSystem.pressSpring, value: isPressed)
                        .contentShape(Circle())
                        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
                            isPressed = pressing
                        }, perform: {})

                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 56)

                    Spacer()
                }
            } else {
                // No images — text-only fallback
                VStack(spacing: 20) {
                    Image(systemName: "film")
                        .font(.system(size: 48))
                        .foregroundColor(colorForMood(record.mood).opacity(0.6))

                    if let mood = record.mood {
                        Text(mood)
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    }

                    Text(record.content)
                        .font(DesignSystem.body)
                        .foregroundColor(DesignSystem.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    Text(formatDateEnglish(record.createdAt))
                        .font(.caption)
                        .foregroundColor(DesignSystem.textSecondary.opacity(0.6))
                }
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        FilmDetailView(record: Record(
            type: .film,
            content: "Weekend Vlog",
            createdAt: Date(),
            mood: "🤩"
        ))
        .environmentObject(RecordStore())
    }
}
