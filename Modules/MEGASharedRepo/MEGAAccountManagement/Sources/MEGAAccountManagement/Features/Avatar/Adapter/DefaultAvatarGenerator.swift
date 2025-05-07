// Copyright © 2023 MEGA Limited. All rights reserved.

import CoreGraphics
import UIKit

struct DefaultAvatarGenerator: DefaultAvatarGenerating {
    enum Error: Swift.Error {
        case failedToGetCurrentContext
        case failedToGetImageFromCurrentContext
    }

    func generate(
        initials: String,
        backgroundColor: ColorHexCode,
        secondaryBackgroundColor: ColorHexCode,
        isRightToLeftLanguage: Bool
    ) async throws -> UIImage {
        try drawAvatar(
            forInitials: initials,
            size: CGSize(width: 100, height: 100),
            backgroundColor: colorFromHexString(backgroundColor),
            secondaryBackgroundColor: colorFromHexString(secondaryBackgroundColor),
            textColor: .white,
            font: .systemFont(ofSize: 50),
            isRightToLeftLanguage: isRightToLeftLanguage
        )
    }

    // swiftlint:disable:next function_parameter_count
    private func drawAvatar(
        forInitials initials: String,
        size imageSize: CGSize,
        backgroundColor: UIColor,
        secondaryBackgroundColor: UIColor,
        textColor: UIColor,
        font: UIFont,
        isRightToLeftLanguage: Bool
    ) throws -> UIImage {
        UIGraphicsBeginImageContextWithOptions(imageSize, false, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }

        guard let context = UIGraphicsGetCurrentContext() else {
            throw Error.failedToGetCurrentContext
        }

        drawBackground(
            in: context,
            size: imageSize,
            primaryColor: backgroundColor,
            secondaryColor: secondaryBackgroundColor
        )

        drawText(
            initials,
            in: context,
            size: imageSize,
            textColor: textColor,
            font: font,
            isRTL: isRightToLeftLanguage
        )

        if let avatar = UIGraphicsGetImageFromCurrentImageContext() {
            return avatar
        } else {
            throw Error.failedToGetImageFromCurrentContext
        }
    }

    private func drawBackground(
        in context: CGContext,
        size: CGSize,
        primaryColor: UIColor,
        secondaryColor: UIColor
    ) {
        let rect = CGRect(origin: .zero, size: size)
        let gradientImage = createGradientImage(
            size: size,
            primaryColor: primaryColor,
            secondaryColor: secondaryColor
        )
        context.draw(gradientImage.cgImage!, in: rect)
    }

    private func createGradientImage(
        size: CGSize,
        primaryColor: UIColor,
        secondaryColor: UIColor
    ) -> UIImage {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(origin: .zero, size: size)
        gradientLayer.colors = [
            secondaryColor.cgColor,
            // Repeat the secondary color to extend its dominance
            secondaryColor.cgColor,
            primaryColor.cgColor
        ]

        // Make the gradient go from bottom left to top right
        gradientLayer.startPoint = .zero
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)

        // Adjust the color locations to control the color gradiency
        gradientLayer.locations = [0.0, 0.2, 1.0]

        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return image
    }

    // swiftlint:disable:next function_parameter_count
    private func drawText(
        _ text: String,
        in context: CGContext,
        size: CGSize,
        textColor: UIColor,
        font: UIFont,
        isRTL: Bool
    ) {
        let radius: CGFloat = size.width / 2
        let dict: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textColor
        ]

        let textSize = text.size(withAttributes: dict)

        let xFactor: CGFloat = isRTL ? -1 : 1
        text.draw(
            in: CGRect(
                x: xFactor * (radius - textSize.width / 2),
                y: radius - font.lineHeight / 2,
                width: textSize.width,
                height: textSize.height
            ),
            withAttributes: dict
        )
    }

    private func colorFromHexString(_ hexString: ColorHexCode) -> UIColor {
        var colorString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        if colorString.hasPrefix("#") {
            colorString.remove(at: colorString.startIndex)
        }

        var rgbValue: UInt64 = 0
        Scanner(string: colorString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0xFF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0xFF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
