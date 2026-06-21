//
//  GameEngine.swift
//  PulsaMatchaSpace
//
//  Core "Sequence Chain" logic.
//
//  Numbered balls drift and bounce around a square arena. Each grab the game
//  highlights a RANDOM target number; the player must tap a ball showing that
//  number. Every correct tap grows the chain and a fresh random target is
//  chosen. A wrong number or a stalled grab-timer costs a life and breaks the
//  chain. Dark void hazards roam the field as tap-traps (tapping one costs a
//  life and scatters the balls) — and more of them spawn the further you get.
//
//  Performance: the per-frame state (ball/hazard positions, grab timer,
//  pop effects) lives in non-@Published properties mutated on a CADisplayLink
//  bound to the main runloop; views read it inside a TimelineView(.animation)
//  so only the field repaints each frame. Only discrete events (chain, lives,
//  next number, score, finish) publish to SwiftUI.
//

import SwiftUI
import QuartzCore

// MARK: - Entities
struct NumberBall: Identifiable {
    let id = UUID()
    var position: CGPoint
    var velocity: CGVector
    var radius: CGFloat
    var number: Int
}

struct VoidHazard: Identifiable {
    let id = UUID()
    var position: CGPoint
    var velocity: CGVector
    var radius: CGFloat
}

struct PopEffect: Identifiable {
    let id = UUID()
    var position: CGPoint
    var color: Color
    var birth: CFTimeInterval
}

enum FlashKind: Equatable {
    case wrong, hazard, timeout

    var color: Color {
        switch self {
        case .wrong:   return Palette.red
        case .hazard:  return Palette.magenta
        case .timeout: return Palette.yellow
        }
    }
}

// MARK: - Engine
final class GameEngine: NSObject, ObservableObject {

    // MARK: Published (discrete events only)
    @Published var lives: Int = 3
    @Published var chain: Int = 0
    @Published var nextNumber: Int = 1
    @Published var score: Int = 0
    @Published var isRunning: Bool = false
    @Published var isPaused: Bool = false
    @Published var isFinished: Bool = false
    @Published var didWin: Bool = false
    @Published var flash: FlashKind? = nil

    // MARK: Per-frame state (NOT published — read by TimelineView)
    private(set) var balls: [NumberBall] = []
    private(set) var hazards: [VoidHazard] = []
    private(set) var pops: [PopEffect] = []
    private(set) var grabRemaining: Double = 0
    var fieldSize: CGSize = .zero

    // MARK: Config
    let mode: GameMode
    let sequenceLength: Int
    let targetChain: Int?          // nil → endless survival
    let skinColor: Color
    private let initialBallCount: Int
    private let initialHazardCount: Int
    private let baseGrabTime: Double
    private let baseSpeed: CGFloat

    // MARK: Runtime
    private var speedMul: CGFloat = 1.0
    private var grabTime: Double = 3.0
    private(set) var bestChainRun: Int = 0

    // MARK: Timing
    private var displayLink: CADisplayLink?
    private var lastTimestamp: CFTimeInterval = 0

    // MARK: Derived
    private var fieldEdge: CGFloat { min(fieldSize.width, fieldSize.height) }
    private var speedScale: CGFloat { max(0.6, min(1.6, fieldEdge / 350)) }
    private var currentSpeed: CGFloat { baseSpeed * speedScale * speedMul }
    private var ballRadius: CGFloat { max(20, min(34, fieldEdge * 0.072)) }
    private var hazardRadius: CGFloat { max(22, min(38, fieldEdge * 0.082)) }

    var grabFraction: Double {
        guard grabTime > 0 else { return 0 }
        return max(0, min(1, grabRemaining / grabTime))
    }

    var levelDef: LevelDefinition? {
        if case .level(let i) = mode { return LevelDefinition.all.first { $0.id == i } }
        return nil
    }

    // MARK: Init
    init(mode: GameMode) {
        self.mode = mode
        self.skinColor = PulseSkin.byId(StorageManager.shared.read().equippedSkinId).color
        switch mode {
        case .level(let i):
            let def = LevelDefinition.all.first { $0.id == i } ?? LevelDefinition.all[0]
            sequenceLength = def.sequenceLength
            targetChain = def.targetChain
            initialBallCount = def.ballCount
            initialHazardCount = def.hazardCount
            baseGrabTime = def.grabTime
            baseSpeed = def.baseSpeed
        case .survival:
            sequenceLength = 6
            targetChain = nil
            initialBallCount = 9
            initialHazardCount = 1
            baseGrabTime = 3.0
            baseSpeed = 95
        }
        super.init()
    }

    deinit {
        displayLink?.invalidate()
    }

    // MARK: Lifecycle
    func start(fieldSize: CGSize) {
        self.fieldSize = fieldSize
        lives = 3
        chain = 0
        bestChainRun = 0
        nextNumber = Int.random(in: 1...sequenceLength)
        score = 0
        speedMul = 1.0
        grabTime = baseGrabTime
        grabRemaining = grabTime
        isFinished = false
        didWin = false
        isPaused = false
        isRunning = true
        flash = nil
        pops = []

        spawnInitialBalls()
        spawnInitialHazards()
        ensureTargetPresent()

        stopDisplayLink()
        lastTimestamp = CACurrentMediaTime()
        let link = CADisplayLink(target: self, selector: #selector(step(_:)))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    func stop() {
        isRunning = false
        stopDisplayLink()
    }

    func pause(_ paused: Bool) {
        isPaused = paused
        if !paused { lastTimestamp = CACurrentMediaTime() }
    }

    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }

    // MARK: Spawning
    private func spawnInitialBalls() {
        var numbers: [Int] = Array(1...sequenceLength)
        while numbers.count < initialBallCount {
            numbers.append(Int.random(in: 1...sequenceLength))
        }
        numbers.shuffle()
        numbers = Array(numbers.prefix(initialBallCount))
        balls = numbers.map { makeBall(number: $0) }
    }

    private func spawnInitialHazards() {
        hazards = (0..<initialHazardCount).map { _ in makeHazard() }
    }

    private func makeBall(number: Int) -> NumberBall {
        let r = ballRadius
        return NumberBall(position: randomPosition(radius: r),
                          velocity: randomVelocity(speed: currentSpeed),
                          radius: r,
                          number: number)
    }

    private func makeHazard() -> VoidHazard {
        let r = hazardRadius
        return VoidHazard(position: randomPosition(radius: r),
                          velocity: randomVelocity(speed: currentSpeed * 0.8),
                          radius: r)
    }

    private func randomPosition(radius: CGFloat) -> CGPoint {
        let w = max(radius * 2 + 1, fieldSize.width)
        let h = max(radius * 2 + 1, fieldSize.height)
        return CGPoint(x: CGFloat.random(in: radius...(w - radius)),
                       y: CGFloat.random(in: radius...(h - radius)))
    }

    private func randomVelocity(speed: CGFloat) -> CGVector {
        let a = CGFloat.random(in: 0...(2 * CGFloat.pi))
        return CGVector(dx: cos(a) * speed, dy: sin(a) * speed)
    }

    /// Guarantee the field always contains the current target number so the
    /// sequence is always solvable.
    private func ensureTargetPresent() {
        guard !balls.isEmpty else { return }
        if !balls.contains(where: { $0.number == nextNumber }) {
            let idx = Int.random(in: 0..<balls.count)
            balls[idx].number = nextNumber
        }
    }

    // MARK: Input
    func handleTap(at point: CGPoint) {
        guard isRunning, !isPaused, !isFinished else { return }

        // Hazards are the topmost threat — check them first.
        if let h = hazards.first(where: {
            hypot($0.position.x - point.x, $0.position.y - point.y) <= $0.radius + 6
        }) {
            onHazardTapped(h)
            return
        }

        // Nearest numbered ball under the tap.
        var hitIndex: Int? = nil
        var bestDist = CGFloat.greatestFiniteMagnitude
        for (i, b) in balls.enumerated() {
            let d = hypot(b.position.x - point.x, b.position.y - point.y)
            if d <= b.radius + 8 && d < bestDist {
                bestDist = d
                hitIndex = i
            }
        }
        guard let idx = hitIndex else { return }   // empty space — ignore

        if balls[idx].number == nextNumber {
            onCorrect(index: idx)
        } else {
            onWrong()
        }
    }

    // MARK: Events
    private func onCorrect(index: Int) {
        Haptic.success()
        let ball = balls[index]
        pops.append(PopEffect(position: ball.position, color: skinColor, birth: CACurrentMediaTime()))
        balls.remove(at: index)

        chain += 1
        bestChainRun = max(bestChainRun, chain)
        score += 10 + chain * 2

        nextNumber = pickNextTarget()
        grabRemaining = grabTime

        balls.append(makeBall(number: Int.random(in: 1...sequenceLength)))
        ensureTargetPresent()
        rampDifficulty()

        if let t = targetChain, chain >= t {
            win()
        }
    }

    private func onWrong() {
        Haptic.error()
        triggerFlash(.wrong)
        breakChain()
    }

    private func onTimeout() {
        Haptic.warning()
        triggerFlash(.timeout)
        breakChain()
    }

    private func breakChain() {
        lives -= 1
        chain = 0
        nextNumber = pickNextTarget()
        grabRemaining = grabTime
        ensureTargetPresent()
        if lives <= 0 { gameOver() }
    }

    private func onHazardTapped(_ h: VoidHazard) {
        Haptic.error()
        triggerFlash(.hazard)
        lives -= 1
        scatterAllBalls()
        if let i = hazards.firstIndex(where: { $0.id == h.id }) {
            hazards[i] = makeHazard()
        }
        if lives <= 0 { gameOver() }
    }

    private func scatterAllBalls() {
        balls = balls.map {
            var b = $0
            b.velocity = randomVelocity(speed: currentSpeed * 1.2)
            return b
        }
    }

    private func triggerFlash(_ kind: FlashKind) {
        withAnimation(.easeOut(duration: 0.1)) { flash = kind }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
            withAnimation(.easeIn(duration: 0.2)) { self?.flash = nil }
        }
    }

    private var maxHazards: Int {
        switch mode {
        case .survival: return 7
        case .level:    return min(8, initialHazardCount + 4)
        }
    }

    /// The next target is a RANDOM number drawn from 1...sequenceLength,
    /// avoiding an immediate repeat so the player must always re-scan the field.
    private func pickNextTarget() -> Int {
        guard sequenceLength > 1 else { return 1 }
        var n = Int.random(in: 1...sequenceLength)
        var guardCount = 0
        while n == nextNumber && guardCount < 8 {
            n = Int.random(in: 1...sequenceLength)
            guardCount += 1
        }
        return n
    }

    private func rampDifficulty() {
        guard chain > 0 else { return }
        // Speed / grab-timer ramp on each completed cycle of grabs.
        if chain % sequenceLength == 0 {
            speedMul = min(2.2, speedMul + 0.12)
            grabTime = max(1.6, grabTime - 0.1)
            rescaleVelocities()
        }
        // More void holes the further you get.
        if chain % 4 == 0, hazards.count < maxHazards {
            hazards.append(makeHazard())
        }
    }

    private func rescaleVelocities() {
        let target = currentSpeed
        func rescale(_ v: CGVector) -> CGVector {
            let mag = max(1, hypot(v.dx, v.dy))
            return CGVector(dx: v.dx / mag * target, dy: v.dy / mag * target)
        }
        balls = balls.map { var b = $0; b.velocity = rescale(b.velocity); return b }
        hazards = hazards.map { var h = $0; h.velocity = rescale(h.velocity); return h }
    }

    private func win() {
        didWin = true
        finish()
    }

    private func gameOver() {
        didWin = false
        finish()
    }

    private func finish() {
        isRunning = false
        isFinished = true
        stopDisplayLink()
    }

    // MARK: Tick (CADisplayLink, main thread)
    @objc private func step(_ link: CADisplayLink) {
        guard isRunning, !isPaused, !isFinished else {
            lastTimestamp = link.timestamp
            return
        }
        let dt = min(0.05, link.timestamp - lastTimestamp)
        lastTimestamp = link.timestamp
        tick(dt: dt)
    }

    private func tick(dt: Double) {
        moveEntities(dt: dt)
        repelBallsFromHazards()

        grabRemaining -= dt
        if grabRemaining <= 0 {
            onTimeout()
        }

        let now = CACurrentMediaTime()
        if !pops.isEmpty {
            pops.removeAll { now - $0.birth > 0.55 }
        }
    }

    private func moveEntities(dt: Double) {
        let w = fieldSize.width, h = fieldSize.height
        guard w > 0, h > 0 else { return }
        if !balls.isEmpty {
            var u = balls
            for i in 0..<u.count {
                var pos = u[i].position
                var vel = u[i].velocity
                stepEntity(&pos, &vel, u[i].radius, dt, w, h)
                u[i].position = pos
                u[i].velocity = vel
            }
            balls = u
        }
        if !hazards.isEmpty {
            var u = hazards
            for i in 0..<u.count {
                var pos = u[i].position
                var vel = u[i].velocity
                stepEntity(&pos, &vel, u[i].radius, dt, w, h)
                u[i].position = pos
                u[i].velocity = vel
            }
            hazards = u
        }
    }

    private func stepEntity(_ pos: inout CGPoint, _ vel: inout CGVector, _ radius: CGFloat,
                            _ dt: Double, _ w: CGFloat, _ h: CGFloat) {
        var x = pos.x + vel.dx * dt
        var y = pos.y + vel.dy * dt
        var vx = vel.dx, vy = vel.dy
        if x - radius < 0 { x = radius; vx = abs(vx) + jitter() }
        if x + radius > w { x = w - radius; vx = -abs(vx) - jitter() }
        if y - radius < 0 { y = radius; vy = abs(vy) + jitter() }
        if y + radius > h { y = h - radius; vy = -abs(vy) - jitter() }
        pos = CGPoint(x: x, y: y)
        vel = CGVector(dx: vx, dy: vy)
    }

    private func jitter() -> CGFloat { CGFloat.random(in: -8...8) }

    /// Void hazards push numbered balls away on near-contact — the "scatter".
    private func repelBallsFromHazards() {
        guard !hazards.isEmpty, !balls.isEmpty else { return }
        var u = balls
        for h in hazards {
            for i in 0..<u.count {
                let dx = u[i].position.x - h.position.x
                let dy = u[i].position.y - h.position.y
                let dist = max(1, hypot(dx, dy))
                let minDist = h.radius + u[i].radius + 4
                if dist < minDist {
                    let nx = dx / dist, ny = dy / dist
                    u[i].velocity = CGVector(dx: nx * currentSpeed, dy: ny * currentSpeed)
                    u[i].position = CGPoint(x: h.position.x + nx * minDist,
                                            y: h.position.y + ny * minDist)
                }
            }
        }
        balls = u
    }
}
