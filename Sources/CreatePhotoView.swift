import SwiftUI
import PhotosUI

struct CreatePhotoView: View {
    @EnvironmentObject var recordStore: RecordStore
    @Environment(\.dismiss) private var dismiss

    @State private var content: String = ""
    @State private var selectedMood: String?
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var imageRecommendation: MoodOption?
    @FocusState private var isFocused: Bool

    @State private var isSaving = false
    @State private var showCheckmark = false
    @State private var saveHapticTrigger = 0
    @State private var isPressed = false
    @State private var showGoldBorder = false

    var recommendedMood: MoodOption? {
        if selectedMood != nil { return nil }
        return imageRecommendation
    }

    private var canSave: Bool {
        selectedImage != nil && !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ZStack {
            OldMoneyBackground()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Image preview — sharp rectangle, no rounded corners
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 260)
                                .clipped()
                        }

                        // Dashed-border photo picker
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            if selectedImage != nil {
                                HStack(spacing: 6) {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                        .font(.system(size: 13))
                                    Text("Change Photo")
                                        .font(.caption)
                                }
                                .foregroundColor(DesignSystem.textSecondary)
                            } else {
                                ZStack {
                                    Rectangle()
                                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
                                        .foregroundColor(DesignSystem.textSecondary.opacity(0.4))
                                        .frame(height: 160)

                                    VStack(spacing: 8) {
                                        Image(systemName: "plus")
                                            .font(.system(size: 28, weight: .thin))
                                            .foregroundColor(DesignSystem.textSecondary.opacity(0.5))
                                        Text("Add Photo")
                                            .font(.caption)
                                            .foregroundColor(DesignSystem.textSecondary.opacity(0.5))
                                            .tracking(DesignSystem.bodyTracking)
                                    }
                                }
                            }
                        }
                        .onChange(of: selectedItem) { _, newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self),
                                   let image = UIImage(data: data) {
                                    selectedImage = image
                                    imageRecommendation = recommendMoodFromColor(image)
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
                    guard let image = selectedImage, canSave, !isSaving else { return }
                    isSaving = true
                    saveHapticTrigger += 1

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        recordStore.addPhoto(content: content, mood: selectedMood, image: image)

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
                                .font(.system(size: 15, weight: .semibold, design: .serif))
                                .foregroundColor(isPressed ? DesignSystem.accent : .white)
                                .tracking(4)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: DesignSystem.buttonHeight)
                    .background(
                        Rectangle()
                            .fill(isPressed ? Color.white : DesignSystem.accent)
                    )
                    .overlay(
                        Rectangle()
                            .stroke(showGoldBorder ? DesignSystem.gold : DesignSystem.accent,
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
        .navigationTitle("New Photo")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                isFocused = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        CreatePhotoView()
            .environmentObject(RecordStore())
    }
}
