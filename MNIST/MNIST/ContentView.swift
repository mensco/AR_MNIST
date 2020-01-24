//
//  ContentView.swift
//  MNIST
//
//  Created by Katsuya Terahata on 2020/01/23.
//  Copyright © 2020 Katsuya Terahata. All rights reserved.
//

import SwiftUI
import RealityKit
import ARKit
import Vision

struct ContentView : View {
    
//    let pkCanvas = PKCanvasRepresentation()
    @State var digitPredicted = "NA"
    
    
    private let textRecognitionWorkQueue = DispatchQueue(label: "VisionRequest", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    
    var body: some View {
        VStack{
            ARViewContainer(overlayText: $digitPredicted).edgesIgnoringSafeArea(.all)
//            pkCanvas

            HStack{
                    Text("")
            Button(action: {
//                let image = self.pkCanvas.canvasView.drawing.image(from: self.pkCanvas.canvasView.drawing.bounds, scale: 1.0)

//                self.recognizeTextInImage(image)
//                self.pkCanvas.canvasView.drawing = PKDrawing()

            }){
                Text("Extract Digit")
            }
//            .buttonStyle(MyButtonStyle(color: .blue))

                Text(digitPredicted)

            }
            
        }
    }
    
    private func recognizeTextInImage(_ image: UIImage) {
        
        guard let cgImage = image.cgImage else { return }
        
        let model = try! VNCoreMLModel(for: MNIST().model)
        
        let request = VNCoreMLRequest(model: model)
        request.imageCropAndScaleOption = .scaleFit
        
        textRecognitionWorkQueue.async {
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try requestHandler.perform([request])
                
                if let observations = request.results as? [VNClassificationObservation]{
                    self.digitPredicted = observations.first?.identifier ?? ""
                }
                
            } catch {
                print(error)
            }
        }
    }
}


#if DEBUG
//struct ContentView_Previews : PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
#endif
