import UIKit

final class MenuViewController: UIViewController {
    private let storyboardInstance = GameApp.storyboardProvider(name: "Main")

    private let storage = UserDefaults.standard
    private let musicPlayer = MusicPlayer.shared
    private var recordCount = 0
    private var planeOriginY = CGFloat()
    
    @IBOutlet private var recordLabel: UILabel!
    @IBOutlet private var moonItem: UIImageView!
    @IBOutlet private var planeItem: UIImageView!
    
    @IBOutlet var musicButton: UIButton!
    @IBOutlet var gameButton: UIButton!
    @IBOutlet var skinsButton: UIButton!
    
    @IBOutlet var logoMenu: UIImageView!
    @IBOutlet var recordView: UIView!
    
    @IBAction func switchMusic(_ sender: UIButton) {
        musicPlayer.playSound(withEffect: "clickButtonSound")
        
        musicPlayer.isMuted = !musicPlayer.isMuted
        if musicPlayer.isMuted {
            let imageSelected = GameApp.imageProvider(named: "soundOffButton")
            musicButton.setImage(imageSelected, for: .selected)
            musicPlayer.stopBGMusic()
        } else {
            let imageDeselected = GameApp.imageProvider(named: "soundOnButton")
            musicButton.setImage(imageDeselected, for: .normal)
            musicPlayer.startGameMusic()
        }
        musicButton.isSelected.toggle()
    }
    
    @IBAction func toBoardScene(_ sender: UIButton) {
        musicPlayer.playSound(withEffect: "Transition")
        
//        if !musicPlayer.isMuted {
//            musicPlayer.stopBGMusic()
//            musicPlayer.startGameMusic()
//        }
        
        let boardVC = storyboardInstance.instantiateViewController(withIdentifier: "BoardViewController") as! BoardViewController
        
        let transition = CATransition()
        transition.duration = 0.15
        navigationController?.view.layer.add(transition, forKey: kCATransition)
        self.navigationController?.pushViewController(boardVC, animated: false)
    }
    
    @IBAction private func toSkinShopAction(_ sender: UIButton) {
        musicPlayer.playSoundSecond(withEffect: "Transition")
        
//        if !musicPlayer.isMuted {
//            musicPlayer.stopBGMusic()
//            musicPlayer.startGameMusic()
//        }
        
        UIView.animate(withDuration: 0.05, animations: { [self] in
            recordView.alpha = 0
            gameButton.alpha = 0
            skinsButton.alpha = 0
        })
        
        let shopVC = storyboardInstance.instantiateViewController(withIdentifier: "ShopViewController") as! ShopViewController
        
        let transition = CATransition()
        transition.duration = 0.25
        transition.subtype = .fromRight
        navigationController?.view.layer.add(transition, forKey: kCATransition)
        self.navigationController?.pushViewController(shopVC, animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        getFrameButtons()
        
        if !storage.bool(forKey: .keyFirstEnter) {
            storage.set(true, forKey: .keyFirstEnter)
            storage.set(1, forKey: .keyCurrentSkin)
        }
        
        if musicPlayer.isMuted {
            musicButton.isSelected = true
            let imageSelected = GameApp.imageProvider(named: "soundOffButton")
            musicButton.setImage(imageSelected, for: .selected)
            musicPlayer.stopBGMusic()
        } else {
            MusicPlayer.shared.playSound(withEffect: "logo")
            musicButton.isSelected = false
            let imageDeselected = GameApp.imageProvider(named: "soundOnButton")
            musicButton.setImage(imageDeselected, for: .normal)
            musicPlayer.startGameMusic()
        }
        
        createAnimForMoonAndMusic()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getRecord()
        
        storage.set(Settings.shared.startLevel, forKey: .keyCurrentNumberLevel) // стартовый уровень
        storage.set(0, forKey: .keyCurrentSubNumberLevel)
        LevelRatings.shared.setCurrentRating(score: 0)
        LevelRatings.shared.setCurrentSessionRating(score: 0)
        
        if planeItem.alpha != 0 {
            recordView.alpha = 1
            gameButton.alpha = 1
            skinsButton.alpha = 1
            UIView.animate(withDuration: 1.5, delay: 0.0, options: [.repeat, .autoreverse], animations: { [self] in
                planeItem.frame.origin.y = planeOriginY - 20
                planeItem.frame.origin.y = planeOriginY + 20
            })
        }
    }
    
    private func getRecord() {
        recordCount = LevelRatings.shared.getMaxRating()
        recordLabel.text = "\(recordCount)"
    }
    
    private func createAnimForMoonAndMusic() {
        moonItem.alpha = 0
        musicButton.alpha = 0
        
        recordView.alpha = 0
        planeItem.alpha = 0
        gameButton.alpha = 0
        skinsButton.alpha = 0
        logoMenu.alpha = 0
        
        moonItem.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        
        UIView.animate(withDuration: 0.5, animations: {
            self.moonItem.transform = .identity
            self.moonItem.alpha = 1
            self.musicButton.alpha = 1
        }) { [self] _ in
            createAnimForLogo()
        }
    }
    
    private func createAnimForLogo() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [self] in
            musicPlayer.playSound(withEffect: "Logo")
        }
        let imageViewTransition = LogoAnimation.shared.startAnimation(frame: logoMenu.frame)
        self.view.addSubview(imageViewTransition)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + imageViewTransition.animationDuration - 0.01) { [self] in
            logoMenu.alpha = 1
            imageViewTransition.removeFromSuperview()
            createAnimForPlaneItem()
        }
    }
    
    private func createAnimForPlaneItem() {
        planeOriginY = planeItem.frame.origin.y
        planeItem.frame.origin.y = self.view.frame.height + planeItem.frame.height
        let recordViewOriginY = recordView.frame.origin.y
        recordView.frame.origin.y = self.view.frame.height + recordView.frame.height
        planeItem.alpha = 1
        recordView.alpha = 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [self] in
            musicPlayer.playSoundSecond(withEffect: "Plane-Menu Screen")
        }
        UIView.animate(withDuration: 0.9, animations: { [self] in
            planeItem.frame.origin.y = planeOriginY
        })
        UIView.animate(withDuration: 1.5, delay: 0.9, options: [.repeat, .autoreverse], animations: { [self] in
            planeItem.frame.origin.y = planeOriginY - 20
        }) 
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [self] in
            musicPlayer.playSound(withEffect: "Record")
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.7, animations: { [self] in
            recordView.frame.origin.y = recordViewOriginY
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) { [self] in
            createAnimForButtons()
        }
    }
    
    private func createAnimForButtons() {
        let gameButtonOriginY = gameButton.frame.origin.y
        gameButton.frame.origin.y = self.view.frame.height + gameButton.frame.height
        let skinsButtonOriginY = skinsButton.frame.origin.y
        skinsButton.frame.origin.y = self.view.frame.height + skinsButton.frame.height
        
        gameButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        skinsButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        gameButton.alpha = 1
        skinsButton.alpha = 1

        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveLinear, animations: { [self] in
            gameButton.frame.origin.y = gameButton.frame.origin.y - (gameButtonOriginY / 2)
            gameButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        })
        UIView.animate(withDuration: 0.2, delay: 0.25, options: .curveLinear, animations: { [self] in
            gameButton.frame.origin.y = gameButtonOriginY
            gameButton.transform = .identity
        }) { [self] _ in
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveLinear, animations: { [self] in
                skinsButton.frame.origin.y = skinsButton.frame.origin.y - (skinsButtonOriginY / 2)
                skinsButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            })
            UIView.animate(withDuration: 0.2, delay: 0.25, options: .curveLinear, animations: { [self] in
                skinsButton.frame.origin.y = skinsButtonOriginY
                skinsButton.transform = .identity
            })
        }
    }
    
    private func getFrameButtons() {
        
        switch CGFloat.currentHeight {
            case .iPhone8Plus, .iPhone8:
                logoMenu.translatesAutoresizingMaskIntoConstraints = false
                musicButton.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    logoMenu.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -140),
                    musicButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 16),
                ])
            case .iPhoneSE1:
                logoMenu.translatesAutoresizingMaskIntoConstraints = false
                musicButton.translatesAutoresizingMaskIntoConstraints = false
                recordLabel.font = recordLabel.font.withSize(18)
                NSLayoutConstraint.activate([
                    logoMenu.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -105),
                    musicButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 16),
                ])
            default: break
        }
    }
}

