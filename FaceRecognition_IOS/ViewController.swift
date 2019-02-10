
//  Created by MacBook  on 08/12/2017.
//  Copyright © 2017 Onurcan Yurt. All rights reserved.
//

import UIKit
import AVKit
import Vision

//Machine Learning kısmına gecelim oncelikle vision u import ettik

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    //AVCaptureVideoDataOutputSampleBufferDelegate i sinifimizi dahil ettik

    @IBOutlet weak var label: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //info.plist ten izin almayı unutmuyoruz(camera usage)
        
        //Burada öncelikle kamerayı olusturdugumuz kodları yazıyoruz
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo //ekranda gorulecek kameranın boyutu
        
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
    
    //Capture video output ile ilgili bi metodumuzu override ettik
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        //projemize dahil ettigimiz Resnet50 modelimizi burada tanımladık ve requeste ekledik
        guard let model = try? VNCoreMLModel(for: people().model) else{ return }
        let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
            
            
            //burada sonuclari yazdırıyoruz
            //tum sonuclara results degiskeni ile eristik
            guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
            guard let firstObservation = results.first else { return }
            //firstObservation ile en kesin sonuca eristik
            
            //ve label e yazdırdık
            DispatchQueue.main.async {
                
                self.label.text = " \(firstObservation.identifier) \(firstObservation.confidence)"
            }
            
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        
    }


}




