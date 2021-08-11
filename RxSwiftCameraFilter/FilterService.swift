//
//  FilterService.swift
//  RxSwiftCameraFilter
//
//  Created by usr on 2021/8/3.
//

import Foundation
import UIKit
import CoreImage
import RxSwift

class FilterService {
    private var context: CIContext
    
    init() {
        self.context = CIContext()
    }
    
    func applyFilter(to inputImage: UIImage) -> Observable<UIImage> {
        // ⭐️  Observable.create
        return Observable.create { observer in
            self.applyFilter(to: inputImage) { filteredImage in
                observer.onNext(filteredImage)
            }
            return Disposables.create()
        }
    }
    
    /// 將圖片套用濾鏡並返回
    private func applyFilter(to inputImage: UIImage,
                     completion: @escaping ((UIImage) -> ())) {
        
        let filter = CIFilter(name: "CICMYKHalftone")!
        filter.setValue(5.0, forKey: kCIInputWidthKey)
        
        if let sourceImage = CIImage(image: inputImage) {
            filter.setValue(sourceImage, forKey: kCIInputImageKey)
            
            if let cgImage = self.context.createCGImage(filter.outputImage!,
                                                        from: filter.outputImage!.extent) {
                
                let processedImage = UIImage(cgImage: cgImage,
                                             scale: inputImage.scale,
                                             orientation: inputImage.imageOrientation)
                completion(processedImage)
            }
        }
    }
}
