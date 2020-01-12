//
//  GameButton.swift
//  RemoteCar ARKit
//
//  Created by Turker Koc on 15.07.2019.
//  Copyright © 2019 Turker Koc. All rights reserved.
//

import Foundation
import UIKit

class GameButton : UIButton
{
    var callback :() -> ()
    private var timer: Timer!
    
    //you want to call a function back when evet actually happen
    init(frame: CGRect, callback: @escaping () -> ()) //Callback is what event you want to triger
    {
        self.callback = callback
        super.init(frame: frame)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: {(timer :Timer) in
            self.callback() //repeatedly calling back
        })
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.timer.invalidate() //when you invalidate timer it will stop calling it self back
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
