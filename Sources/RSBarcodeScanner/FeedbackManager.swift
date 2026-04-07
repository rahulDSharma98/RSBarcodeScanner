//
//  FeedbackManager.swift
//  BarcodeScannerSDK
//
//  Created by MACM62 on 02/04/26.
//

import Foundation
import UIKit
import AudioToolbox

final class FeedbackManager {

    func playSuccess() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        AudioServicesPlaySystemSound(SystemSoundID(1057))
    }
}
