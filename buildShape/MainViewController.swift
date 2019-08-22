import UIKit
import CoreMotion

class MainViewController: UIViewController {

    var animator = UIDynamicAnimator()
    var gravity = UIGravityBehavior()
    var collision = UICollisionBehavior()
    var item = UIDynamicItemBehavior()
    let motion = CMMotionManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGesture(gesture: )))
        view.addGestureRecognizer(tap)
        
        animator = UIDynamicAnimator(referenceView: view)
        
        animator.addBehavior(gravity)
        
        collision.translatesReferenceBoundsIntoBoundary = true
        animator.addBehavior(collision)
        
        animator.addBehavior(item)
        item.elasticity = 0.8
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if motion.isAccelerometerAvailable {
            motion.accelerometerUpdateInterval = 0.2
            let queue = OperationQueue.main
            motion.startAccelerometerUpdates(to: queue, withHandler: accHandler)
        }
    }

    func accHandler(data: CMAccelerometerData?, error: Error?) {
        if let myData = data {
            let x = CGFloat(myData.acceleration.x)
            let y = CGFloat(myData.acceleration.y)
            let v = CGVector(dx: x, dy: -y)
            gravity.gravityDirection = v
        }
    }

    @objc func tapGesture(gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        let shapeView = Shape(x: Double(location.x), y: Double(location.y))
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panGesture(gesture: )))
        shapeView.addGestureRecognizer(pan)
        
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinchGesture(gesture: )))
        shapeView.addGestureRecognizer(pinch)
        
        let rotation = UIRotationGestureRecognizer(target: self, action: #selector(rotationGesture(gesture: )))
        shapeView.addGestureRecognizer(rotation)
        
        view.addSubview(shapeView)
        gravity.addItem(shapeView)
        collision.addItem(shapeView)
        item.addItem(shapeView)
    }

    @objc func pinchGesture(gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began:
            gravity.removeItem(gesture.view!)
            collision.removeItem(gesture.view!)
            item.removeItem(gesture.view!)
        case .ended:
            gravity.addItem(gesture.view!)
            collision.addItem(gesture.view!)
            item.addItem(gesture.view!)
        case .changed:
            gesture.view?.layer.bounds.size.height *= gesture.scale
            gesture.view?.layer.bounds.size.width *= gesture.scale
            if let gestureCopy = gesture.view! as? Shape {
                if (gestureCopy.circle) {
                    gesture.view!.layer.cornerRadius *= gesture.scale
                }
            }
            gesture.scale = 1
        default:
            break
        }
    }
    
    @objc func rotationGesture(gesture: UIRotationGestureRecognizer) {
        guard gesture.view != nil else {return}
        switch gesture.state {
        case .began:
            gravity.removeItem(gesture.view!)
        case .ended:
            gravity.addItem(gesture.view!)
        case .changed:
            gesture.view?.transform = (gesture.view?.transform.rotated(by: gesture.rotation))!
            animator.updateItem(usingCurrentState: gesture.view!)
            gesture.rotation = 0
        default:
            break
        }
    }
    
    @objc func panGesture(gesture: UIPanGestureRecognizer) {
        guard gesture.view != nil else {return}
        switch gesture.state {
        case .began:
            gravity.removeItem(gesture.view!)
        case .ended:
            gravity.addItem(gesture.view!)
        case .changed:
            gesture.view?.center = gesture.location(in: gesture.view?.superview)
            animator.updateItem(usingCurrentState: gesture.view!)
        default:
            break
        }
    }
}
