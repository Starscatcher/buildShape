import UIKit
import Foundation

class Shape: UIView {

    var circle: Bool = false
    let width: Double = 100.0
    let height: Double = 100.0
    let x: CGFloat = 0
    let y: CGFloat = 0
    
    init(x: Double, y: Double) {
        super.init(frame: CGRect(x: x - width / 2 , y: y - height / 2 , width: width, height: height))
        
        self.backgroundColor = randomColor()
        if (arc4random_uniform(2) == 0) {
            self.layer.cornerRadius = CGFloat(width / 2)
            circle = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func randomColor() -> UIColor {
        return UIColor(red:   CGFloat(arc4random()) / CGFloat(UInt32.max),
                       green: CGFloat(arc4random()) / CGFloat(UInt32.max),
                       blue:  CGFloat(arc4random()) / CGFloat(UInt32.max),
                       alpha: 1.0)
    }

    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        if (self.circle == true) {
            return .ellipse
        }
        else {
            return .rectangle
        }
    }
}
