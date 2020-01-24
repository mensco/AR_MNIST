//
//  ARViewContainer.swift
//  MNIST
//
//  Created by Katsuya Terahata on 2020/01/23.
//  Copyright © 2020 Katsuya Terahata. All rights reserved.
//

import Foundation
import RealityKit
import ARKit
import UIKit
import SwiftUI

struct ARViewContainer: UIViewRepresentable {
    
    @Binding var overlayText: String
    
    func makeCoordinator() -> ARViewCoordinator{
        ARViewCoordinator(self, overlayText : $overlayText)
    }
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.addCoaching()
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        arView.session.run(config, options: [])
        
        arView.setupGestures()
        arView.session.delegate = context.coordinator
//        arView.installGestures(.init(arrayLiteral: [.rotate, .scale]), for: box)
        
        return arView
    }
    func updateUIView(_ uiView: ARView, context: Context) {
        
    }
}

class ARViewCoordinator: NSObject, ARSessionDelegate {
    var arVC: ARViewContainer
    
    @Binding var overlayText: String
    
    init(_ control: ARViewContainer, overlayText: Binding<String>) {
        self.arVC = control
        _overlayText = overlayText
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
    }
}

extension ARView: ARCoachingOverlayViewDelegate {
    func addCoaching() {
        
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.delegate = self
        coachingOverlay.session = self.session
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        coachingOverlay.goal = .anyPlane
        self.addSubview(coachingOverlay)
    }
    
    public func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        //Ready to add entities next?
        coachingOverlayView.activatesAutomatically = false //the plane is lost, avoiding to start onboarding
    }
}
