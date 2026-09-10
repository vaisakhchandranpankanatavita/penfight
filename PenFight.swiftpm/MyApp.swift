import SwiftUI

@main
struct PenFightApp: App {
    @State private var isPlaying = false

    var body: some Scene {
        WindowGroup {
            if isPlaying {
                GameView(onExit: { isPlaying = false })
            } else {
                MenuView(onPlay: { isPlaying = true })
            }
        }
    }
}
