
//  Created by MacBook  on 08/12/2017.
//  Copyright © 2017 Onurcan Yurt. All rights reserved.
//

import UIKit
import AVKit
import Vision


class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    @IBOutlet weak var label: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo 
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            return
        }
        
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else{
            
            return
        }
        
        captureSession.addInput(input)
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        view.layer.addSublayer(previewLayer)
        
        previewLayer.frame = view.frame
        
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
    }
    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        
        guard let model = try? VNCoreMLModel(for: people().model) else{ return }
        let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
            
                                                     
            guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
            guard let firstObservation = results.first else { return }
                                                     
            
                                                     
            DispatchQueue.main.async {
                
                self.label.text = " \(firstObservation.identifier) \(firstObservation.confidence)"
            }
            
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        
    }


}




