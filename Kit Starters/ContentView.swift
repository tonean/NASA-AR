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
    var titleTextNode: SCNNode?
    var subtitleTextNode: SCNNode?
    
    // Text animation properties
    let titleText = "Stress Busters"
    let subtitleText = "Play with a basketball in a microgravity environment"
    var titleIndex = 0
    var subtitleIndex = 0
    var titleTimer: Timer?
    var subtitleTimer: Timer?
    
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
        
        // Create and add text node
        createTextNode()
        
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
    
    func createTextNode() {
        let text = SCNText(string: "Welcome Astronaut!", extrusionDepth: 1.0)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.white
        text.materials = [material]
        
        textNode = SCNNode(geometry: text)
        textNode?.scale = SCNVector3(0.01, 0.01, 0.01)
        textNode?.position = SCNVector3(-0.2, 0, -1)
        
        if let textNode = textNode {
            sceneView.scene.rootNode.addChildNode(textNode)
        }
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
                
                basketballNode.physicsBody?.angularVelocity = angularVelocity
                basketballNode.physicsBody?.velocity = throwVelocity
                
            default:
                break
            }
        }
    
    func addMainTapGesture() {
        if let mainTapGesture = mainTapGesture {
            sceneView.removeGestureRecognizer(mainTapGesture)
        }
        mainTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        if let mainTapGesture = mainTapGesture {
            sceneView.addGestureRecognizer(mainTapGesture)
        }
    }
    
    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let tapLocation = gestureRecognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation, options: [.boundingBoxOnly: true])
        
        if let hitNode = hitTestResults.first?.node, let index = buttonNodes.firstIndex(of: hitNode) {
            sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
                node.removeFromParentNode()
            }
            
            if index == 0 {
                let rectangleGeometry = SCNPlane(width: 0.5, height: 0.3)
                let rectangleMaterial = SCNMaterial()
                rectangleMaterial.diffuse.contents = UIColor(white: 1.0, alpha: 0.5)
                rectangleGeometry.materials = [rectangleMaterial]
                
                let rectangleNode = SCNNode(geometry: rectangleGeometry)
                rectangleNode.position = SCNVector3(0, 0, -1)
                sceneView.scene.rootNode.addChildNode(rectangleNode)
            } else if index == 1 {
                createBasketball()
            }
            
            createBackButton()
        }
    }
    
    func createBackButton() {
        let backText = SCNText(string: "<", extrusionDepth: 0.1)
        let backMaterial = SCNMaterial()
        backMaterial.diffuse.contents = UIColor.white
        backText.materials = [backMaterial]
        
        backButtonNode = SCNNode(geometry: backText)
        backButtonNode?.scale = SCNVector3(0.01, 0.01, 0.01)
        backButtonNode?.position = SCNVector3(-0.4, 0.2, -1)
        
        if let backButtonNode = backButtonNode {
            sceneView.scene.rootNode.addChildNode(backButtonNode)
            
            if let backTapGesture = backTapGesture {
                sceneView.removeGestureRecognizer(backTapGesture)
            }
            
            backTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackTap(_:)))
            if let backTapGesture = backTapGesture {
                sceneView.addGestureRecognizer(backTapGesture)
            }
        }
    }
    
    @objc func handleBackTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let tapLocation = gestureRecognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation, options: [.boundingBoxOnly: true])
        
        if let hitNode = hitTestResults.first?.node, hitNode == backButtonNode {
            sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
                node.removeFromParentNode()
            }
            
            createTextNode()
            createButtonNodes()
            addMainTapGesture()
            
            if let panGesture = panGesture {
                sceneView.removeGestureRecognizer(panGesture)
                self.panGesture = nil
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
}
