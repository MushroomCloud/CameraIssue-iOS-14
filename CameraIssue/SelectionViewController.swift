//
//  SelectionViewController.swift
//  CameraIssue
//
//  Created by Rayman Rosevear on 2020/10/05.
//

import UIKit

class SelectionViewController: UITableViewController
{
    @IBSegueAction func instantiateNoPreviewController(_ coder: NSCoder) -> CameraViewController?
    {
        return CameraViewController(coder: coder, previewType: .none)
    }
    
    @IBSegueAction func instantiateVideoLayerPreviewController(_ coder: NSCoder) -> CameraViewController?
    {
        return CameraViewController(coder: coder, previewType: .videoPreviewLayer)
    }
    
    @IBSegueAction func instantiateVideoOutputDelegateController(_ coder: NSCoder) -> CameraViewController?
    {
        return CameraViewController(coder: coder, previewType: .videoDataOutput)
    }
    
    @IBSegueAction func instantiateLayerAndDelegatePreviewController(_ coder: NSCoder) -> CameraViewController?
    {
        return CameraViewController(coder: coder, previewType: .layerAndDelegate)
    }
}
