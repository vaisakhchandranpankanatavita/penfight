//
//  WinnerView.swift
//  Pen Fight
//
//  A modal overlay displayed when a player wins the match.
//  Shows a trophy, the winning player's name, the final score,
//  and buttons to play again or return to the main menu.
//

import SwiftUI

struct WinnerView: View {

    /// The shared game-state, used to read the winner and final scores.
    @ObservedObject var gameState: GameState

    /// Called when the player taps "Play Again".
    var onPlayAgain: () -> Void

    /// Called when the player taps "Main Menu".
    var onExit: () -> Void

    // MARK: Convenience

    /// The accent colour for the winning player.
    var winnerColor: Color { gameState.winner == 1 ? .blue : .red }

    /// A human-readable label for the winner ("Blue" or "Red").
    var winnerName: String { gameState.winner == 1 ? "Blue" : "Red" }

    // MARK: Body

    var body: some View {
        ZStack {
            // Semi-transparent scrim behind the card
            Color.black.opacity(0.35)
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // ── Trophy icon with a soft coloured glow ──
                ZStack {
                    Circle()
                        .fill(winnerColor.opacity(0.15))
                        .frame(width: 100, height: 100)
                        .blur(radius: 20)

                    Image(systemName: "trophy.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(winnerColor)
                }
                .padding(.bottom, 18)

                // ── Winner announcement ──
                Text("\(winnerName) Wins!")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .padding(.bottom, 20)

                // ── Final score comparison ──
                HStack(spacing: 32) {
                    scoreColumn(score: gameState.player1Score, color: .blue, label: "Blue")

                    Text("–")
                        .font(.system(size: 22, weight: .thin))
                        .foregroundStyle(.secondary)

                    scoreColumn(score: gameState.player2Score, color: .red, label: "Red")
                }
                .padding(.bottom, 32)

                // ── Play Again button ──
                Button(action: onPlayAgain) {
                    Text("Play Again")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(winnerColor)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)

                // ── Main Menu link ──
                Button(action: onExit) {
                    Text("Main Menu")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                        .padding(.top, 16)
                }
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.15), radius: 30, y: 10)
            )
            .padding(28)
        }
    }

    // MARK: - Helpers

    /// A single column showing a large score number and a colour label beneath it.
    func scoreColumn(score: Int, color: Color, label: String) -> some View {
        VStack(spacing: 3) {
            Text("\(score)")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)
        }
    }
}
