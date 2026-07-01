import SwiftUI

struct SplashView: View {
    let onDismiss: () -> Void

    @AppStorage("splashText") private var splashText: String = "Ricky's World"
    @State private var shimmerOffset: CGFloat = -300
    @State private var lineWidth: CGFloat = 0
    @State private var fadeOut = false
    @State private var textScale: CGFloat = 0.92
    @State private var floating = false

    var body: some View {
        ZStack {
            // 深海军蓝背景
            DesignSystem.accent
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // 主标题 — 渐变流光文字（含极细微漂浮感 ±3pt）
                shimmerText
                    .offset(y: floating ? -3 : 3)
                    .padding(.bottom, 20)

                // 金色横线 — 从中间向两边展开
                Rectangle()
                    .fill(DesignSystem.gold)
                    .frame(width: lineWidth, height: 1)
                    .opacity(lineWidth > 0 ? 1 : 0)

                Spacer()

                // 底部品牌标识
                Text("LifeChronicle")
                    .font(.system(size: 13, design: .serif))
                    .foregroundColor(.white.opacity(0.4))
                    .tracking(2)
                    .padding(.bottom, 48)
            }
        }
        .opacity(fadeOut ? 0 : 1)
        .onAppear {
            // 文字缩放入场
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                textScale = 1.0
            }

            // 极细微漂浮感 — 上下 3pt，4 秒周期
            withAnimation(
                .easeInOut(duration: 4)
                .repeatForever(autoreverses: true)
            ) {
                floating = true
            }

            // 渐变流光动画 — 3 秒一个周期，无限循环
            withAnimation(
                .easeInOut(duration: 3)
                .repeatForever(autoreverses: true)
            ) {
                shimmerOffset = 300
            }

            // 0.5 秒后金色横线从中间展开
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    lineWidth = 40
                }
            }

            // 2.5 秒后整体淡出
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 0.6)) {
                    fadeOut = true
                }
                // 淡出动画完成后通知父视图切换
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    onDismiss()
                }
            }
        }
    }

    // MARK: - Shimmer Text

    private var shimmerText: some View {
        Text(splashText)
            .font(.system(size: 36, weight: .bold, design: .serif))
            .foregroundColor(.clear)
            .scaleEffect(textScale)
            .overlay {
                // 宽渐变 overlay：金 → 银白 → 金，偏移产生流光
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: DesignSystem.gold, location: 0.0),
                        .init(color: Color(red: 229/255, green: 229/255, blue: 229/255), location: 0.5),
                        .init(color: DesignSystem.gold, location: 1.0),
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: 600)
                .offset(x: shimmerOffset)
            }
            .mask {
                Text(splashText)
                    .font(.system(size: 36, weight: .bold, design: .serif))
            }
    }
}

#Preview {
    SplashView(onDismiss: {})
}
