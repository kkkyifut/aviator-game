import UIKit

class TransitionAnimation {
    static let shared = TransitionAnimation()
    private var imageViewTransition = UIImageView(frame: UIScreen.main.bounds)
    private var animationFrames: [UIImage] = []
    
    private func createAnimation() -> [UIImage] {
        for i in 58...67 {
            animationFrames.append(GameApp.imageProvider(named: "Transition_000\(i)")!)
        }
        return animationFrames
    }
    
    func startAnimation() -> UIImageView {
        stopAnimation()
        imageViewTransition.animationImages = createAnimation()
        
        let frameDuration = 1.0 / 23.0
        imageViewTransition.animationDuration = frameDuration * Double(animationFrames.count)
        
        imageViewTransition.animationRepeatCount = 1
        imageViewTransition.startAnimating()
        
        return imageViewTransition
    }
    
    func stopAnimation() {
        animationFrames = []
        imageViewTransition.stopAnimating()
        imageViewTransition.removeFromSuperview()
    }
}
