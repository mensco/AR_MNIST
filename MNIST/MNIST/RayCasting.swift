//
//  RayCasting.swift
//  MNIST
//
//  Created by Katsuya Terahata on 2020/01/23.
//  Copyright © 2020 Katsuya Terahata. All rights reserved.
//
import RealityKit
import Foundation
import ARKit

extension ARView{
    
    class CustomBox: Entity, HasModel, HasAnchoring, HasCollision {
        required init(color: UIColor) {
            super.init()
            self.components[ModelComponent] = ModelComponent(
                mesh: .generateBox(size: 0.1),
                materials: [SimpleMaterial(
                    color: color,
                    isMetallic: false)
                ]
            )
        }
        
        convenience init(color: UIColor, position: SIMD3<Float>) {
            self.init(color: color)
            self.position = position
        }
        
        required init() {
            fatalError("init() has not been implemented")
        }
    }
    
    func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        
        guard let touchInView = sender?.location(in: self) else {
            return
        }
        
        rayCastingMethod(point: touchInView)
        
        //to find whether an entity exists at the point of contact
        let entities = self.entities(at: touchInView)
    }
    
    func rayCastingMethod(point: CGPoint) {
        
        
        guard let coordinator = self.session.delegate as? ARViewCoordinator else{ print("GOOD NIGHT"); return }
        
        guard let raycastQuery = self.makeRaycastQuery(from: point,
                                                       allowing: .existingPlaneInfinite,
                                                       alignment: .horizontal) else {
                                                        
                                                        print("failed first")
                                                        return
        }
        
        guard let result = self.session.raycast(raycastQuery).first else {
            print("failed")
            return
        }
        
        let transformation = Transform(matrix: result.worldTransform)
        let box = CustomBox(color: .yellow)
        self.installGestures(.all, for: box)
        box.generateCollisionShapes(recursive: true)
        
        let mesh = MeshResource.generateText(
            "\(coordinator.overlayText)",
            extrusionDepth: 0.1,
            font: .systemFont(ofSize: 2),
            containerFrame: .zero,
            alignment: .left,
            lineBreakMode: .byTruncatingTail)
        
        let occlusion = OcclusionMaterial(receivesDynamicLighting: true) //An invisible material that hides objects rendered behind it.
        let material = SimpleMaterial(color: .red, isMetallic: false)
        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.scale = SIMD3<Float>(0.03, 0.03, 0.1)
        
        box.addChild(entity)
        box.transform = transformation
        
        entity.setPosition(SIMD3<Float>(0, 0.05, 0), relativeTo: box)
        
        let raycastAnchor = AnchorEntity(raycastResult: result)
        raycastAnchor.addChild(box)
        self.scene.addAnchor(raycastAnchor)
    }
}
