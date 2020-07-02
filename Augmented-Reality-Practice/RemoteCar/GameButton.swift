//
//  GameButton.swift
//  Augmented-Reality-Practice
//
//  Created by Stephen Brundage on 3/6/20.
//  Copyright © 2020 Stephen Brundage. All rights reserved.
//

import UIKit

class GameButton: UIButton {

    var callback: () -> ()
    private var timer: Timer!
    
    init(frame: CGRect, callback: @escaping () -> ()) {
        self.callback = callback
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { [weak self](timer) in
            self?.callback()
        })
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.timer.invalidate()
    }

}
