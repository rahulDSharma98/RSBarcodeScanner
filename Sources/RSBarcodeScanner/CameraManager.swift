//
//  CameraManager.swift
//  BarcodeScannerSDK
//
//  Created by MACM62 on 02/04/26.
//

import Foundation
import AVFoundation

final class CameraManager {

    let session = AVCaptureSession()
    var videoDevice: AVCaptureDevice?
    let metadataOutput = AVCaptureMetadataOutput()

    func startSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
    }

    func stopSession() {
        session.stopRunning()
    }
}
