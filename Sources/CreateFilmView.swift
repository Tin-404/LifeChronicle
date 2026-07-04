import SwiftUI
import PhotosUI

struct CreateFilmView: View {
    @EnvironmentObject var recordStore: RecordStore
    @Environment(\.dismiss) private var dismiss

    @State private var content: String = ""
    @State private var selectedMood: String?
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    @State private var imageRecommendation: MoodOption?
    @FocusState private var isFocused: Bool

    @State private var isSaving = false
    @State private var showCheckmark = false
    @State private var saveHapticTrigger = 0
    @State private var isPressed = false
    @State private var showGoldBorder = false

    private let maxImages = 9
    private let gridColumns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)

    var recommendedMood: MoodOption? {
        if selectedMood != nil { return nil }
        return imageRecommendation
    }

    private var canSave: Bool {
        !selectedImages.isEmpty && !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ZStack {
            MistBlueBackground()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Image grid — sharp squares, 2px gaps
                        VStack(alignment: .leading, spacing: 10) {
                            if !selectedImages.isEmpty {
                                LazyVGrid(columns: gridColumns, spacing: 2) {
                                    ForEach(selectedImages.indices, id: \.self) { index in
                                        ZStack(alignment: .topTrailing) {
                                            Image(uiImage: selectedImages[index])
                                                .resizable()
                                                .scaledToFill()
                                                .frame(height: 100)
                                                .clipped()
                                                .contentShape(Rectangle())

                                            Button {
                                                removeImage(at: index)
                                            } label: {
                                                Image(systemName: "xmark")
                                                    .font(.system(size: 11, weight: .bold))
                                                    .foregroundColor(.white)
                                                    .padding(5)
                                                    .background(
                                                        Rectangle()
                                                            .fill(Color.black.opacity(0.5))
                                                    )
                                            }
                                            .padding(2)
                                        }
                                    }
                                }
                            }

                            // Dashed-border photo picker
                            PhotosPicker(
                                selection: $selectedItems,
                                maxSelectionCount: maxImages,
                                matching: .images
                            ) {
                                if selectedImages.isEmpty {
                                    ZStack {
                                        Rectangle()
                                            .stroke(style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
                                            .foregroundColor(DesignSystem.textSecondary.opacity(0.4))
                                            .frame(height: 120)

                                        VStack(spacing: 8) {
                                            Image(systemName: "plus")
                                                .font(.system(size: 28, weight: .thin))
                                                .foregroundColor(DesignSystem.textSecondary.opacity(0.5))
                                            Text("Add Photos")
                                                .font(.caption)
                                                .foregroundColor(DesignSystem.textSecondary.opacity(0.5))
                                                .tracking(DesignSystem.bodyTracking)
                                            Text("Up to \(maxImages)")
                                                .font(.caption2)
                                                .foregroundColor(DesignSystem.textSecondary.opacity(0.35))
                                        }
                                    }
                                } else if selectedImages.count < maxImages {
                                    HStack(spacing: 6) {
                                        Image(systemName: "plus")
                                            .font(.system(size: 13))
                                        Text("Add More (\(selectedImages.count)/\(maxImages))")
                                            .font(.caption)
                                    }
                                    .foregroundColor(DesignSystem.textSecondary)
                                }
                            }
                            .onChange(of: selectedItems) { _, newItems in
                                Task {
                                    var loaded: [UIImage] = []
                                    for item in newItems {
                                        if let data = try? await item.loadTransferable(type: Data.self),
                                           let image = UIImage(data: data) {
                                            loaded.append(image)
                                        }
                                    }
                                    selectedImages = loaded
                                    if let first = loaded.first {
                                        imageRecommendation = recommendMoodFromColor(first)
                                    }
                                }
                            }
                        }

                        // Text editor — warm paper background (#EAE8E3)
                        TextEditor(text: $content)
                            .focused($isFocused)
                            .font(DesignSystem.body)
                            .foregroundColor(DesignSystem.textBody)
                            .scrollContentBackground(.hidden)
                            .padding(20)
                            .frame(minHeight: 140, maxHeight: 200)
                            .background(DesignSystem.editorBackground)
                            .lineSpacing(DesignSystem.bodyLineSpacing)
                            .tracking(DesignSystem.bodyTracking)

                        // Mood recommendation
                        if let rec = recommendedMood {
                            MoodRecommendationHint(
                                emoji: rec.emoji,
                                label: rec.label,
                                moodColor: rec.color
                            ) {
                                selectedMood = rec.emoji
                            }
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                        // Mood selector — thin-bordered capsules
                        MoodSelector(selectedEmoji: $selectedMood)

                        Spacer(minLength: 24)
                    }
                    .padding(.horizontal, DesignSystem.screenPadding)
                    .padding(.top, 20)
                }

                // Save button
                Button {
                    guard canSave, !isSaving else { return }
                    isSaving = true
                    saveHapticTrigger += 1

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        recordStore.addFilm(
                            content: content,
                            mood: selectedMood,
                            images: selectedImages
                        )

                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            isSaving = false
                            showCheckmark = true
                        }

                        // Gold border flash on success
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showGoldBorder = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showGoldBorder = false
                            }
                        }

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                            dismiss()
                        }
                    }
                } label: {
                    ZStack {
                        if showCheckmark {
                            Image(systemName: "checkmark")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .transition(.scale.combined(with: .opacity))
                        } else {
                            Text("SAVE")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(isPressed ? DesignSystem.accent : .white)
                                .tracking(3)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: DesignSystem.buttonHeight)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.cornerRadiusButton)
                            .fill(isPressed ? Color.white : DesignSystem.accent)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.cornerRadiusButton)
                            .stroke(showGoldBorder ? DesignSystem.accent.opacity(0.6) : DesignSystem.accent,
                                    lineWidth: showGoldBorder ? 2 : 1)
                    )
                }
                .disabled(!canSave || isSaving)
                .opacity(canSave ? 1.0 : 0.4)
                .animation(DesignSystem.pressSpring, value: isPressed)
                .sensoryFeedback(.success, trigger: saveHapticTrigger)
                .contentShape(Rectangle())
                .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
                    isPressed = pressing
                }, perform: {})
                .padding(.horizontal, DesignSystem.screenPadding)
                .padding(.bottom, 12)
            }
        }
        .navigationTitle("New Film")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                isFocused = true
            }
        }
    }

    private func removeImage(at index: Int) {
        selectedImages.remove(at: index)
        selectedItems.remove(at: index)
        if selectedImages.isEmpty {
            imageRecommendation = nil
        }
    }
}

#Preview {
    NavigationStack {
        CreateFilmView()
            .environmentObject(RecordStore())
    }
}
