//
//  Appearance.swift
//  Dubbidson
//
//  Created by matsuosh on 2015/12/15.
//  Copyright © 2015年 matsuosh. All rights reserved.
//

import Foundation
import Chameleon

class Appearance {

    static let sharedInstance = Appearance()

    enum Color {
        case Main
        case Sub
        func withUIColor() -> UIColor {
            switch self {
            case .Main:
                // ライムグリーン
                return UIColor(hexString: "7ED321")
            case .Sub:
                // ブルー
                return UIColor(hexString: "385BDA")
            }
        }
        
    }

    func apply() {
        // Tab bar
        UITabBar.appearance().backgroundColor = UIColor.mainColor
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().shadowImage = UIImage()
        // Navigation bar
        UINavigationBar.appearance().backgroundColor = UIColor.whiteColor()
        // Slider
        UISlider.appearance().tintColor = UIColor.subColor
        UISlider.appearance().setMinimumTrackImage(R.image.minimumTrack?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        //UISlider.appearance().setMinimumTrackImage(R.image.minimumTrack, forState: .Normal)
        UISlider.appearance().setMaximumTrackImage(R.image.maximumTrack, forState: .Normal)
        //UISlider.appearance().setThumbImage(R.image.thumbTrack, forState: .Normal)
        UISlider.appearance().setThumbImage(R.image.thumbTrack?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        // Progress view
        UIProgressView.appearance().tintColor = Color.Sub.withUIColor()
    }
}

extension UIColor {
    
    static var mainColor: UIColor {
        return Appearance.Color.Main.withUIColor()
    }

    static var subColor: UIColor {
        return Appearance.Color.Sub.withUIColor()
    }
}