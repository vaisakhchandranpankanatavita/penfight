//
//  GameState.swift
//  Pen Fight
//
//  Created by Sudhanshu on 28/02/26.
//

import Foundation
import Combine

// MARK: - GameState
/// The single source of truth for scores, turns, and win conditions.
///
/// `GameScene` owns all turn-switching logic; this model only records
/// scores and checks for a winner.
class GameState: ObservableObject {

    // MARK: Published Properties

    /// Current score for the blue player.
    @Published var player1Score: Int = 0

    /// Current score for the red player.
    @Published var player2Score: Int = 0

    /// The winning player (1 = Blue, 2 = Red), or `nil` while the match is still in progress.
    @Published var winner: Int?

    /// Which player's turn it is right now (1 = Blue, 2 = Red).
    @Published var currentTurn: Int = 1

    // MARK: Constants

    /// Number of rounds a player must win to take the match.
    let roundsToWin = 3

    // MARK: - Scoring

    /// Awards one round to the specified player and checks for a match winner.
    ///
    /// - Parameter player: The player who scored (1 = Blue, 2 = Red).
    ///
    /// > Note: This method does **not** switch turns. Turn management is
    /// > handled exclusively by `GameScene` to avoid double-switching.
    func scorePoint(for player: Int) {
        guard winner == nil else { return }

        if player == 1 {
            player1Score += 1
        } else {
            player2Score += 1
        }

        checkForWinner()
    }

    // MARK: - Turn Management

    /// Toggles `currentTurn` between player 1 (Blue) and player 2 (Red).
    func switchTurn() {
        currentTurn = (currentTurn == 1) ? 2 : 1
    }

    // MARK: - Reset

    /// Resets all scores, clears the winner, and gives the first turn to Blue.
    func resetGame() {
        player1Score = 0
        player2Score = 0
        winner = nil
        currentTurn = 1
    }

    // MARK: - Private Helpers

    /// Sets `winner` if either player has reached `roundsToWin`.
    private func checkForWinner() {
        if player1Score >= roundsToWin {
            winner = 1
        } else if player2Score >= roundsToWin {
            winner = 2
        }
    }
}
