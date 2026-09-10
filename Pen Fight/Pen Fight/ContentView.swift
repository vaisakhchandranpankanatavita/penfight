//
//  ContentView.swift
//  Pen Fight
//
//  Created by Sudhanshu on 17/02/26.
//
//  The app's root view. Switches between the main-menu screen and the
//  gameplay screen with a smooth cross-fade animation.
//

import SwiftUI

struct ContentView: View {

    /// Tracks whether the player has tapped "Start Game" on the menu.
    @State private var isGameStarted = false

    var body: some View {
        ZStack {
            if isGameStarted {
                // ── Active game ──
                GameView(onExit: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isGameStarted = false
                    }
                })
            } else {
                // ── Main menu ──
                MenuView {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isGameStarted = true
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
