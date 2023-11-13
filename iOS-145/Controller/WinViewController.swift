import UIKit

final class WinViewController: UIViewController {
    private let storage = UserDefaults.standard
    private let musicPlayer = MusicPlayer.shared
    
    private var levelNumber = 1
    private var bestResult = 0
    private var currentSessionResult = 0
    
    @IBOutlet private var winTitle: UIImageView!
    @IBOutlet private var blueGlow: UIImageView!
    @IBOutlet private var planeItem: UIImageView!
    @IBOutlet private var smokePlane: UIImageView!
    
    @IBOutlet weak var bestResultLabel: UILabel!
    @IBOutlet weak var totalResultLabel: UILabel!
    
    @IBOutlet var winFrame: UIView!
    @IBOutlet var continueButton: UIButton!
    
    @IBOutlet private var chestView: UIView!
    @IBOutlet private var newSkinTitle: UIImageView!
    @IBOutlet private var chestImage: UIImageView!
    @IBOutlet private var chestGlow: UIImageView!
    @IBOutlet private var chestFire: UIImageView!
    
    @IBOutlet private var chestSpark1: UIImageView!
    @IBOutlet private var chestSpark2: UIImageView!
    @IBOutlet private var chestSpark3: UIImageView!
    @IBOutlet private var chestSpark4: UIImageView!
    
    @IBAction func nextLevelButton(_ sender: UIButton) {
        musicPlayer.playSound(withEffect: "Transition")
        let numberLevel = storage.integer(forKey: .keyCurrentNumberLevel)
        storage.set(numberLevel + 1, forKey: .keyCurrentNumberLevel)

        createExitAnim()
    }
        
    private func getResult() {
        levelNumber = storage.integer(forKey: .keyCurrentNumberLevel)
        
        bestResult = LevelRatings.shared.getMaxRating()
        currentSessionResult = LevelRatings.shared.getCurrentSessionRating() + LevelRatings.shared.getCurrentRating()
            
        totalResultLabel.text = "\(currentSessionResult)"

        if currentSessionResult > bestResult {
            LevelRatings.shared.setMaxRating(score: currentSessionResult)
            bestResult = currentSessionResult
        }

        bestResultLabel.text = "\(bestResult)"
        
        LevelRatings.shared.addCurrentSessionRating(add: LevelRatings.shared.getCurrentRating())
        LevelRatings.shared.setCurrentRating(score: 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 5, green: 24, blue: 73).withAlphaComponent(0.8)
        musicPlayer.playSoundSecond(withEffect: "Level Passed-Frame")
        getFrameButtons()
        
        getResult()
        smokePlane.alpha = 0
        chestView.alpha = 0

        if [3, 5, 10].contains(levelNumber) {
//            let skin2 = false
            let skin2 = storage.bool(forKey: .keySkin2)
            let skin3 = storage.bool(forKey: .keySkin3)
            let skin4 = storage.bool(forKey: .keySkin4)
            
            if levelNumber == 3 && !skin2 {
                storage.set(true, forKey: .keySkin2)
            } else if levelNumber == 5 && !skin3 {
                storage.set(true, forKey: .keySkin3)
            } else if levelNumber == 10 && !skin4 {
                storage.set(true, forKey: .keySkin4)
            }
//            chestView.alpha = 1
            getChestFrame()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        winFrame.alpha = 0.0
        winTitle.alpha = 0.0
        planeItem.alpha = 0
        chestFire.alpha = 0
        continueButton.alpha = 0
        
        chestSpark1.alpha = 0
        chestSpark2.alpha = 0
        chestSpark3.alpha = 0
        chestSpark4.alpha = 0
        
        self.view.alpha = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [self] in
            UIView.animate(withDuration: 0.25, animations: { [self] in
                self.view.alpha = 1
            }) { [self] _ in
                createAnimForWinFrame()
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func createAnimForWinFrame() {
        winFrame.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        winTitle.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        chestView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        newSkinTitle.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        newSkinTitle.alpha = 0

        chestSpark1.transform = CGAffineTransform(rotationAngle: .pi/4)
        chestSpark2.transform = CGAffineTransform(rotationAngle: .pi/4)
        chestSpark3.transform = CGAffineTransform(rotationAngle: .pi/4)
        chestSpark4.transform = CGAffineTransform(rotationAngle: .pi/4)
        
        let planeOriginY = planeItem.frame.origin.y
        planeItem.frame.origin.y = -planeItem.frame.height
        planeItem.alpha = 1
        
        UIView.animate(withDuration: 0.4, animations: { [self] in
            winFrame.alpha = 1
            winFrame.transform = .identity
            winTitle.alpha = 1
            winTitle.transform = .identity
        }) { [self] _ in
            musicPlayer.playSound(withEffect: "Landing the plane")
        }
        UIView.animate(withDuration: 0.3, delay: 0.4, options: .curveEaseIn, animations: { [self] in
            planeItem.frame.origin.y = planeOriginY
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.63) { [self] in
            let anim = SmokePlaneWinAnimation.shared.startAnimation(frame: smokePlane.frame)
            self.view.addSubview(anim)
            self.view.bringSubviewToFront(winTitle)
            DispatchQueue.main.asyncAfter(deadline: .now() + anim.animationDuration) {
                anim.removeFromSuperview()
            }
        }
        
        if [3, 5, 10].contains(levelNumber) {
            musicPlayer.playSoundSecond(withEffect: "Chest")
            UIView.animate(withDuration: 0.3, delay: 0.7, animations: { [self] in
                chestView.alpha = 1
                chestView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }) { [self] _ in
                let anim = FireWinAnimation.shared.startAnimation(frame: chestFire.frame)
                chestView.addSubview(anim)
                DispatchQueue.main.asyncAfter(deadline: .now() + anim.animationDuration) {
                    anim.removeFromSuperview()
                }
            }
            
            UIView.animate(withDuration: 0.2, delay: 0.75) { [self] in
                chestSpark1.alpha = 1
            }
            UIView.animate(withDuration: 0.2, delay: 0.95) { [self] in
                chestSpark3.alpha = 1
            }
            UIView.animate(withDuration: 0.2, delay: 1.15) { [self] in
                chestSpark2.alpha = 1
            }
            UIView.animate(withDuration: 0.2, delay: 1.4) { [self] in
                chestSpark4.alpha = 1
            }
            
            UIView.animate(withDuration: 0.3, delay: 1.0, animations: { [self] in
                chestView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            })
            UIView.animate(withDuration: 0.2, delay: 1.3, animations: { [self] in
                newSkinTitle.alpha = 1
                newSkinTitle.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                chestView.transform = .identity
            }) { [self] _ in
                createAnimForContinueButton()
            }
            UIView.animate(withDuration: 0.2, delay: 1.5, animations: { [self] in
                newSkinTitle.transform = .identity
            })
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                createAnimForContinueButton()
            }
        }
    }
        
    private func createAnimForContinueButton() {
        let continueButtonOriginY = continueButton.frame.origin.y
        continueButton.frame.origin.y = self.view.frame.height + continueButton.frame.height
        continueButton.alpha = 1
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: { [self] in
            continueButton.frame.origin.y = continueButtonOriginY + 50
            continueButton.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
        })
        UIView.animate(withDuration: 0.2, delay: 0.3, options: .curveEaseOut, animations: { [self] in
            continueButton.frame.origin.y = continueButtonOriginY
            continueButton.transform = .identity
        })
    }
        
    private func createExitAnim() {
        view.backgroundColor = nil
        let backgroundSnapshot = view.snapshotView(afterScreenUpdates: true)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        backgroundSnapshot?.frame = view.frame
        view.subviews.forEach({ $0.alpha = 0 })
        view.addSubview(backgroundSnapshot!)
        
        UIView.animate(withDuration: 0.3, delay: 0.0, animations: { [self] in
            backgroundSnapshot?.frame.origin.x = -self.view.frame.width
            backgroundSnapshot?.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            backgroundSnapshot?.alpha = 0
        }) { [self] _ in
            let storyboard = GameApp.storyboardProvider(name: "Main")
            let board = storyboard.instantiateViewController(withIdentifier: "BoardViewController") as! BoardViewController
            navigationController?.pushViewController(board, animated: false)
            backgroundSnapshot?.removeFromSuperview()
        }
    }
    
    private func getChestFrame() {
        winFrame.translatesAutoresizingMaskIntoConstraints = false
        continueButton.removeFromSuperview()
        self.view.addSubview(continueButton)
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            winFrame.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -50),
            continueButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -25),
            continueButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            continueButton.widthAnchor.constraint(equalTo: self.winFrame.widthAnchor),
        ])
        
        switch CGFloat.currentHeight {
            case .iPhone8Plus, .iPhone8:
                NSLayoutConstraint.activate([
                    winFrame.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -50),
                    continueButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -16),
                    continueButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                    continueButton.widthAnchor.constraint(equalTo: self.winFrame.widthAnchor),
                    bestResultLabel.centerYAnchor.constraint(equalTo: self.winFrame.centerYAnchor, constant: 100),
                ])
            case .iPhoneSE1:
                totalResultLabel.font = totalResultLabel.font.withSize(18)
                bestResultLabel.font = bestResultLabel.font.withSize(18)
                NSLayoutConstraint.activate([
                    winFrame.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -50),
                    continueButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -12),
                    continueButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                    continueButton.widthAnchor.constraint(equalTo: self.winFrame.widthAnchor),
                    bestResultLabel.centerYAnchor.constraint(equalTo: self.winFrame.centerYAnchor, constant: 100),
                ])
            default: break
        }
    }
    
    private func getFrameButtons() {
        
        switch CGFloat.currentHeight {
            case .iPhone8Plus:
                continueButton.translatesAutoresizingMaskIntoConstraints = false
                bestResultLabel.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    continueButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -26),
                    bestResultLabel.centerYAnchor.constraint(equalTo: self.winFrame.centerYAnchor, constant: 114),
                ])
            case .iPhone8:
                continueButton.translatesAutoresizingMaskIntoConstraints = false
                bestResultLabel.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    continueButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -26),
                    bestResultLabel.centerYAnchor.constraint(equalTo: self.winFrame.centerYAnchor, constant: 102),
                ])
            case .iPhoneSE1:
                continueButton.translatesAutoresizingMaskIntoConstraints = false
                bestResultLabel.translatesAutoresizingMaskIntoConstraints = false
                totalResultLabel.font = totalResultLabel.font.withSize(18)
                bestResultLabel.font = bestResultLabel.font.withSize(18)
                NSLayoutConstraint.activate([
                    continueButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -26),
                    bestResultLabel.centerYAnchor.constraint(equalTo: self.winFrame.centerYAnchor, constant: 85),
                ])
            default: break
        }
    }
}
