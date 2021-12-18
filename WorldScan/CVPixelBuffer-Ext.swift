//
//  CVPixelBuffer-Ext.swift
//  WorldScan
//
//  Created by Larry Li on 12/17/21.
//

import UIKit

extension CVPixelBuffer {
    func toUIImage() -> UIImage? {
         let image = CIImage(cvPixelBuffer: self)
         let context = CIContext(options:nil)
         guard let image = context.createCGImage(image, from: image.extent) else {return nil}
         return UIImage(cgImage: image)
    }
}
