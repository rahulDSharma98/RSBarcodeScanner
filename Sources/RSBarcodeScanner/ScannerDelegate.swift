//
//  ScannerDelegate.swift
//  BarcodeScannerSDK
//
//  Created by MACM62 on 02/04/26.
//

import Foundation

public protocol BarcodeScannerDelegate: AnyObject {
    func barcodeScanner(_ scanner: BarcodeScannerViewController, didScan code: String)
    func barcodeScannerDidCancel(_ scanner: BarcodeScannerViewController)
    func barcodeScanner(_ scanner: BarcodeScannerViewController, didFail error: BarcodeScannerError)
}
