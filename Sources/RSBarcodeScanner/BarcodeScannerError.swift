//
//  BarcodeScannerError.swift
//  BarcodeScannerSDK
//
//  Created by MACM62 on 02/04/26.
//

import Foundation

public enum BarcodeScannerError: Error {
    case cameraPermissionDenied
    case cameraUnavailable
    case inputCreationFailed
    case metadataOutputFailed
}

public enum ScannerState: Equatable {
    case idle
    case scanning
    case processing
    case stopped
    case failed(Error)

    public static func == (lhs: ScannerState, rhs: ScannerState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle),
             (.scanning, .scanning),
             (.processing, .processing),
             (.stopped, .stopped):
            return true

        case (.failed, .failed):
            return true // ignore error comparison

        default:
            return false
        }
    }
}
