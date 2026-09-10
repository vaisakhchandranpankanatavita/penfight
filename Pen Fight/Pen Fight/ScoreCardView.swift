//
//  ScoreCardView.swift
//  Pen Fight
//
//  A compact score-card shown at the bottom of the game screen.
//  Displays three round-indicator pips for each player and a
//  central "VS" badge with a turn-coloured dot.
//

import SwiftUI

struct ScoreCardView: View {

    /// The shared game-state used to read scores and the current turn.
    @ObservedObject var gameState: GameState

    var body: some View {
        HStack(spacing: 0) {

            // ── Blue player column ──
            playerColumn(
                label: "BLUE",
                score: gameState.player1Score,
                color: .blue,
                scoreKeyPath: \.player1Score
            )

            // ── Centre turn indicator ──
            VStack(spacing: 4) {
                Circle()
                    .fill(gameState.currentTurn == 1 ? Color.blue : Color.red)
                    .frame(width: 8, height: 8)
                    .shadow(
                        color: (gameState.currentTurn == 1 ? Color.blue : Color.red).opacity(0.5),
                        radius: 5
                    )
                    .animation(.easeInOut, value: gameState.currentTurn)

                Text("VS")
                    .font(.system(size: 9, weight: .black))
                    .foregroundStyle(Color(.tertiaryLabel))
                    .kerning(1)
            }
            .frame(width: 44)

            // ── Red player column ──
            playerColumn(
                label: "RED",
                score: gameState.player2Score,
                color: .red,
                scoreKeyPath: \.player2Score
            )
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 24)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.06), radius: 10, y: 2)
        )
        .padding(.horizontal, 28)
        .padding(.bottom, 18)
    }

    // MARK: - Helpers

    /// A column showing a player label and three round-indicator pips.
    /// Filled pips represent rounds already won.
    func playerColumn(
        label: String,
        score: Int,
        color: Color,
        scoreKeyPath: KeyPath<GameState, Int>
    ) -> some View {
        VStack(spacing: 5) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.secondary)
                .kerning(1.2)

            HStack(spacing: 6) {
                ForEach(0..<3, id: \.self) { roundIndex in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(roundIndex < score
                              ? color
                              : color.opacity(0.15))
                        .frame(width: 22, height: 8)
                        .animation(.spring(response: 0.3), value: gameState[keyPath: scoreKeyPath])
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}
