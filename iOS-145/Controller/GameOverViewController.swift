import UIKit

final class GameOverViewController: UIViewController {
    private let storage = UserDefaults.standard
    private let musicPlayer = MusicPlayer.shared
    private let currentHeight = UIScreen.main.nativeBounds.height
    
    private var bestResult = 0
    private var currentResult = 0
    
    @IBOutlet weak var currentResultCount: UILabel!
    @IBOutlet weak var bestResultCount: UILabel!
    
    @IBOutlet var gameOverFrame: UIView!
    @IBOutlet var restartButton: UIButton!
    @IBOutlet var menuButton: UIButton!
    
    
    @IBAction func restartButton(_ sender: UIButton) {
        musicPlayer.playSound(withEffect: "Transition")
        let transition = CATransition()
        transition.duration = 0.3
        navigationController?.view.layer.add(transition, forKey: kCATransition)
        
        let storyboard = GameApp.storyboardProvider(name: "Main")
        let board = storyboard.instantiateViewController(withIdentifier: "BoardViewController") as! BoardViewController
        navigationController?.pushViewController(board, animated: false)
    }
    
    @IBAction func menuButton(_ sender: UIButton) {
        musicPlayer.playSound(withEffect: "Transition")
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)
        transition.type = CATransitionType.fade
        navigationController?.view.layer.add(transition, forKey: kCATransition)
        navigationController?.popToRootViewController(animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 5, green: 24, blue: 73).withAlphaComponent(0.8)
//        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        getFrameButtons()
        musicPlayer.playSoundSecond(withEffect: "Game Over-Frame")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        createResult()
        
        createAnimForGameOverFrame()
        createAnimForContinueButton()
        createAnimForMenuButton()
    }
    
    func createResult() {
        
        if storage.integer(forKey: .keyCurrentNumberLevel) <= 0 {
            storage.set(1, forKey: .keyCurrentNumberLevel)
//            storage.set(0, forKey: .keyCurrentSubNumberLevel)
            LevelRatings.shared.setCurrentSessionRating(score: 0)
        }

        bestResult = LevelRatings.shared.getMaxRating()
        currentResult = LevelRatings.shared.getCurrentSessionRating()
        
        currentResultCount.text = "\(currentResult)"
        
        if currentResult > bestResult {
            LevelRatings.shared.setMaxRating(score: currentResult)
            bestResult = currentResult
        }
        
        bestResultCount.text = "\(bestResult)"
        
        LevelRatings.shared.setCurrentRating(score: 0)
        LevelRatings.shared.setCurrentSessionRating(score: 0)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func createAnimForGameOverFrame() {
        gameOverFrame.alpha = 0
        gameOverFrame.transform = CGAffineTransform(scaleX: 0.5, y: 0.5).rotated(by: .pi / 4)
        
        UIView.animate(withDuration: 0.5, animations: { [self] in
            gameOverFrame.alpha = 1
            gameOverFrame.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
        })
        UIView.animate(withDuration: 0.2, delay: 0.5,  animations: { [self] in
            gameOverFrame.transform = .identity
        })
    }
    
    private func createAnimForContinueButton() {
        restartButton.alpha = 0
        restartButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5).rotated(by: .pi / 4)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [self] in
            UIView.animate(withDuration: 0.35, animations: { [self] in
                restartButton.alpha = 1
                restartButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            })
            UIView.animate(withDuration: 0.15, delay: 0.35,  animations: { [self] in
                restartButton.transform = .identity
            })
        }
    }
    
    private func createAnimForMenuButton() {
        menuButton.alpha = 0
        menuButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5).rotated(by: .pi / 4)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { [self] in
            UIView.animate(withDuration: 0.3, animations: { [self] in
                menuButton.alpha = 1
                menuButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            })
            UIView.animate(withDuration: 0.15, delay: 0.3,  animations: { [self] in
                menuButton.transform = .identity
            })
        }
    }
    
    private func getFrameButtons() {
        
        switch currentHeight {
            case .iPhone8Plus:
                gameOverFrame.translatesAutoresizingMaskIntoConstraints = false
                menuButton.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    gameOverFrame.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -105),
                    bestResultCount.centerYAnchor.constraint(equalTo: self.gameOverFrame.centerYAnchor, constant: 115),
                ])
            case .iPhone8:
                gameOverFrame.translatesAutoresizingMaskIntoConstraints = false
                menuButton.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    gameOverFrame.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -105),
                    bestResultCount.centerYAnchor.constraint(equalTo: self.gameOverFrame.centerYAnchor, constant: 107),
                ])
            case .iPhoneSE1:
                gameOverFrame.translatesAutoresizingMaskIntoConstraints = false
                menuButton.translatesAutoresizingMaskIntoConstraints = false
                restartButton.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    gameOverFrame.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -88),
                    gameOverFrame.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: self.view.frame.width * 0.55),
                    restartButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 140),
                    menuButton.heightAnchor.constraint(equalTo: self.restartButton.heightAnchor),
                    menuButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -12),
                    bestResultCount.centerYAnchor.constraint(equalTo: self.gameOverFrame.centerYAnchor, constant: 92),
                ])
            default: break
        }
    }
}
