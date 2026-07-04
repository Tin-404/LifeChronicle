import SwiftUI

// MARK: - Settings View

struct SettingsView: View {
    @AppStorage("splashText") private var splashText: String = "Ricky's World"
    @State private var showEditSheet = false
    @State private var editText: String = ""

    var body: some View {
        ZStack {
            MistBlueBackground()

            ScrollView {
                VStack(spacing: DesignSystem.spacing) {
                    // Splash Greeting section — white card + 1px grey border
                    VStack(spacing: 0) {
                        // Current value row
                        Button {
                            editText = splashText
                            withAnimation(DesignSystem.pressSpring) {
                                showEditSheet = true
                            }
                        } label: {
                            HStack(spacing: 12) {
                                Text("Splash Greeting")
                                    .font(DesignSystem.body)
                                    .foregroundColor(DesignSystem.textPrimary)
                                    .tracking(DesignSystem.bodyTracking)

                                Spacer()

                                Text(splashText)
                                    .font(DesignSystem.body)
                                    .foregroundColor(DesignSystem.textSecondary)
                                    .lineLimit(1)
                                    .truncationMode(.tail)

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(DesignSystem.textSecondary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                        }
                        .buttonStyle(.plain)

                        // Hairline divider
                        Rectangle()
                            .fill(DesignSystem.border)
                            .frame(height: 1)
                            .padding(.leading, 16)

                        // Restore default button
                        Button {
                            withAnimation(DesignSystem.pressSpring) {
                                splashText = "Ricky's World"
                            }
                        } label: {
                            HStack(spacing: 12) {
                                Text("Restore Default")
                                    .font(DesignSystem.body)
                                    .foregroundColor(DesignSystem.accent)
                                    .tracking(DesignSystem.bodyTracking)

                                Spacer()

                                Text("Ricky's World")
                                    .font(.caption)
                                    .foregroundColor(DesignSystem.textSecondary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                        }
                        .buttonStyle(.plain)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.cornerRadiusLarge)
                            .fill(DesignSystem.cardBackground)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.cornerRadiusLarge)
                            .stroke(DesignSystem.border, lineWidth: 1)
                    )
                    .shadow(color: DesignSystem.cardShadowColor, radius: DesignSystem.cardShadowRadius, x: 0, y: DesignSystem.cardShadowY)
                    .padding(.horizontal, DesignSystem.screenPadding)
                }
                .padding(.top, 16)
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .sheet(isPresented: $showEditSheet) {
            EditSplashView(splashText: $splashText, isPresented: $showEditSheet)
        }
    }
}

// MARK: - Edit Splash Text Sheet

private struct EditSplashView: View {
    @Binding var splashText: String
    @Binding var isPresented: Bool
    @State private var localText: String = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                MistBlueBackground()

                VStack(spacing: 20) {
                    // Text field — Old Money editor style
                    TextField("Enter splash text", text: $localText)
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(DesignSystem.textPrimary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: DesignSystem.cornerRadiusSmall)
                                .fill(DesignSystem.editorBackground)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.cornerRadiusSmall)
                                .stroke(isFocused ? DesignSystem.borderFocused : DesignSystem.border, lineWidth: 1)
                        )
                        .focused($isFocused)
                        .padding(.horizontal, DesignSystem.screenPadding)
                        .padding(.top, 24)

                    // Hint text
                    Text("This text will appear on the launch screen")
                        .font(.caption)
                        .foregroundColor(DesignSystem.textSecondary)
                        .tracking(DesignSystem.bodyTracking)

                    Spacer()
                }
            }
            .navigationTitle("Edit Greeting")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(DesignSystem.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        splashText = localText.trimmingCharacters(in: .whitespaces).isEmpty
                            ? "Ricky's World"
                            : localText
                        isPresented = false
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.accent)
                }
            }
            .onAppear {
                localText = splashText
                // Delay focus for smooth sheet animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isFocused = true
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
