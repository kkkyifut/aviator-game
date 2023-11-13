import UIKit

class FireWinAnimation {
    static let shared = FireWinAnimation()
    private var animationFrames: [UIImage] = []
    private var imageViewLightning = UIImageView(frame: UIScreen.main.bounds)
    
    private func createAnimation() -> [UIImage] {
        for i in 0...11 {
            let i: String = i < 10 ? "0\(i)" : "\(i)"
            animationFrames.append(GameApp.imageProvider(named: "Fire_000\(i)")!)
        }
        return animationFrames
    }
    
    func startAnimation(frame: CGRect) -> UIImageView {
        stopAnimation()
        imageViewLightning.animationImages = createAnimation()
        imageViewLightning.contentMode = .scaleAspectFit
        imageViewLightning.frame = frame
        
        let frameDuration = 1.0 / 24.0
        imageViewLightning.animationDuration = frameDuration * Double(animationFrames.count)
        
        imageViewLightning.animationRepeatCount = 1
        imageViewLightning.startAnimating()
        
        return imageViewLightning
    }
    
    private func stopAnimation() {
        animationFrames = []
        imageViewLightning.stopAnimating()
        imageViewLightning.removeFromSuperview()
    }
}
