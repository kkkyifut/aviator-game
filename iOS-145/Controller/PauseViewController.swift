import UIKit

final class PauseViewController: UIViewController {
    private let musicPlayer = MusicPlayer.shared
    
    @IBOutlet private var scoreLabel: UILabel!
    @IBOutlet private var recordLabel: UILabel!
    
    @IBOutlet private var pauseFrameView: UIView!
    @IBOutlet private var continueButton: UIButton!
    @IBOutlet private var menuButton: UIButton!
    @IBOutlet private var blueGlow: UIImageView!
    
    @IBAction func continuePlayButton(_ sender: UIButton) {
        createAnimForExitFromPause()
    }
    
    @IBAction func toMenuScene(_ sender: UIButton) {
        musicPlayer.playSoundSecond(withEffect: "Transition")
        let transition = CATransition()
        transition.duration = 0.4
        navigationController?.view.layer.add(transition, forKey: kCATransition)
        navigationController?.popToRootViewController(animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 5, green: 24, blue: 73).withAlphaComponent(0.8)
        getFrameButtons()
        musicPlayer.playSoundSecond(withEffect: "Pause")
    
        createAnimForPauseFrame()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        createResult()
    }
        
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func createResult() {
        scoreLabel.text = "\(LevelRatings.shared.getCurrentSessionRating() + LevelRatings.shared.getCurrentRating())"
        recordLabel.text = "\(LevelRatings.shared.getMaxRating())"
    }
    
    private func createAnimForPauseFrame() {
        continueButton.alpha = 0
        menuButton.alpha = 0
        
        blueGlow.alpha = 0
        blueGlow.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        pauseFrameView.alpha = 0
        pauseFrameView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        
        UIView.animate(withDuration: 0.35, delay: 0.3, animations: { [self] in
            blueGlow.alpha = 1
            blueGlow.transform = .identity
            pauseFrameView.alpha = 1
            pauseFrameView.transform = .identity
        }) { [self] _ in
            createAnimForButtons()
        }
    }
    
    private func createAnimForButtons() {
        let continueButtonOriginY = continueButton.frame.origin.y
        continueButton.frame.origin.y = self.view.frame.height + continueButton.frame.height
        let menuButtonOriginY = menuButton.frame.origin.y
        menuButton.frame.origin.y = self.view.frame.height + menuButton.frame.height
        
        continueButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        menuButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        continueButton.alpha = 1
        menuButton.alpha = 1
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveLinear, animations: { [self] in
            continueButton.frame.origin.y = continueButtonOriginY + 50
            continueButton.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
        })
        UIView.animate(withDuration: 0.2, delay: 0.3, options: .curveLinear, animations: { [self] in
            continueButton.frame.origin.y = continueButtonOriginY
            continueButton.transform = .identity
        }) { [self] _ in
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveLinear, animations: { [self] in
                menuButton.frame.origin.y = menuButtonOriginY + 50
                menuButton.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            })
            UIView.animate(withDuration: 0.2, delay: 0.3, options: .curveLinear, animations: { [self] in
                menuButton.frame.origin.y = menuButtonOriginY
                menuButton.transform = .identity
            })
        }
    }
    
    private func createAnimForExitFromPause() {
        musicPlayer.playSoundSecond(withEffect: "Transition")
        UIView.animate(withDuration: 0.35, delay: 0.0, options: .curveLinear, animations: { [self] in
            pauseFrameView.frame.origin.y = -pauseFrameView.frame.height
            continueButton.frame.origin.y = self.view.frame.height + continueButton.frame.height
            menuButton.frame.origin.y = self.view.frame.height + continueButton.frame.height + menuButton.frame.height * 1.5
            view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            blueGlow.alpha = 0.0
            pauseFrameView.alpha = 0.5
            continueButton.alpha = 0.5
            menuButton.alpha = 0.5
        }) { [self] _ in
            self.view.removeFromSuperview()
            self.removeFromParent()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationPause"), object: nil, userInfo: nil)
        }
    }
    
    private func getFrameButtons() {
        
        switch CGFloat.currentHeight {
            case .iPhone8Plus:
                menuButton.translatesAutoresizingMaskIntoConstraints = false
                recordLabel.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    menuButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -16),
                    recordLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 53),
                ])
            case .iPhone8:
                menuButton.translatesAutoresizingMaskIntoConstraints = false
                recordLabel.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    menuButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -16),
                    recordLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 47),
                ])
            case .iPhoneSE1:
                menuButton.translatesAutoresizingMaskIntoConstraints = false
                recordLabel.translatesAutoresizingMaskIntoConstraints = false
                scoreLabel.font = scoreLabel.font.withSize(18)
                recordLabel.font = recordLabel.font.withSize(18)
                NSLayoutConstraint.activate([
                    menuButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -16),
                    recordLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 38),
                ])
            default: break
        }
    }
}
