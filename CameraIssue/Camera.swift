//
//  Camera.swift
//  CameraIssue
//
//  Created by Rayman Rosevear on 2020/10/05.
//

import AVFoundation

enum CameraError: Error
{
    case couldNotFindCamera
    case unsupportedConfiguration
}

class Camera
{
    let session: AVCaptureSession
    let videoInput: AVCaptureDeviceInput
    let inputCamera: AVCaptureDevice
    let photoOutput: AVCapturePhotoOutput
    
    init(position: AVCaptureDevice.Position, videoDelegate: AVCaptureVideoDataOutputSampleBufferDelegate?) throws
    {
        guard let inputCamera = AVCaptureDevice.inputDeviceWith(position: position) else
        {
            throw CameraError.couldNotFindCamera
        }
        
        let session = AVCaptureSession()
        session.beginConfiguration()
        
        let videoInput = try AVCaptureDeviceInput(device: inputCamera)
        guard session.canAddInput(videoInput) else
        {
            throw CameraError.unsupportedConfiguration
        }
        session.addInput(videoInput)
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.alwaysDiscardsLateVideoFrames = false
        
        if let videoDelegate = videoDelegate
        {
            let processQueue = DispatchQueue.global(qos: .userInteractive)
            videoOutput.setSampleBufferDelegate(videoDelegate, queue: processQueue)
        }
        
        guard session.canAddOutput(videoOutput) else
        {
            throw CameraError.unsupportedConfiguration
        }
        
        session.addOutput(videoOutput)
        session.sessionPreset = .photo
        
        let photoOutput = AVCapturePhotoOutput()
        photoOutput.isHighResolutionCaptureEnabled = true
        
        guard session.canAddOutput(photoOutput) else
        {
            throw CameraError.unsupportedConfiguration
        }
        session.addOutput(photoOutput)
        
        session.commitConfiguration()
        
        self.session = session
        self.videoInput = videoInput
        self.inputCamera = inputCamera
        self.photoOutput = photoOutput
    }
    
    func start()
    {
        self.session.startRunning()
    }
    
    func stop()
    {
        self.session.stopRunning()
    }
    
    func capture(delegate: AVCapturePhotoCaptureDelegate)
    {
        let settings = AVCapturePhotoSettings(format: [
            // I tried all the different format's, they all produced the issue
            kCVPixelBufferPixelFormatTypeKey as String: photoOutput.availablePhotoPixelFormatTypes[0]
        ])
        settings.isHighResolutionPhotoEnabled = true
        
        self.photoOutput.capturePhoto(with: settings, delegate: delegate)
    }
}

private extension AVCaptureDevice
{
    static func inputDeviceWith(position: AVCaptureDevice.Position) -> AVCaptureDevice?
    {
        let discovery = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: position)
        return discovery.devices.first
    }
}
