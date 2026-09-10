//
//  GameView.swift
//  Pen Fight
//
//  The main gameplay screen. Hosts the SpriteKit arena, a top navigation
//  bar (close / title / reset), a score-card at the bottom, and a modal
//  winner overlay when someone takes the match.
//

import SwiftUI
import SpriteKit

struct GameView: View {

    /// Closure called when the player taps the "✕" button to leave the game.
    var onExit: () -> Void

    // MARK: State

    /// Shared model tracking scores, turns, and the winner.
    @StateObject private var gameState = GameState()

    /// The SpriteKit scene that renders the arena and handles pen physics.
    /// Created once and reused across rounds; `resetScene()` handles respawning.
    @State private var scene = GameScene()

    // MARK: Convenience

    /// The accent colour matching the current player's turn (Blue or Red).
    var turnColor: Color { gameState.currentTurn == 1 ? .blue : .red }

    // MARK: Body

    var body: some View {
        ZStack {

            // ── Background ──
            // A subtle turn-coloured gradient layered over the system grouped background.
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    turnColor.opacity(0.30),
                    turnColor.opacity(0.10),
                    .clear
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.45), value: gameState.currentTurn)

            VStack(spacing: 0) {

                // ── Navigation bar ──
                // Close button (left) · Title + turn label (centre) · Reset button (right)
                HStack {
                    Button(action: onExit) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .frame(width: 44, height: 44)   // HIG minimum touch target
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(Circle())
                    }

                    Spacer()

                    VStack(spacing: 2) {
                        Text("Pen Fight")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)

                        Text(gameState.currentTurn == 1 ? "Blue's Turn" : "Red's Turn")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(turnColor)
                            .animation(.easeInOut(duration: 0.2), value: gameState.currentTurn)
                    }

                    Spacer()

                    Button(action: resetGame) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .frame(width: 44, height: 44)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 6)

                // ── SpriteKit arena ──
                SpriteView(scene: scene, options: [.allowsTransparency])
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                // ── Score card ──
                ScoreCardView(gameState: gameState)
            }

            // ── Winner overlay ──
            // Shown with a combined fade + scale transition once a player wins.
            if gameState.winner != nil {
                WinnerView(gameState: gameState, onPlayAgain: resetGame, onExit: onExit)
                    .transition(.opacity.combined(with: .scale(scale: 0.94)))
            }
        }
        .onAppear {
            // Wire the scene up to the shared game-state model
            scene.gameState = gameState
            scene.scaleMode = .resizeFill
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.82), value: gameState.winner != nil)
    }

    // MARK: - Actions

    /// Resets both the model and the scene so the players can start a fresh match.
    func resetGame() {
        gameState.resetGame()
        scene.resetScene()
    }
}
