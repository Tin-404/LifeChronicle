import SwiftUI

struct CreateDiaryView: View {
    @EnvironmentObject var recordStore: RecordStore
    @Environment(\.dismiss) private var dismiss

    @State private var content: String = ""
    @State private var selectedMood: String?
    @FocusState private var isFocused: Bool

    @State private var isSaving = false
    @State private var showCheckmark = false
    @State private var saveHapticTrigger = 0
    @State private var isPressed = false
    @State private var showGoldBorder = false

    private var canSave: Bool {
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ZStack {
            MistBlueBackground()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Text editor — warm paper background (#EAE8E3), no border
                        TextEditor(text: $content)
                            .focused($isFocused)
                            .font(DesignSystem.body)
                            .foregroundColor(DesignSystem.textBody)
                            .scrollContentBackground(.hidden)
                            .padding(20)
                            .frame(minHeight: 220, maxHeight: 320)
                            .background(DesignSystem.editorBackground)
                            .lineSpacing(DesignSystem.bodyLineSpacing)
                            .tracking(DesignSystem.bodyTracking)

                        // Mood recommendation hint
                        if selectedMood == nil, let recommended = recommendMood(for: content) {
                            MoodRecommendationHint(
                                emoji: recommended.emoji,
                                label: recommended.label,
                                moodColor: recommended.color
                            ) {
                                selectedMood = recommended.emoji
                            }
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                        // Mood selector — thin-bordered capsule row
                        MoodSelector(selectedEmoji: $selectedMood)

                        Spacer(minLength: 24)
                    }
                    .padding(.horizontal, DesignSystem.screenPadding)
                    .padding(.top, 20)
                }

                // Save button — full-width 44pt, uppercase SAVE, navy fill
                Button {
                    guard canSave, !isSaving else { return }
                    isSaving = true
                    saveHapticTrigger += 1

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        recordStore.addDiary(content: content, mood: selectedMood)

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
        .navigationTitle("New Note")
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
        CreateDiaryView()
            .environmentObject(RecordStore())
    }
}
