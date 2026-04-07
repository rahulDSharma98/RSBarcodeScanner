//
//  BarcodeScannerViewController.swift
//  BarcodeScannerSDK
//
//  Created by MACM62 on 02/04/26.
//

import Foundation
import UIKit
import AVFoundation

@MainActor
public final class BarcodeScannerViewController: UIViewController {

    public weak var delegate: BarcodeScannerDelegate?
    
    public private(set) var state: ScannerState = .idle {
        didSet {
            // Optional: expose via callback later
            print("Scanner State: \(state)")
        }
    }
    
    private let config: ScannerConfiguration

    private let cameraManager = CameraManager()
    private let feedback = FeedbackManager()

    private var previewLayer: AVCaptureVideoPreviewLayer!
    private let overlay = ScannerOverlayView()

    private var lastCode: String?
    private var isProcessing = false

    // MARK: Zoom
    private var baseZoomFactor: CGFloat = 1.0
    private let zoomSmoothing: CGFloat = 0.2

    // MARK: INIT
    public init(configuration: ScannerConfiguration = ScannerConfiguration()) {
        self.config = configuration
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            // Fallback on earlier versions
        }
        
        setupGestures()
        setupLifecycleObservers()
        checkPermission()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        previewLayer?.frame = view.bounds
        overlay.frame = view.bounds
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        cameraManager.startSession()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        cameraManager.stopSession()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
    }
}

private extension BarcodeScannerViewController {
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    granted ? self.setupCamera() : self.delegate?.barcodeScanner(self, didFail: .cameraPermissionDenied)
                }
            }

        default:
            delegate?.barcodeScanner(self, didFail: .cameraPermissionDenied)
        }
    }

    func setupCamera() {
        guard let device = AVCaptureDevice.default(for: .video) else {
            delegate?.barcodeScanner(self, didFail: .cameraUnavailable)
            return
        }

        cameraManager.videoDevice = device

        do {
            let input = try AVCaptureDeviceInput(device: device)

            cameraManager.session.addInput(input)
            cameraManager.session.addOutput(cameraManager.metadataOutput)

            cameraManager.metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
            cameraManager.metadataOutput.metadataObjectTypes = config.supportedTypes

            //APPLY INITIAL FLASH STATE
            if config.isFlashEnabled && device.hasTorch {
                try device.lockForConfiguration()
                device.torchMode = .on
                device.unlockForConfiguration()
            }
            
            setupPreview()
            setupOverlay()
        } catch {
            delegate?.barcodeScanner(self, didFail: .inputCreationFailed)
        }
    }

    func setupPreview() {
        previewLayer = AVCaptureVideoPreviewLayer(session: cameraManager.session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
    }

    func setupOverlay() {
        overlay.frame = view.bounds
        view.addSubview(overlay)

        let width: CGFloat = view.bounds.width * 0.7
        let height: CGFloat = view.bounds.height * 0.15
        overlay.scanRect = CGRect(x: (view.bounds.width - width)/2, y: (view.bounds.height - height)/2, width: width, height: height)
    }
    
    func setState(_ newState: ScannerState) {
        state = newState
    }
    
    func updateRectOfInterest() {
        guard let output = cameraManager.session.outputs.first as? AVCaptureMetadataOutput else { return }

        let converted = previewLayer.metadataOutputRectConverted(fromLayerRect: overlay.scanRect)
        output.rectOfInterest = converted
    }
    
    func setupLifecycleObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    @objc func appDidBecomeActive() {
        if state == .scanning {
            cameraManager.startSession()
        }
    }

    @objc func appWillResignActive() {
        cameraManager.stopSession()
    }
}

private extension BarcodeScannerViewController {
    func setupGestures() {
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))

        view.addGestureRecognizer(pinch)
        view.addGestureRecognizer(tap)
    }

    @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard let device = cameraManager.videoDevice else { return }

        let maxZoom = min(device.activeFormat.videoMaxZoomFactor, 6.0)

        let newZoom = min(max(baseZoomFactor * gesture.scale, 1.0), maxZoom)

        switch gesture.state {
        case .changed:
            try? device.lockForConfiguration()
            device.videoZoomFactor = newZoom
            device.unlockForConfiguration()

        case .ended:
            baseZoomFactor = newZoom

        default:
            break
        }
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: view)
        
        guard let device = cameraManager.videoDevice else { return }

        let focusPoint = previewLayer.captureDevicePointConverted(fromLayerPoint: point)

        try? device.lockForConfiguration()

        if device.isFocusPointOfInterestSupported {
            device.focusPointOfInterest = focusPoint
            device.focusMode = .autoFocus
        }

        if device.isExposurePointOfInterestSupported {
            device.exposurePointOfInterest = focusPoint
            device.exposureMode = .continuousAutoExposure
        }

        device.unlockForConfiguration()
    }
}

private extension BarcodeScannerViewController {
    func handleAutoZoom(_ object: AVMetadataMachineReadableCodeObject) {
        guard config.isAutoZoomEnabled,
              let device = cameraManager.videoDevice,
              let transformed = previewLayer.transformedMetadataObject(for: object) else { return }

        let relativeWidth = transformed.bounds.width / view.bounds.width

        var targetZoom = device.videoZoomFactor

        if relativeWidth < 0.2 {
            targetZoom += 0.3
        } else if relativeWidth > 0.6 {
            targetZoom -= 0.3
        }

        let maxZoom = min(device.activeFormat.videoMaxZoomFactor, 6.0)
        targetZoom = min(max(targetZoom, 1.0), maxZoom)

        let smoothZoom = device.videoZoomFactor + (targetZoom - device.videoZoomFactor) * zoomSmoothing

        try? device.lockForConfiguration()
        device.videoZoomFactor = smoothZoom
        device.unlockForConfiguration()
    }
}

extension BarcodeScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    public func metadataOutput(_ output: AVCaptureMetadataOutput,
                               didOutput objects: [AVMetadataObject],
                               from connection: AVCaptureConnection) {

        guard state == .scanning else { return }
        
        guard let obj = objects.first as? AVMetadataMachineReadableCodeObject,
              let code = obj.stringValue else { return }

        setState(.processing)

        if config.isAutoZoomEnabled {
            handleAutoZoom(obj)
        }

        if code == lastCode { return }

        lastCode = code

        cameraManager.stopSession()

        feedback.playSuccess()
        delegate?.barcodeScanner(self, didScan: code)
        setState(.stopped)
    }
}

// MARK: - Public APIs
public extension BarcodeScannerViewController {
    //Toggle Torch
    func toggleTorch() -> Bool {
        guard let device = cameraManager.videoDevice,
              device.hasTorch else { return false }

        do {
            try device.lockForConfiguration()
            device.torchMode = (device.torchMode == .on) ? .off : .on
            device.unlockForConfiguration()
            
            return (device.torchMode == .on) ? true : false
        } catch {
            print("Torch toggle error: \(error)")
            
            return false
        }
    }

    //Explicit Torch Control
    func setTorch(enabled: Bool) {
        guard let device = cameraManager.videoDevice,
              device.hasTorch else { return }

        do {
            try device.lockForConfiguration()
            device.torchMode = enabled ? .on : .off
            device.unlockForConfiguration()
        } catch {
            print("Torch set error: \(error)")
        }
    }

    //Smooth Zoom
    func setZoom(to level: CGFloat) {
        guard let device = cameraManager.videoDevice else { return }

        let maxZoom = min(device.activeFormat.videoMaxZoomFactor, 6.0)
        let target = min(max(level, 1.0), maxZoom)

        let current = device.videoZoomFactor
        let newZoom = current + (target - current) * 0.2

        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = newZoom
            device.unlockForConfiguration()

            baseZoomFactor = newZoom
        } catch {
            print("Smooth zoom error: \(error)")
        }
    }

    //Restart scanning (single scan mode)
    func restartScanning() {
        lastCode = nil
        isProcessing = false
        cameraManager.startSession()
    }
    
    func reset() {
        lastCode = nil
        isProcessing = false
        cameraManager.stopSession()
    }
    
    func setScanArea(_ rect: CGRect) {
        overlay.scanRect = rect
        updateRectOfInterest()
    }
}
