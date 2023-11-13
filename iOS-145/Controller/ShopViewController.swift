import UIKit

final class ShopViewController: UIViewController {
    private let storage = UserDefaults.standard
    private let musicPlayer = MusicPlayer.shared

    private var costs = 0
    private var coins = 0
    var bonusNumber = 0
    
    @IBOutlet private var plane1Button: UIButton!
    @IBOutlet private var plane2Button: UIButton!
    @IBOutlet private var plane3Button: UIButton!
    @IBOutlet private var plane4Button: UIButton!
    
    @IBOutlet private var active1Frame: UIImageView!
    @IBOutlet private var active2Frame: UIImageView!
    @IBOutlet private var active3Frame: UIImageView!
    @IBOutlet private var active4Frame: UIImageView!
    
    @IBOutlet private var closed2Frame: UIImageView!
    @IBOutlet private var closed3Frame: UIImageView!
    @IBOutlet private var closed4Frame: UIImageView!
    
    @IBOutlet private var new2Frame: UIImageView!
    @IBOutlet private var new3Frame: UIImageView!
    @IBOutlet private var new4Frame: UIImageView!
    
    @IBOutlet private var skinsTitle: UIImageView!
    @IBOutlet private var backButton: UIButton!
    
    @IBAction private func toMenuAction(_ sender: UIButton) {
        musicPlayer.playSoundSecond(withEffect: "Transition")
        let transition = CATransition()
        transition.duration = 0.25
        transition.subtype = .fromLeft
        navigationController?.view.layer.add(transition, forKey: kCATransition)
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction private func clickSkinAction(_ sender: UIButton) {
        musicPlayer.playSound(withEffect: "Choice")
        switch sender.tag {
            case 1:
                storage.set(1, forKey: .keyCurrentSkin)
            case 2:
                storage.set(2, forKey: .keyCurrentSkin)
                storage.set(true, forKey: .keyNewSkin2)
            case 3:
                storage.set(3, forKey: .keyCurrentSkin)
                storage.set(true, forKey: .keyNewSkin3)
            case 4:
                storage.set(4, forKey: .keyCurrentSkin)
                storage.set(true, forKey: .keyNewSkin4)
            default: break
        }
        getSkins()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        getFrameButtons()
        
        getSkins()
    }
    
    private func getSkins() {
        var currentSkinNumber = storage.integer(forKey: .keyCurrentSkin)
        let gotSkin2 = storage.bool(forKey: .keySkin2)
        let gotSkin3 = storage.bool(forKey: .keySkin3)
        let gotSkin4 = storage.bool(forKey: .keySkin4)
        let wasChosenSkin2 = storage.bool(forKey: .keyNewSkin2)
        let wasChosenSkin3 = storage.bool(forKey: .keyNewSkin3)
        let wasChosenSkin4 = storage.bool(forKey: .keyNewSkin4)
//        let gotSkin2 = false
//        let gotSkin3 = false
//        let gotSkin4 = false
//        let wasChosenSkin2 = false
//        let wasChosenSkin3 = false
//        let wasChosenSkin4 = false
        
        if currentSkinNumber == 0 {
            storage.set(1, forKey: .keyCurrentSkin)
            currentSkinNumber = 1
        }
        
        plane1Button.imageView?.contentMode = .scaleAspectFit
        plane2Button.imageView?.contentMode = .scaleAspectFit
        plane3Button.imageView?.contentMode = .scaleAspectFit
        plane4Button.imageView?.contentMode = .scaleAspectFit
        
        UIView.animate(withDuration: 0.15, animations: { [self] in
            active1Frame.alpha = 0
            active2Frame.alpha = 0
            active3Frame.alpha = 0
            active4Frame.alpha = 0
            
            switch currentSkinNumber {
                case 1:
                    active1Frame.alpha = 1
                case 2:
                    active2Frame.alpha = 1
                case 3:
                    active3Frame.alpha = 1
                case 4:
                    active4Frame.alpha = 1
                default: break
            }
        })
        
        if wasChosenSkin2 {
            new2Frame.alpha = 0
        } else {
            new2Frame.alpha = 1
        }
        if wasChosenSkin3 {
            new3Frame.alpha = 0
        } else {
            new3Frame.alpha = 1
        }
        if wasChosenSkin4 {
            new4Frame.alpha = 0
        } else {
            new4Frame.alpha = 1
        }
        
        if gotSkin2 {
            plane2Button.alpha = 1
            closed2Frame.image = GameApp.imageProvider(named: "Plane-2-Title")
        } else {
            plane2Button.alpha = 0
            closed2Frame.image = GameApp.imageProvider(named: "closedFrame")
            new2Frame.alpha = 0
        }
        if gotSkin3 {
            plane3Button.alpha = 1
            closed3Frame.image = GameApp.imageProvider(named: "Plane-3-Title")
        } else {
            plane3Button.alpha = 0
            closed3Frame.image = GameApp.imageProvider(named: "closedFrame")
            new3Frame.alpha = 0
        }
        if gotSkin4 {
            plane4Button.alpha = 1
            closed4Frame.image = GameApp.imageProvider(named: "Plane-4-Title")
        } else {
            plane4Button.alpha = 0
            closed4Frame.image = GameApp.imageProvider(named: "closedFrame")
            new4Frame.alpha = 0
        }
    }
    
    private func getFrameButtons() {
        skinsTitle.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
        switch CGFloat.currentHeight {
            case .iPhone8Plus, .iPhone8:
                NSLayoutConstraint.activate([
                    skinsTitle.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 16),
                    backButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 270),
                ])
            case .iPhoneSE1:
                NSLayoutConstraint.activate([
                    skinsTitle.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 16),
                    backButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 200),
                ])
            default:
                skinsTitle.translatesAutoresizingMaskIntoConstraints = true
                backButton.translatesAutoresizingMaskIntoConstraints = true
        }
    }
}
