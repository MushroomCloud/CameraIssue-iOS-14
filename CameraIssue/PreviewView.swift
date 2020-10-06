//
//  PreviewView.swift
//  CameraIssue
//
//  Created by Rayman Rosevear on 2020/10/05.
//

import UIKit
import AVFoundation

class PreviewView: UIView
{
    var videoPreviewLayer: AVCaptureVideoPreviewLayer
    {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
    var session: AVCaptureSession?
    {
        get
        {
            return videoPreviewLayer.session
        }
        set
        {
            videoPreviewLayer.session = newValue
        }
    }
    
    override class var layerClass: AnyClass
    {
        return AVCaptureVideoPreviewLayer.self
    }
}
