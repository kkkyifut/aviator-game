import UIKit

class DestroyItemAnimation {
    private var animationFrames: [UIImage] = []
    private var imageViewDestroyItem = UIImageView(frame: UIScreen.main.bounds)
    
    private func createAnimationFrames() -> [UIImage] {
        for i in 1...13 {
            let temp: String = i < 10 ? "0\(i)" : "\(i)"
            animationFrames.append(GameApp.imageProvider(named: "lash Radial_000\(temp)")!)
        }
        return animationFrames
    }
    
    func startAnimation(view: UIView) -> UIImageView {
        imageViewDestroyItem.frame = CGRect(origin: view.bounds.origin, size: CGSize(width: view.bounds.width * 1.5, height: view.bounds.width * 1.5))
        imageViewDestroyItem.layer.position = CGPoint(x: view.frame.midX, y: view.frame.midY)
        
        imageViewDestroyItem.animationImages = createAnimationFrames()
        
        let frameDuration = 1.0 / 24.0
        imageViewDestroyItem.animationDuration = frameDuration * Double(animationFrames.count)
        
        imageViewDestroyItem.animationRepeatCount = 1
        imageViewDestroyItem.startAnimating()
        
        return imageViewDestroyItem
    }
}
