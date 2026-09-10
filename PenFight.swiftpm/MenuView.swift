//
//  MenuView.swift
//  PenFight
//
//  Created by Sudhanshu on 01/03/26.
//

import SwiftUI

struct MenuView: View {

    /// Called when the player taps "Start Game".
    var onPlay: () -> Void

    // MARK: Animation State

    /// Drives the pulsing glow behind the Start button.
    @State private var isPulsing = false

    /// Drives the gentle vertical float of the decorative pens.
    @State private var floatOffset: CGFloat = 0

    // MARK: Body

    var body: some View {
        ZStack {

            // ── Full-screen warm gradient background ──
            LinearGradient(
                colors: [
                    Color(red: 0.42, green: 0.26, blue: 0.14),   // warm brown (top)
                    Color(red: 0.30, green: 0.17, blue: 0.08),   // deeper mid
                    Color(red: 0.18, green: 0.10, blue: 0.04),   // dark bottom
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // ── Subtle radial warmth at the centre ──
            RadialGradient(
                colors: [
                    Color(red: 0.55, green: 0.36, blue: 0.18).opacity(0.35),
                    .clear
                ],
                center: .center,
                startRadius: 40,
                endRadius: 340
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {

                Spacer()

                // ── Decorative mini-table with floating pens ──
                miniTablePreview
                    .padding(.bottom, 36)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true)) {
                            floatOffset = 8
                        }
                    }

                // ── Title block ──
                Text("PEN FIGHT")
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .kerning(3)
                    .shadow(color: .black.opacity(0.3), radius: 8, y: 3)

                Text("Classic 2-Player Tabletop Battle")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.50))
                    .padding(.top, 6)

                Spacer()

                // ── Game-details info row ──
                gameDetailsRow

                Spacer().frame(height: 28)

                // ── Start Game button with pulsing glow ──
                startButton

                Spacer().frame(height: 46)
            }
        }
        .preferredColorScheme(.dark)
    }

    // ──────────────────────────────────────────────
    // MARK: - Subviews
    // ──────────────────────────────────────────────

    /// A small decorative table with two floating pen previews.
    private var miniTablePreview: some View {
        ZStack {
            // Table shadow
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.black.opacity(0.30))
                .frame(width: 200, height: 200)
                .offset(y: 8)
                .blur(radius: 12)

            // Table rim
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(red: 0.16, green: 0.09, blue: 0.03))
                .frame(width: 204, height: 204)

            // Table surface
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.78, green: 0.58, blue: 0.34),
                            Color(red: 0.68, green: 0.48, blue: 0.26)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 190, height: 190)

            // Inner edge highlight
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                .frame(width: 184, height: 184)

            // Centre dividing line
            Rectangle()
                .fill(Color.black.opacity(0.10))
                .frame(width: 150, height: 1)

            // Blue pen (gently floating)
            penPreview(
                gradientColors: [.white, Color(red: 0.85, green: 0.90, blue: 1.0)],
                capColor: .blue,
                capOnLeading: true,
                rotation: -30,
                offset: CGPoint(x: -18, y: -28 + floatOffset * 0.4)
            )

            // Red pen (gently floating in the opposite phase)
            penPreview(
                gradientColors: [Color(red: 1, green: 0.88, blue: 0.88), .white],
                capColor: .red,
                capOnLeading: false,
                rotation: 25,
                offset: CGPoint(x: 18, y: 28 - floatOffset * 0.4)
            )
        }
    }

    /// A quick-info row showing player count, round format, and control hint.
    private var gameDetailsRow: some View {
        HStack(spacing: 0) {
            detailItem(icon: "person.2.fill", text: "2 Players")
            verticalDivider
            detailItem(icon: "trophy.fill", text: "Best of 3")
            verticalDivider
            detailItem(icon: "hand.draw.fill", text: "Drag & Shoot")
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.08))
        )
        .padding(.horizontal, 24)
    }

    /// The primary call-to-action with a pulsing blue glow behind it.
    private var startButton: some View {
        Button(action: onPlay) {
            ZStack {
                // Animated glow
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.blue.opacity(isPulsing ? 0.40 : 0.20))
                    .frame(height: 64)
                    .blur(radius: 18)

                HStack(spacing: 10) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 18, weight: .bold))
                    Text("Start Game")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 62)
                .background(
                    LinearGradient(
                        colors: [Color.blue, Color(red: 0.20, green: 0.38, blue: 0.95)],
                        startPoint: .leading, endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 28)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }

    // ──────────────────────────────────────────────
    // MARK: - Helper Views
    // ──────────────────────────────────────────────

    /// A small capsule pen preview used in the decorative table illustration.
    private func penPreview(
        gradientColors: [Color],
        capColor: Color,
        capOnLeading: Bool,
        rotation: Double,
        offset: CGPoint
    ) -> some View {
        Capsule()
            .fill(LinearGradient(colors: gradientColors,
                                 startPoint: .leading, endPoint: .trailing))
            .frame(width: 70, height: 13)
            .overlay(
                HStack {
                    if capOnLeading {
                        Circle().fill(capColor).frame(width: 13, height: 13)
                        Spacer()
                    } else {
                        Spacer()
                        Circle().fill(capColor).frame(width: 13, height: 13)
                    }
                }
            )
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
            .rotationEffect(.degrees(rotation))
            .offset(x: offset.x, y: offset.y)
    }

    /// An icon + label pair used inside the game-details info row.
    private func detailItem(icon: String, text: String) -> some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(.white.opacity(0.65))
            Text(text)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white.opacity(0.50))
        }
        .frame(maxWidth: .infinity)
    }

    /// A thin vertical line used as a separator in the info row.
    private var verticalDivider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.10))
            .frame(width: 1, height: 30)
    }
}

