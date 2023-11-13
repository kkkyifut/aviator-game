import UIKit

class ExpandableButton: UIButton {
    private let expandSize: CGFloat = 20.0
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let extendedBounds = bounds.insetBy(dx: -expandSize, dy: -expandSize)
        return extendedBounds.contains(point)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let extendedBounds = bounds.insetBy(dx: -expandSize, dy: -expandSize)
        return extendedBounds.contains(point) ? self : nil
    }
}
