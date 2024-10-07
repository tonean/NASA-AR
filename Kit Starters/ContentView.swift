import UIKit
import ARKit
import SceneKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    var sceneView: ARSCNView!
    var buttonNodes: [SCNNode] = [] // Store button nodes
    var textNode: SCNNode?
    var backButtonNode: SCNNode?
    var mainTapGesture: UITapGestureRecognizer?
    var backTapGesture: UITapGestureRecognizer?
    var basketballNode: SCNNode?
    var panGesture: UIPanGestureRecognizer?
    
    // Text animation properties
    let titleText = "Stress Busters"
    let subtitleText = "Play with a basketball in a microgravity environment"
    var titleIndex = 0
    var subtitleIndex = 0
    var titleTimer: Timer?
    var subtitleTimer: Timer?
    
    // Typing animation properties
    let welcomeText = "Welcome Astronaut!"
    var typingIndex = 0
    var typingTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create AR Scene View
        sceneView = ARSCNView(frame: view.bounds)
        view.addSubview(sceneView)
        
        // Set up scene
        sceneView.delegate = self
        sceneView.scene = SCNScene()
        
        // Set up physics for space simulation
        sceneView.scene.physicsWorld.gravity = SCNVector3(0, 0, 0) // Zero gravity for space
        
        // Create and add text node with typing animation
        createTypingTextNode()
        
        // Create and add button nodes
        createButtonNodes()
        
        // Enable tap gesture detection
        addMainTapGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create AR configuration
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    func createTypingTextNode() {
        textNode = SCNNode()
        textNode?.position = SCNVector3(-0.2, 0, -1)
        sceneView.scene.rootNode.addChildNode(textNode!)
        
        startTypingAnimation()
    }
    
    func startTypingAnimation() {
        typingIndex = 0
        
        // Clear existing text nodes by iterating through the child nodes
        textNode?.childNodes.forEach { $0.removeFromParentNode() }
        
        typingTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            if self.typingIndex < self.welcomeText.count {
                let character = String(self.welcomeText[self.welcomeText.index(self.welcomeText.startIndex, offsetBy: self.typingIndex)])
                self.addCharacter(character)
                self.typingIndex += 1
            } else {
                timer.invalidate() // Stop the timer when done
                self.typingTimer = nil
            }
        }
    }

    
    func addCharacter(_ character: String) {
        let text = SCNText(string: character, extrusionDepth: 1.0)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.white
        text.materials = [material]
        
        let characterNode = SCNNode(geometry: text)
        characterNode.scale = SCNVector3(0.01, 0.01, 0.01)
        characterNode.position = SCNVector3(-0.2 + Float(typingIndex) * 0.05, 0, -1) // Adjust positioning for spacing
        
        textNode?.addChildNode(characterNode)
    }
    
    func createButtonNodes() {
        buttonNodes.removeAll()
        
        let buttonCount = 6
        let defaultSpacing: Float = 0.18
        let secondRowSpacing: Float = 0.28
        let buttonWidth: CGFloat = 0.12
        let buttonHeight: CGFloat = 0.12
        let chamferRadius: CGFloat = 0.03
        
        let buttonsPerRow = 2
        let startX: Float = 0.2
        let startY: Float = -0.15
        
        for i in 0..<buttonCount {
            let buttonGeometry = SCNBox(width: buttonWidth, height: buttonHeight, length: 0.01, chamferRadius: chamferRadius)
            let buttonMaterial = SCNMaterial()
            buttonMaterial.diffuse.contents = UIColor(white: 1.0, alpha: 0.85)
            buttonGeometry.materials = [buttonMaterial]
            
            let buttonNode = SCNNode(geometry: buttonGeometry)
            let row = i / buttonsPerRow
            let column = i % buttonsPerRow
            
            let positionX = startX + (row == 1 ? (column == 0 ? -0.1 : secondRowSpacing) : Float(column) * defaultSpacing)
            let positionY = startY - Float(row) * defaultSpacing
            buttonNode.position = SCNVector3(positionX, positionY, -1)
            
            buttonNodes.append(buttonNode)
            sceneView.scene.rootNode.addChildNode(buttonNode)
            
            let numberText = SCNText(string: "\(i + 1)", extrusionDepth: 0.1)
            let numberMaterial = SCNMaterial()
            numberMaterial.diffuse.contents = UIColor.white
            numberText.materials = [numberMaterial]
            
            let numberNode = SCNNode(geometry: numberText)
            numberNode.scale = SCNVector3(0.003, 0.003, 0.003)
            numberNode.position = SCNVector3(positionX, positionY - 0.12, -1)
            sceneView.scene.rootNode.addChildNode(numberNode)
        }
        
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .directional
        lightNode.light?.color = UIColor.white
        lightNode.position = SCNVector3(0, 5, 5)
        lightNode.eulerAngles = SCNVector3(-0.5, 0, 0)
        sceneView.scene.rootNode.addChildNode(lightNode)
    }
    
    func createBasketball() {
        let sphereGeometry = SCNSphere(radius: 0.1)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.orange
        sphereGeometry.materials = [material]
        
        basketballNode = SCNNode(geometry: sphereGeometry)
        basketballNode?.position = SCNVector3(0, 0, -1)
        
        // Configure physics body for space simulation
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: sphereGeometry, options: nil))
        physicsBody.mass = 0.6 // Basketball-like mass
        physicsBody.friction = 0.5
        physicsBody.restitution = 0.8 // Higher restitution for more bouncy behavior
        physicsBody.damping = 0.1 // Low damping for space-like movement
        physicsBody.angularDamping = 0.1 // Low angular damping for realistic rotation
        basketballNode?.physicsBody = physicsBody
        
        if let basketballNode = basketballNode {
            sceneView.scene.rootNode.addChildNode(basketballNode)
        }
        
        setupPanGesture()
    }
    
    func setupPanGesture() {
        if let existingPanGesture = panGesture {
            sceneView.removeGestureRecognizer(existingPanGesture)
        }
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        if let panGesture = panGesture {
            sceneView.addGestureRecognizer(panGesture)
        }
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let basketballNode = basketballNode else { return }
        
        switch gesture.state {
        case .began:
            basketballNode.physicsBody?.isAffectedByGravity = false
            basketballNode.physicsBody?.velocity = SCNVector3Zero
            
        case .changed:
            let translation = gesture.translation(in: sceneView)
            let currentPosition = basketballNode.position
            
            // Convert pan gesture movement to 3D space
            let movementSpeed: Float = 0.001
            let newPosition = SCNVector3(
                currentPosition.x + Float(translation.x) * movementSpeed,
                currentPosition.y - Float(translation.y) * movementSpeed,
                currentPosition.z
            )
            
            basketballNode.position = newPosition
            gesture.setTranslation(.zero, in: sceneView)
            
        case .ended:
            let velocity = gesture.velocity(in: sceneView)
            let velocityScale: Float = 0.0005 // Adjust this value to change throw sensitivity
            
            // Apply velocity based on gesture movement
            let throwVelocity = SCNVector3(
                Float(velocity.x) * velocityScale,
                -Float(velocity.y) * velocityScale,
                0
            )
            
            // Create random rotation axis and angle
            let randomX = Float.random(in: -1...1)
            let randomY = Float.random(in: -1...1)
            let randomZ = Float.random(in: -1...1)
            let randomAngle = Float.random(in: 0...Float.pi * 2)
            
            // Create SCNVector4 for angular velocity (x, y, z, w) where w is the rotation angle
            let angularVelocity = SCNVector4(randomX, randomY, randomZ, randomAngle)
            
            basketballNode.physicsBody?.applyForce(throwVelocity, at: SCNVector3Zero, asImpulse: true)
            basketballNode.physicsBody?.angularVelocity = angularVelocity // Apply random spin
            
            basketballNode.physicsBody?.isAffectedByGravity = true // Allow gravity again
            
        default:
            break
        }
    }
    
    func addMainTapGesture() {
        mainTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMainTap(_:)))
        if let mainTapGesture = mainTapGesture {
            sceneView.addGestureRecognizer(mainTapGesture)
        }
    }
    
    @objc func handleMainTap(_ gesture: UITapGestureRecognizer) {
        // Switch to basketball scene
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode() // Clear existing nodes
        }
        
        // Re-create basketball node
        createBasketball()
        
        // Remove tap gesture recognizer to prevent additional taps
        if let mainTapGesture = mainTapGesture {
            sceneView.removeGestureRecognizer(mainTapGesture)
        }
        
        // Add back button
        createBackButtonNode()
    }
    
    func createBackButtonNode() {
        let backButtonGeometry = SCNBox(width: 0.12, height: 0.12, length: 0.01, chamferRadius: 0.03)
        let backButtonMaterial = SCNMaterial()
        backButtonMaterial.diffuse.contents = UIColor(white: 1.0, alpha: 0.85)
        backButtonGeometry.materials = [backButtonMaterial]
        
        backButtonNode = SCNNode(geometry: backButtonGeometry)
        backButtonNode?.position = SCNVector3(0.0, -0.25, -1)
        
        sceneView.scene.rootNode.addChildNode(backButtonNode!)
        
        let backText = SCNText(string: "Back", extrusionDepth: 0.01)
        let backTextMaterial = SCNMaterial()
        backTextMaterial.diffuse.contents = UIColor.white
        backText.materials = [backTextMaterial]
        
        let backTextNode = SCNNode(geometry: backText)
        backTextNode.scale = SCNVector3(0.003, 0.003, 0.003)
        backTextNode.position = SCNVector3(0.0, -0.25 - 0.12, -1)
        
        sceneView.scene.rootNode.addChildNode(backTextNode)
        
        // Enable back button tap gesture
        addBackTapGesture()
    }
    
    func addBackTapGesture() {
        backTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackTap(_:)))
        if let backTapGesture = backTapGesture {
            sceneView.addGestureRecognizer(backTapGesture)
        }
    }
    
    @objc func handleBackTap(_ gesture: UITapGestureRecognizer) {
        // Remove basketball node and go back to the main screen
        basketballNode?.removeFromParentNode()
        
        // Clear other nodes and reset scene
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()
        }
        
        // Re-create main screen text and buttons
        createTypingTextNode()
        createButtonNodes()
        
        // Remove back button
        backButtonNode?.removeFromParentNode()
        
        // Remove back tap gesture
        if let backTapGesture = backTapGesture {
            sceneView.removeGestureRecognizer(backTapGesture)
        }
        
        // Re-enable main tap gesture
        addMainTapGesture()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
