//
//  ScannerConfiguration.swift
//  BarcodeScannerSDK
//
//  Created by MACM62 on 02/04/26.
//

import Foundation
import AVFoundation

public struct ScannerConfiguration {

    public var supportedTypes: [AVMetadataObject.ObjectType]
    public var isFlashEnabled: Bool
    public var isAutoZoomEnabled: Bool

    public init(supportedTypes: [AVMetadataObject.ObjectType] = AVMetadataObject.ObjectType.barcodeScannerMetadata, isFlashEnabled: Bool = false, isAutoZoomEnabled: Bool = false) {
        self.supportedTypes = supportedTypes
        self.isFlashEnabled = isFlashEnabled
        self.isAutoZoomEnabled = isAutoZoomEnabled
    }
}
