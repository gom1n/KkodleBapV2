//
//  Image.swift
//  KkodleBap
//
//  Created by gomin on 9/1/25.
//

import UIKit
import ImageIO

extension UIImageView {
    func loadGIF(named name: String) {
        guard let path = Bundle.main.path(forResource: name, ofType: "gif"),
              let data = NSData(contentsOfFile: path) else {
            print("GIF 파일을 찾을 수 없음")
            return
        }
        self.image = UIImage.animatedImageWithGIFData(data as Data)
    }
    
    func loadGIF(data: Data) {
        self.image = UIImage.animatedImageWithGIFData(data)
    }
}

extension UIImage {
    static func animatedImageWithGIFData(_ data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        
        var images = [UIImage]()
        var duration: TimeInterval = 0
        
        let count = CGImageSourceGetCount(source)
        for i in 0..<count {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(UIImage(cgImage: cgImage))
                
                // 프레임마다 딜레이 시간 추출
                let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as Dictionary?
                if let gifDict = properties?[kCGImagePropertyGIFDictionary] as? NSDictionary,
                   let delay = gifDict[kCGImagePropertyGIFDelayTime] as? NSNumber {
                    duration += delay.doubleValue
                }
            }
        }
        
        return UIImage.animatedImage(with: images, duration: duration)
    }
}
