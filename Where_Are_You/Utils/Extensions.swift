//
//  Extensions.swift
//  Where_Are_You
//
//  Created by 오정석 on 25/5/2024.
//

import UIKit
import SwiftUI

// MARK: - UIViewController
extension UIViewController {
    func configureNavigationBar(title: String, backButtonAction: Selector? = nil, showBackButton: Bool = true) {
        Utilities.createNavigationBar(for: self, title: title, backButtonAction: backButtonAction, showBackButton: showBackButton)
    }
}

// MARK: - UIColor
extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
    static let brandColor = UIColor.rgb(red: 123, green: 80, blue: 255)
    static let letterBrandColor = UIColor.rgb(red: 98, green: 54, blue: 233)
    static let lightpurple = UIColor.rgb(red: 146, green: 134, blue: 255)
    static let warningColor = UIColor.rgb(red: 225, green: 49, blue: 49)
    static let scheduleDateColor = UIColor.rgb(red: 252, green: 47, blue: 47)
    static let popupButtonColor = UIColor.rgb(red: 81, green: 70, blue: 117)
    static let alertActionButtonColor = UIColor.rgb(red: 224, green: 158, blue: 255)
    
    static let color5 = UIColor.rgb(red: 5, green: 5, blue: 5)
    static let color17 = UIColor.rgb(red: 17, green: 17, blue: 17)
    static let color29 = UIColor.rgb(red: 29, green: 29, blue: 29)
    static let color34 = UIColor.rgb(red: 34, green: 34, blue: 34)
    static let color51 = UIColor.rgb(red: 51, green: 51, blue: 51)
    static let color5769 = UIColor.rgb(red: 57, green: 69, blue: 255)
    static let color57125 = UIColor.rgb(red: 57, green: 125, blue: 255)
    static let color68 = UIColor.rgb(red: 68, green: 68, blue: 68)
    static let color81 = UIColor.rgb(red: 81, green: 70, blue: 117)
    static let color102 = UIColor.rgb(red: 102, green: 102, blue: 102)
    static let color118 = UIColor.rgb(red: 118, green: 118, blue: 118)
    static let color153 = UIColor.rgb(red: 153, green: 153, blue: 153)
    static let color160 = UIColor.rgb(red: 160, green: 160, blue: 160)
    static let color171 = UIColor.rgb(red: 171, green: 171, blue: 171)
    static let color172 = UIColor.rgb(red: 172, green: 172, blue: 172)
    static let color190 = UIColor.rgb(red: 190, green: 190, blue: 190)
    static let color191 = UIColor.rgb(red: 191, green: 191, blue: 191)
    static let color212 = UIColor.rgb(red: 212, green: 212, blue: 212)
    static let color221 = UIColor.rgb(red: 221, green: 221, blue: 221)
    static let color223 = UIColor.rgb(red: 223, green: 223, blue: 223)
    static let color231 = UIColor.rgb(red: 231, green: 231, blue: 231)
    static let color235 = UIColor.rgb(red: 235, green: 235, blue: 235)
    static let color240 = UIColor.rgb(red: 240, green: 240, blue: 240)
    static let color242 = UIColor.rgb(red: 242, green: 242, blue: 242)
    static let color249 = UIColor.rgb(red: 249, green: 249, blue: 249)
    static let color255125 = UIColor.rgb(red: 255, green: 125, blue: 150)
    static let color25569 = UIColor.rgb(red: 255, green: 69, blue: 69)
}

// MARK: - UIFont

extension UIFont {
    static func pretendard(Ttangsbudae weight: UIFont.Weight, fontSize: CGFloat) -> UIFont {
        
        var weightString: String
        
        switch weight {
        case .bold:
            weightString = "OTTtangsbudaejjigaeB"
        case .light:
            weightString = "OTTtangsbudaejjigaeL"
        case .medium:
            weightString = "OTTtangsbudaejjigaeLM"
        default:
            weightString = "Regular"
        }
        
        return UIFont(name: "\(weightString)", size: fontSize) ?? .systemFont(ofSize: fontSize, weight: weight)
    }
    
    static func pretendard(NotoSans weight: UIFont.Weight, fontSize: CGFloat) -> UIFont {
        
        var weightString: String
        
        switch weight {
        case .bold:
            weightString = "NotoSansKR-Bold"
        case .light:
            weightString = "NotoSansKR-Light"
        case .medium:
            weightString = "NotoSansKR-Medium"
        default:
            weightString = "Regular"
        }
        
        return UIFont(name: "\(weightString)", size: fontSize) ?? .systemFont(ofSize: fontSize, weight: weight)
    }
}

extension Font {
    static func pretendard(NotoSans weight: Font.Weight, fontSize: CGFloat) -> Font {
        let uiFontWeight: UIFont.Weight
        switch weight {
        case .regular: uiFontWeight = .regular
        case .bold: uiFontWeight = .bold
        case .light: uiFontWeight = .light
        case .medium: uiFontWeight = .medium
        default: uiFontWeight = .regular
        }
        return Font(UIFont.pretendard(NotoSans: uiFontWeight, fontSize: fontSize))
    }
}

extension UIImage {
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func toBase64() -> String? {
        guard let imageData = self.jpegData(compressionQuality: 1.0) else {
            return nil
        }
        return imageData.base64EncodedString()
    }
}

// MARK: - UIImageView

extension UIImageView {
    func setImage(from urlString: String, placeholder: UIImage? = nil) {
        // 기본 이미지 설정
        self.image = placeholder
        
        ImageLoader.shared.loadImage(from: urlString) { [weak self] loadedImage in
            guard let self = self else { return }
            if let loadedImage = loadedImage {
                self.image = loadedImage
            }
        }
    }
}

extension UIImageView {
    func loadImage(from urlString: String?, placeholder: UIImage? = UIImage(named: "basic_profile_image")) {
        // 서버에서 비어있는 URL이 올 경우 기본 이미지 설정
        guard let urlString = urlString, !urlString.isEmpty, let url = URL(string: urlString) else {
            self.image = placeholder
            return
        }

        // 네트워크에서 이미지를 비동기로 가져오기
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let data = data, let image = UIImage(data: data) {
                    self.image = image
                } else {
                    self.image = placeholder // 요청 실패 시 기본 이미지
                }
            }
        }.resume()
    }
}
