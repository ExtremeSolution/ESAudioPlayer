//
//  UIImageView+SetImageFromURL.swift
//  ESAudioPlayer_Example
//
//  Created by Mario Mouris on 14/12/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

extension UIImageView {
    func setImage(
        fromURL url: URL
    ) {
        URLSession.shared.dataTask(
            with: url,
            completionHandler: { (data, _, error) in
                guard let data = data,
                      error == nil else { return }
                DispatchQueue.main.async { [weak self] in
                    self?.image = UIImage(data: data)
                }
            }
        ).resume()
    }
}
