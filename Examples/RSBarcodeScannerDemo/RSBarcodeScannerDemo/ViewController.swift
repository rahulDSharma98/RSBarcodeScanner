//
//  ViewController.swift
//  RSBarcodeScannerDemo
//
//  Created by MACM62 on 07/04/26.
//

import UIKit
import RSBarcodeScanner
import AVFoundation

class ViewController: UIViewController {

    private let scanButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start Scanning", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        view.addSubview(scanButton)
        scanButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scanButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scanButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        scanButton.addTarget(self, action: #selector(startScanner), for: .touchUpInside)
    }

    @objc private func startScanner() {
        var config = ScannerConfiguration()
        
        config.supportedTypes = [.qr]

        let scanner = BarcodeScannerViewController(configuration: config)
        scanner.delegate = self

        present(scanner, animated: true)
    }
}

extension ViewController: BarcodeScannerDelegate {

    func barcodeScanner(_ scanner: BarcodeScannerViewController, didScan code: String) {
        scanner.dismiss(animated: true)

        print("Scanned:", code)
    }

    func barcodeScannerDidCancel(_ scanner: BarcodeScannerViewController) {
        scanner.dismiss(animated: true)
    }

    func barcodeScanner(_ scanner: BarcodeScannerViewController, didFail error: BarcodeScannerError) {
        print("Error:", error)
    }
}
