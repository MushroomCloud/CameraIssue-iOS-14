//
//  CameraViewController.swift
//  CameraIssue
//
//  Created by Rayman Rosevear on 2020/10/05.
//

import AVFoundation
import UIKit
import VideoToolbox

enum PreviewType: Equatable
{
    case none
    case videoPreviewLayer
    case videoDataOutput
    case layerAndDelegate
}

class CameraViewController: UIViewController
{
    var camera: Camera?
    var previewType: PreviewType
    
    @IBOutlet weak var previewView: PreviewView!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var photoImageView: UIImageView!
    
    required init?(coder: NSCoder)
    {
        self.previewType = .videoPreviewLayer
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder, previewType: PreviewType)
    {
        self.previewType = previewType
        super.init(coder: coder)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        let camera: Camera
        switch self.previewType
        {
        case .none:
            self.title = "No Preview"
            camera = try! Camera(position: .front, videoDelegate: nil)
            
        case .videoPreviewLayer:
            self.title = "AVCaptureVideoPreviewLayer"
            camera = try! Camera(position: .front, videoDelegate: nil)
            previewView.session = camera.session

        case .videoDataOutput:
            self.title = "AVCaptureVideoDataOutputSampleBufferDelegate"
            camera = try! Camera(position: .front, videoDelegate: self)
            
        case .layerAndDelegate:
            self.title = "Both Layer And Delegate Preview"
            camera = try! Camera(position: .front, videoDelegate: self)
            previewView.session = camera.session
        }
        
        camera.start()
        self.camera = camera
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        self.camera?.stop()
    }
    
    @IBAction func capture(_ sender: Any)
    {
        self.camera?.capture(delegate: self)
    }
    
    func updateOnMainThread(_ updates: () -> Void)
    {
        if Thread.current.isMainThread
        {
            updates()
        }
        else
        {
            DispatchQueue.main.sync(execute: updates)
        }
    }
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate
{
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection)
    {
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        let image = UIImage(pixelBuffer: pixelBuffer)!
        
        self.updateOnMainThread
        {
            self.previewImageView.image = image
        }
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate
{
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?)
    {
        let image = UIImage(pixelBuffer: photo.pixelBuffer!)!
        self.updateOnMainThread
        {
            self.photoImageView.image = image
        }
    }
}

extension UIImage
{
    convenience init?(pixelBuffer: CVPixelBuffer)
    {
        var _cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &_cgImage)
        
        guard let cgImage = _cgImage else
        {
            return nil
        }
        self.init(cgImage: cgImage)
    }
}
