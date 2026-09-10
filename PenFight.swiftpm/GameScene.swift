//
//  GameScene.swift
//  PenFight
//
//  Created by Sudhanshu on 01/03/26.
//

import SpriteKit
import UIKit

// MARK: - Physics Categories
struct PhysicsCategory {
    static let pen: UInt32  = 0b01
    static let wall: UInt32 = 0b10
}

// MARK: - Tuning Constants
struct GameConstants {
    // Pen dimensions
    static let penLength: CGFloat = 130
    static let penHeight: CGFloat = 18
    static let capWidth: CGFloat = 35

    // Mass & balance — cap is light, barrel is heavy (like a real pen)
    static let penMass: CGFloat = 0.22
    static let capMassRatio: CGFloat = 0.15
    static let barrelMassRatio: CGFloat = 0.85

    // Surface physics — pen travels well linearly but spin settles quickly
    static let friction: CGFloat = 0.7
    static let restitution: CGFloat = 0.45
    static let linearDamping: CGFloat = 1.2
    static let angularDamping: CGFloat = 3.0

    // Flick tuning
    static let maxDragDistance: CGFloat = 140
    static let maxImpulse: CGFloat = 32
    static let minimumDragToFlick: CGFloat = 5

    // Stopped thresholds
    static let movementThreshold: CGFloat = 3.0
    static let angularThreshold: CGFloat = 0.5

    // Chevrons
    static let chevronSpacing: CGFloat = 16
}

// MARK: - GameScene
@MainActor
class GameScene: SKScene {

    var gameState: GameState?

    private var pens: [SKNode] = []
    private var currentTurnIndex = 0
    private var arenaRect: CGRect = .zero
    private var selectedPen: SKNode?
    private var touchStartPoint: CGPoint?
    private var isTurnLocked = false
    private var isRoundOver = false
    private var chevronContainer: SKNode?
    private var groundShadow: SKShapeNode?

    // MARK: - Lifecycle

    nonisolated override func didMove(to view: SKView) {
        MainActor.assumeIsolated {
        backgroundColor = .clear
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        buildArena()
        buildTopWall()
        spawnPens()
        highlightActivePen()
        }
    }

    func resetScene() {
        spawnPens()
        highlightActivePen()
    }

    // MARK: - Arena

    private func buildArena() {
        let width = size.width * 0.95
        let height = size.height * 0.82
        let originX = (size.width - width) / 2
        let originY = (size.height - height) / 2
        arenaRect = CGRect(x: originX, y: originY, width: width, height: height)

        // Drop shadow
        let shadow = SKShapeNode(rect: arenaRect.insetBy(dx: -6, dy: -6), cornerRadius: 34)
        shadow.fillColor = UIColor.black.withAlphaComponent(0.45)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 0, y: -16)
        shadow.zPosition = -3
        addChild(shadow)

        // Mahogany rim
        let rim = SKShapeNode(rect: arenaRect.insetBy(dx: -10, dy: -10), cornerRadius: 32)
        rim.fillColor = UIColor(red: 0.14, green: 0.08, blue: 0.03, alpha: 1)
        rim.strokeColor = UIColor(red: 0.30, green: 0.16, blue: 0.06, alpha: 1)
        rim.lineWidth = 1.5
        rim.zPosition = -1
        addChild(rim)

        // Oak surface
        let surface = SKShapeNode(rect: arenaRect, cornerRadius: 20)
        surface.fillColor = UIColor(red: 0.74, green: 0.54, blue: 0.31, alpha: 1)
        surface.strokeColor = .clear
        surface.zPosition = 0
        addChild(surface)

        // Inner edge highlight
        let edgeHighlight = SKShapeNode(rect: arenaRect.insetBy(dx: 1, dy: 1), cornerRadius: 19)
        edgeHighlight.fillColor = .clear
        edgeHighlight.strokeColor = UIColor.white.withAlphaComponent(0.15)
        edgeHighlight.lineWidth = 1.5
        edgeHighlight.zPosition = 0.5
        addChild(edgeHighlight)

        // Centre line
        let centreLine = SKShapeNode()
        let linePath = CGMutablePath()
        linePath.move(to: CGPoint(x: arenaRect.minX + 24, y: arenaRect.midY))
        linePath.addLine(to: CGPoint(x: arenaRect.maxX - 24, y: arenaRect.midY))
        centreLine.path = linePath
        centreLine.strokeColor = UIColor.black.withAlphaComponent(0.12)
        centreLine.lineWidth = 1
        centreLine.zPosition = 1
        addChild(centreLine)
    }

    private func buildTopWall() {
        let wallHeight: CGFloat = 12
        let wallY = arenaRect.maxY - wallHeight

        let wallRect = CGRect(x: arenaRect.minX, y: wallY,
                              width: arenaRect.width, height: wallHeight)
        let wallShape = SKShapeNode(rect: wallRect, cornerRadius: 0)
        wallShape.fillColor = UIColor(red: 0.14, green: 0.08, blue: 0.03, alpha: 1)
        wallShape.strokeColor = .clear
        wallShape.zPosition = 2
        addChild(wallShape)

        let edgeNode = SKNode()
        edgeNode.physicsBody = SKPhysicsBody(
            edgeFrom: CGPoint(x: arenaRect.minX, y: wallY),
            to: CGPoint(x: arenaRect.maxX, y: wallY)
        )
        edgeNode.physicsBody?.categoryBitMask = PhysicsCategory.wall
        edgeNode.physicsBody?.collisionBitMask = PhysicsCategory.pen
        edgeNode.physicsBody?.restitution = 0.6
        addChild(edgeNode)
    }

    // MARK: - Pen Spawning

    private func spawnPens() {
        pens.forEach { $0.removeFromParent() }
        pens.removeAll()

        spawnSinglePen(
            at: CGPoint(x: arenaRect.midX, y: arenaRect.midY + 110),
            color: .blue, capOnLeft: true
        )
        spawnSinglePen(
            at: CGPoint(x: arenaRect.midX, y: arenaRect.midY - 110),
            color: .red, capOnLeft: false
        )

        currentTurnIndex = (gameState?.currentTurn == 1) ? 0 : 1
        isTurnLocked = false
        isRoundOver = false
    }

    private func spawnSinglePen(at position: CGPoint, color: UIColor, capOnLeft: Bool) {
        let length = GameConstants.penLength
        let height = GameConstants.penHeight
        let capWidth = GameConstants.capWidth

        let pen = SKNode()
        pen.position = position
        pen.zPosition = 5
        pen.name = "pen"

        // Barrel
        let barrel = SKShapeNode(rectOf: CGSize(width: length, height: height),
                                 cornerRadius: height / 2)
        barrel.fillColor = UIColor(white: 0.97, alpha: 1)
        barrel.strokeColor = UIColor(white: 0.72, alpha: 1)
        barrel.lineWidth = 1.2
        barrel.name = "barrel"
        pen.addChild(barrel)

        // Cap
        let capX = capOnLeft ? -length / 2 + capWidth / 2 : length / 2 - capWidth / 2
        let cap = SKShapeNode(rectOf: CGSize(width: capWidth, height: height),
                              cornerRadius: height / 2)
        cap.position = CGPoint(x: capX, y: 0)
        cap.fillColor = color
        cap.strokeColor = .clear
        pen.addChild(cap)

        // Tip
        let tipX = capOnLeft ? (length / 2 - 6) : -(length / 2 - 6)
        let tip = SKShapeNode(circleOfRadius: 3)
        tip.position = CGPoint(x: tipX, y: 0)
        tip.fillColor = UIColor(white: 0.28, alpha: 1)
        tip.strokeColor = .clear
        pen.addChild(tip)

        // Compound physics body
        let barrelCenterX: CGFloat = capOnLeft ? capWidth / 2 : -capWidth / 2
        let barrelBody = SKPhysicsBody(
            rectangleOf: CGSize(width: length - capWidth, height: height),
            center: CGPoint(x: barrelCenterX, y: 0)
        )
        let capCenterX: CGFloat = capOnLeft ? -length / 2 + capWidth / 2 : length / 2 - capWidth / 2
        let capBody = SKPhysicsBody(
            rectangleOf: CGSize(width: capWidth, height: height),
            center: CGPoint(x: capCenterX, y: 0)
        )

        // Realistic mass distribution — barrel is much heavier than cap
        capBody.mass = GameConstants.penMass * GameConstants.capMassRatio
        barrelBody.mass = GameConstants.penMass * GameConstants.barrelMassRatio

        let compound = SKPhysicsBody(bodies: [barrelBody, capBody])
        compound.friction = GameConstants.friction
        compound.restitution = GameConstants.restitution
        compound.linearDamping = GameConstants.linearDamping
        compound.angularDamping = GameConstants.angularDamping
        compound.allowsRotation = true
        compound.affectedByGravity = false
        compound.categoryBitMask = PhysicsCategory.pen
        compound.collisionBitMask = PhysicsCategory.wall | PhysicsCategory.pen
        compound.contactTestBitMask = PhysicsCategory.pen | PhysicsCategory.wall

        pen.physicsBody = compound
        pens.append(pen)
        addChild(pen)
    }

    // MARK: - Active Pen Highlight

    private func highlightActivePen() {
        pens.forEach { $0.childNode(withName: "highlight")?.removeFromParent() }
        guard !isRoundOver, pens.indices.contains(currentTurnIndex) else { return }

        let activePen = pens[currentTurnIndex]
        let penColor: UIColor = (currentTurnIndex == 0) ? .blue : .red

        let glow = SKShapeNode(rectOf: CGSize(width: 144, height: 28), cornerRadius: 14)
        glow.fillColor = penColor.withAlphaComponent(0.08)
        glow.strokeColor = penColor.withAlphaComponent(0.9)
        glow.lineWidth = 2.5
        glow.name = "highlight"
        glow.zPosition = 4

        let fadeOut = SKAction.fadeAlpha(to: 0.15, duration: 0.65)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.65)
        glow.run(.repeatForever(.sequence([fadeOut, fadeIn])))
        activePen.addChild(glow)
    }

    // MARK: - Touch Handling

    nonisolated override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        MainActor.assumeIsolated {
        guard !isTurnLocked, !isRoundOver,
              let touch = touches.first else { return }

        let location = touch.location(in: self)
        if let node = nodes(at: location).first?.parent,
           node == pens[currentTurnIndex] {
            selectedPen = node
            touchStartPoint = location
            createGroundShadow(for: node)
        }
        }
    }

    nonisolated override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        MainActor.assumeIsolated {
        guard let touch = touches.first,
              let start = touchStartPoint else { return }

        let current = touch.location(in: self)
        let dx = start.x - current.x
        let dy = start.y - current.y
        let distance = sqrt(dx * dx + dy * dy)
        guard distance > GameConstants.minimumDragToFlick else { return }

        let clamped = min(distance, GameConstants.maxDragDistance)
        let direction = CGVector(dx: dx / distance, dy: dy / distance)
        drawChevrons(from: start, direction: direction, force: clamped)
        updateGroundShadow(force: clamped, direction: direction)
        }
    }

    nonisolated override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        MainActor.assumeIsolated {
        guard let touch = touches.first,
              let start = touchStartPoint,
              let pen = selectedPen,
              !isRoundOver else {
            cleanupDragVisuals()
            return
        }

        let end = touch.location(in: self)
        let dx = start.x - end.x
        let dy = start.y - end.y
        let distance = sqrt(dx * dx + dy * dy)

        guard distance > GameConstants.minimumDragToFlick else {
            cleanupDragVisuals()
            return
        }

        // Quadratic force curve — short flicks are gentle, full drags are powerful
        let clamped = min(distance, GameConstants.maxDragDistance)
        let ratio = clamped / GameConstants.maxDragDistance
        let force = ratio * ratio * GameConstants.maxImpulse
        let direction = CGVector(dx: dx / distance, dy: dy / distance)
        let impulse = CGVector(dx: direction.dx * force, dy: direction.dy * force)

        // Apply at the touch point — hit centre for straight travel, hit ends for spin
        let localPoint = pen.convert(start, from: self)
        pen.physicsBody?.applyImpulse(impulse, at: localPoint)

        cleanupDragVisuals()
        isTurnLocked = true
        }
    }

    // MARK: - Drag Shadow

    private func createGroundShadow(for pen: SKNode) {
        groundShadow?.removeFromParent()
        let shadow = SKShapeNode(ellipseOf: CGSize(width: 70, height: 22))
        shadow.fillColor = UIColor.black.withAlphaComponent(0.12)
        shadow.strokeColor = .clear
        shadow.position = pen.position
        shadow.zPosition = 3
        addChild(shadow)
        groundShadow = shadow
    }

    private func updateGroundShadow(force: CGFloat, direction: CGVector) {
        guard let shadow = groundShadow else { return }
        let ratio = force / GameConstants.maxDragDistance
        shadow.xScale = 1.0 + ratio * 0.8
        shadow.yScale = 1.0 - ratio * 0.3
        shadow.zRotation = atan2(direction.dy, direction.dx)
        shadow.alpha = 0.1 + ratio * 0.15
    }

    // MARK: - Chevrons

    private func drawChevrons(from point: CGPoint, direction: CGVector, force: CGFloat) {
        chevronContainer?.removeFromParent()
        let container = SKNode()
        container.zPosition = 6
        addChild(container)
        chevronContainer = container

        let ratio = force / GameConstants.maxDragDistance
        let count = 2 + Int(ratio * 6)

        let color: UIColor
        switch ratio {
        case ..<0.33:  color = .systemGreen
        case ..<0.66:  color = .systemYellow
        case ..<0.85:  color = .systemOrange
        default:       color = .systemRed
        }

        for i in 0..<count {
            let chevron = SKShapeNode(path: makeChevronPath())
            chevron.fillColor = color
            chevron.strokeColor = .clear
            chevron.alpha = 1.0 - CGFloat(i) * 0.08
            chevron.position = CGPoint(
                x: point.x + direction.dx * CGFloat(i) * GameConstants.chevronSpacing,
                y: point.y + direction.dy * CGFloat(i) * GameConstants.chevronSpacing
            )
            chevron.zRotation = atan2(direction.dy, direction.dx)
            container.addChild(chevron)
        }
    }

    private func makeChevronPath() -> CGPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: -6, y: -4))
        path.addLine(to: CGPoint(x: 6, y: 0))
        path.addLine(to: CGPoint(x: -6, y: 4))
        path.close()
        return path.cgPath
    }

    private func cleanupDragVisuals() {
        chevronContainer?.removeFromParent()
        groundShadow?.removeFromParent()
        chevronContainer = nil
        groundShadow = nil
        selectedPen = nil
        touchStartPoint = nil
    }

    // MARK: - Game Loop

    nonisolated override func update(_ currentTime: TimeInterval) {
        MainActor.assumeIsolated {
        guard !isRoundOver else { return }
        checkForRingOut()
        checkForTurnCompletion()
        }
    }

    private func checkForTurnCompletion() {
        guard pens.count == 2, isTurnLocked else { return }

        let allStopped = pens.allSatisfy { pen in
            guard let body = pen.physicsBody else { return false }
            return body.velocity.length() < GameConstants.movementThreshold &&
                   abs(body.angularVelocity) < GameConstants.angularThreshold
        }

        if allStopped {
            isTurnLocked = false
            gameState?.switchTurn()
            currentTurnIndex = (gameState?.currentTurn == 1) ? 0 : 1
            highlightActivePen()
        }
    }

    private func checkForRingOut() {
        for (index, pen) in pens.enumerated() {
            guard !arenaRect.contains(pen.position) else { continue }

            isRoundOver = true
            let winnerIndex = (index == 0) ? 1 : 0

            pens.forEach { $0.physicsBody?.velocity = .zero }

            pen.run(.group([
                .scale(to: 0.85, duration: 0.15),
                .fadeAlpha(to: 0.35, duration: 0.15)
            ]))

            pens[winnerIndex].run(.sequence([
                .scale(to: 1.06, duration: 0.08),
                .scale(to: 1.0, duration: 0.08)
            ]))

            let scoringPlayer = (index == 0) ? 2 : 1
            gameState?.scorePoint(for: scoringPlayer)

            run(.wait(forDuration: 0.9)) { [weak self] in
                guard let self, self.gameState?.winner == nil else { return }
                self.spawnPens()
                self.highlightActivePen()
            }
            break
        }
    }
}

// MARK: - Contact Delegate

extension GameScene: SKPhysicsContactDelegate {
    nonisolated func didBegin(_ contact: SKPhysicsContact) {
        let catA = contact.bodyA.categoryBitMask
        let catB = contact.bodyB.categoryBitMask
        let impulse = contact.collisionImpulse
        nonisolated(unsafe) let nodeA = contact.bodyA.node
        nonisolated(unsafe) let nodeB = contact.bodyB.node

        MainActor.assumeIsolated {
            guard catA == PhysicsCategory.pen,
                  catB == PhysicsCategory.pen else { return }

            let penA = nodeA?.ancestorNode(withName: "pen") ?? nodeA
            let penB = nodeB?.ancestorNode(withName: "pen") ?? nodeB

            let bump = SKAction.sequence([
                .scale(to: 1.04, duration: 0.05),
                .scale(to: 1.0, duration: 0.07)
            ])
            penA?.run(bump)
            penB?.run(bump)

            let style: UIImpactFeedbackGenerator.FeedbackStyle
            if impulse > 8 {
                style = .heavy
            } else if impulse > 3 {
                style = .medium
            } else {
                style = .light
            }
            UIImpactFeedbackGenerator(style: style).impactOccurred()
        }
    }
}

// MARK: - Helpers

extension SKNode {
    @MainActor func ancestorNode(withName name: String) -> SKNode? {
        var current = self.parent
        while let node = current {
            if node.name == name { return node }
            current = node.parent
        }
        return nil
    }
}

extension CGVector {
    nonisolated func length() -> CGFloat { sqrt(dx * dx + dy * dy) }
}
