# 🖊️ Pen Fight

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20iPadOS%20%7C%20macOS-lightgrey.svg)](https://developer.apple.com/platforms/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A turn-based 2-player physics game built with **SwiftUI** and **SpriteKit** — a digital recreation of the classic classroom pen battle game. Challenge a friend and test your precision in this minimalist physics showdown.

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Gameplay](#-gameplay)
- [Core Mechanics](#-core-mechanics)
- [Architecture](#-architecture)
- [Technologies](#-technologies)
- [Setup](#️-running-the-project)
- [Project Goals](#-project-goal)
- [Author](#-author)
- [License](#-license)

---

## 🎯 Overview

Pen Fight brings the nostalgic classroom pen battle to your device with realistic physics and competitive gameplay. Two players take turns applying carefully aimed impulses to their pens, trying to knock the opponent out of the arena while keeping their own pen in play. Every hit matters — where and how you strike determines the outcome.

---

## 🎮 Gameplay

### Basic Rules

| Rule | Description |
|------|-------------|
| **Players** | 2 Players (Blue vs Red), turn-based competition |
| **Objective** | Push opponent's pen outside the arena boundaries |
| **Win Condition** | First player to reach **3 points** wins the match |
| **Round Reset** | Automatic repositioning after each ring-out |

### Turn System

- **Active Player** — Visual highlight indicates whose turn it is
- **Movement Lock** — No turns while pens are in motion
- **Auto Switch** — Turn passes automatically when both pens settle

### Scoring

- **+1 Point** for forcing opponent out of bounds
- **Match Victory** at 3 points with celebration overlay
- **Score Reset** for new matches

---

## ⚙️ Core Mechanics

### 🔹 Physics Engine (SpriteKit)

The game simulates realistic pen behavior using compound physics bodies with two connected components:

| Component | Properties | Purpose |
|-----------|------------|---------|
| **Main Barrel** | Optimized mass distribution, controlled surface friction, realistic angular damping | Primary body for movement and collisions |
| **Cap** | Joint-connected to barrel, secondary collision detection | Adds visual realism and affects spin |

### 🔹 Impulse System

Players control force application through intuitive touch. The impact location determines the pen's reaction:

| Hit Location | Primary Effect | Gameplay Impact |
|:------------:|:--------------:|:----------------|
| 🎯 **Center** | Linear thrust | Quick pushes, repositioning |
| ⚡ **Near Edge** | Torque + rotation | Spin attacks, tricky shots |
| 💪 **Strong Drag** | High impulse | Powerful knockback |
| 👆 **Light Tap** | Gentle nudge | Precision adjustments |

### 🔹 Collision Detection

The arena handles three types of physical interactions:

| Interaction Type | Physics Response | Gameplay Significance |
|-----------------|------------------|----------------------|
| **Pen-to-Pen** | Bounce with momentum transfer | Direct combat mechanics |
| **Pen-to-Wall** | Energy loss on impact | Strategic positioning |
| **Ring-out** | Continuous boundary monitoring | Win condition detection |

### 🔹 Arena Environment

- **Bounded rectangular playing field** with optimized dimensions
- **Calibrated surface friction** for strategic movement control
- **Clear visual boundaries** for easy ring-out judgment

---

## 🏗 Architecture

The project keeps the user interface, game logic, and physics simulation separate for better organization and maintainability.

```
Sources/
 ├── GameScene.swift      // SpriteKit physics & gameplay logic
 ├── GameState.swift      // Score and turn management
 ├── GameView.swift       // SwiftUI container for SpriteKit scene
 ├── MenuView.swift       // Start screen
 ├── ScoreCardView.swift  // Bottom score display
 ├── WinnerView.swift     // Match winner overlay
 └── Pen_FightApp.swift   // App entry point
```

### 🧩 How It Works

| What | Does What | Built With |
|------|-----------|------------|
| **Views** | Show screens to player | SwiftUI |
| **GameScene** | Handles physics, collisions, touch | SpriteKit |
| **GameState** | Tracks scores, whose turn it is | Swift |

### 🔄 Information Flow

```
Player touches screen → GameScene detects touch
GameScene applies force to pen → Physics simulates movement
GameState checks if pen went out → Updates score if needed
SwiftUI refreshes screen → Shows new score/turn
Repeat until game ends
```

### ✨ Simple Example

1. **MenuView** → Player taps "Start"
2. **GameView** appears → Blue player's turn
3. **GameScene** detects touch → Pen moves
4. **GameState** checks if Red pen fell out → Blue gets +1 point
5. **ScoreCardView** updates → Shows Blue winning

That's it! Three main parts working together:

- 🎨 **Views** = What you see
- 🎮 **GameScene** = What happens
- 📊 **GameState** = What's the score

---

## 🛠 Technologies

### Core Frameworks

| Framework | Purpose |
|:---------:|:-------:|
| **SwiftUI** | 100% declarative UI |
| **SpriteKit** | Physics simulation |
| **Combine** | Reactive state |
| **GameplayKit** | State machines |

### Development Tools

| Tool | Version |
|------|---------|
| Xcode | 15+ |
| Swift | 5.9 |
| Swift Playgrounds | iPad/Mac support |

### Key Features

- ✅ Zero external dependencies
- ✅ Full offline functionality
- ✅ Adaptive layout (iPhone / iPad / Mac)
- ✅ 60 FPS physics simulation
- ✅ Accessibility support

---

## ▶️ Running the Project

### Using Xcode

1. Open `PenFight.swiftpm` in Xcode 15 or later
2. Select an iPhone simulator
3. Press **Run**

### Using Swift Playgrounds (Mac / iPad)

1. Open the `.swiftpm` file
2. Tap **Run**

> No internet connection is required.

---

## 🎯 Project Goal

This project explores how force application affects motion and rotation in a controlled environment. It focuses on:

- Understanding impulse and torque
- Creating skill-based gameplay mechanics
- Maintaining clean architecture
- Delivering a complete interactive experience within three minutes

The aim was not to create a complex game, but a focused and technically thoughtful one.

---

## 📊 Achievement Metrics

| Metric | Target | Status |
|--------|--------|--------|
| Package Size | 📦 < 5 MB | ✅ Achieved |
| Performance | ⚡️ 60 FPS | ✅ Achieved |
| Latency | 🎯 < 100ms | ✅ Achieved |
| Platform Support | 📱 Universal | ✅ Achieved |

---

## 📊 Project Status

| Phase | Status | Timeline |
|-------|--------|----------|
| Core Mechanics | ✅ Complete | v1.0 |
| UI/UX Polish | ✅ Complete | v1.1 |
| Multiplayer | 🚧 Planning | v2.0 |
| AI Opponent | 📝 Research | Future |

---

## 👤 Author

**Sudhanshu Pratap**  
iOS Developer passionate about physics simulations and game mechanics

**Specialties:**

- 🎯 SwiftUI & UIKit Development
- 🎮 SpriteKit & Game Physics
- 🥽 ARKit & RealityKit
- 🏗 Clean Architecture & Design Patterns

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2024 Sudhanshu Pratap

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 🙏 Acknowledgments

- **Inspiration** — Classroom pen fighting games from school days
- **Physics Guidance** — Box2D and SpriteKit documentation
- **Design Inspiration** — Apple's Game Center and traditional board games

---

<div align="center">

⭐ **Star this repo if you found it useful!**

[Report Bug](../../issues) · [Request Feature](../../issues) · [Follow Author](../../)

*Last Updated: March 2026 • Swift 5.9*

</div>
