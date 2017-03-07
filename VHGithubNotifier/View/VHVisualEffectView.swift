//
//  VHVisualEffectView.swift
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/3/7.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

import Cocoa

@objc class VHVisualEffectView: NSVisualEffectView {
    
    override init(frame frameRect: NSRect) {
        self.tintColor = NSColor.init(red: 0, green: 0, blue: 0, alpha: 0);
        super.init(frame:frameRect);
    }
    
    required init?(coder: NSCoder) {
        self.tintColor = NSColor.init(red: 0, green: 0, blue: 0, alpha: 0);
        super.init(coder: coder);
    }
    
    var tintColor: NSColor {
        willSet {
            
        }
        didSet {
            for sublayer: CALayer in self.layer!.sublayers! {
                if sublayer.name == "ClearCopyLayer" {
                    sublayer.backgroundColor = tintColor.cgColor
                    break
                }
            }
        }
    }
}
