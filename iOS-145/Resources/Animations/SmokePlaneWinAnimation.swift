import UIKit

class SmokePlaneWinAnimation {
    static let shared = SmokePlaneWinAnimation()
    private var imageViewTransition = UIImageView(frame: UIScreen.main.bounds)
    private var animationFrames: [UIImage] = []
    
    private func createAnimation() -> [UIImage] {
        for i in 0...22 {
            let i: String = i < 10 ? "0\(i)" : "\(i)"
            animationFrames.append(GameApp.imageProvider(named: "Smoke-2_000\(i)")!)
        }
        return animationFrames
    }
    
    func startAnimation(frame: CGRect) -> UIImageView {
        stopAnimation()
        imageViewTransition.animationImages = createAnimation()
        imageViewTransition.contentMode = .scaleAspectFit
        imageViewTransition.frame = frame
        
        let frameDuration = 1.0 / 23.0
        imageViewTransition.animationDuration = frameDuration * Double(animationFrames.count)
        
        imageViewTransition.animationRepeatCount = 1
        imageViewTransition.startAnimating()
        
        return imageViewTransition
    }
    
    private func stopAnimation() {
        animationFrames = []
        imageViewTransition.stopAnimating()
        imageViewTransition.removeFromSuperview()
    }
}
