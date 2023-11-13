import UIKit

final class NewLevelViewController: UIViewController {
    private let storage = UserDefaults.standard
    private let musicPlayer = MusicPlayer.shared
    private let currentHeight = UIScreen.main.nativeBounds.height
    var boardVC: BoardViewController!
    private var is3Goals = false
    private var is4Goals = false
    
    @IBOutlet private var levelNumberLabel: UILabel!
    @IBOutlet private var levelSpark: UIImageView!
    @IBOutlet private var sparkAnims: UIImageView!
    
    @IBOutlet private var goal1Image: UIImageView!
    @IBOutlet private var goal1Label: UILabel!
    @IBOutlet private var goal2Image: UIImageView!
    @IBOutlet private var goal2Label: UILabel!
    @IBOutlet private var goal3Image: UIImageView!
    @IBOutlet private var goal3Label: UILabel!
    @IBOutlet private var goal4Image: UIImageView!
    @IBOutlet private var goal4Label: UILabel!
    
    @IBOutlet private var goal1Frame: UIImageView!
    @IBOutlet private var goal2Frame: UIImageView!
    @IBOutlet private var goal3Frame: UIImageView!
    @IBOutlet private var goal4Frame: UIImageView!
    @IBOutlet private var goalsFrame: UIView!
    
    @IBOutlet private var frameForAnimate: UIView!
    
    @IBOutlet private var blueGlow: UIImageView!
    @IBOutlet private var spark1: UIImageView!
    @IBOutlet private var spark2: UIImageView!
    @IBOutlet private var spark3: UIImageView!
    @IBOutlet private var spark4: UIImageView!
    @IBOutlet private var spark5: UIImageView!
    @IBOutlet private var spark6: UIImageView!
    @IBOutlet private var spark7: UIImageView!
    @IBOutlet private var spark8: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 5, green: 24, blue: 73).withAlphaComponent(0.8)
        musicPlayer.playSound(withEffect: "Goal Level")
        createGoals()
        getFrameLifeStack()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        animateForFrame()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func createGoals() {
        if storage.integer(forKey: .keyCurrentNumberLevel) <= 0 {
            storage.set(1, forKey: .keyCurrentNumberLevel)
        }
        let levelNumber = storage.integer(forKey: .keyCurrentNumberLevel)
        levelNumberLabel.text = "\(levelNumber)"
        
        var roundNumberLevel = levelNumber
        while roundNumberLevel > 12 {
            roundNumberLevel -= 12
        }
        
        let goal1ImageInt = storage.integer(forKey: .key1GoalImageInt)
        let goal2ImageInt = storage.integer(forKey: .key2GoalImageInt)
        let goal3ImageInt = storage.integer(forKey: .key3GoalImageInt)
        let goal4ImageInt = storage.integer(forKey: .key4GoalImageInt)
        
        if levelNumber <= 12 {
            goal1Label.text = "\(levelsItems[roundNumberLevel]![0])"
            goal2Label.text = "\(levelsItems[roundNumberLevel]![1])"
            goal1Image.image = GameApp.imageProvider(named: "\(goal1ImageInt)")
            goal2Image.image = GameApp.imageProvider(named: "\(goal2ImageInt)")
            if levelsGoals[roundNumberLevel] ?? 2 >= 3 {
                goal3Label.text = "\(levelsItems[roundNumberLevel]![2])"
                goal3Image.image = GameApp.imageProvider(named: "\(goal3ImageInt)")
                is3Goals = true
            } else {
                goal3Label.text = ""
                goal3Image.image = nil
                goal3Frame.image = nil
                is3Goals = false
            }
            if levelsGoals[roundNumberLevel] ?? 2 >= 4 {
                goal4Label.text = "\(levelsItems[roundNumberLevel]![3])"
                goal4Image.image = GameApp.imageProvider(named: "\(goal4ImageInt)")
                is4Goals = true
            } else {
                goal4Label.text = ""
                goal4Image.image = nil
                goal4Frame.image = nil
                is4Goals = false
            }
        } else {
            goal1Label.text = "\(levelsItems[roundNumberLevel]![0] + 10)"
            goal2Label.text = "\(levelsItems[roundNumberLevel]![1] + 10)"
            goal1Image.image = GameApp.imageProvider(named: "\(goal1ImageInt)")
            goal2Image.image = GameApp.imageProvider(named: "\(goal2ImageInt)")
            if levelsGoals[roundNumberLevel] ?? 2 >= 3 {
                goal3Label.text = "\(levelsItems[roundNumberLevel]![2] + 10)"
                goal3Image.image = GameApp.imageProvider(named: "\(goal3ImageInt)")
                is3Goals = true
            } else {
                goal3Label.text = ""
                goal3Image.image = nil
                goal3Frame.image = nil
                is3Goals = false
            }
            if levelsGoals[roundNumberLevel] ?? 2 >= 4 {
                goal4Label.text = "\(levelsItems[roundNumberLevel]![3] + 10)"
                goal4Image.image = GameApp.imageProvider(named: "\(goal4ImageInt)")
                is4Goals = true
            } else {
                goal4Label.text = ""
                goal4Image.image = nil
                goal4Frame.image = nil
                is4Goals = false
            }
        }
        
        goal1Label.font = UIFont(name: "Audiowide Regular", size: 30)
        goal2Label.font = UIFont(name: "Audiowide Regular", size: 30)
        goal3Label.font = UIFont(name: "Audiowide Regular", size: 30)
        goal4Label.font = UIFont(name: "Audiowide Regular", size: 30)
        getGoalsFrames()
    }
    
    private func animateForFrame() {
        frameForAnimate.alpha = 0
        sparkAnims.alpha = 0
        goal1Frame.alpha = 0
        goal2Frame.alpha = 0
        goal3Frame.alpha = 0
        goal4Frame.alpha = 0
        goal1Image.alpha = 0
        goal2Image.alpha = 0
        goal3Image.alpha = 0
        goal4Image.alpha = 0
        goal1Label.alpha = 0
        goal2Label.alpha = 0
        goal3Label.alpha = 0
        goal4Label.alpha = 0
        
        blueGlow.alpha = 0
        
        spark1.alpha = 0
        spark2.alpha = 0
        spark3.alpha = 0
        spark4.alpha = 0
        spark5.alpha = 0
        spark6.alpha = 0
        spark7.alpha = 0
        spark8.alpha = 0
        
        levelSpark.alpha = 0
        levelNumberLabel.alpha = 0
        
        frameForAnimate.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        goal1Frame.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        goal2Frame.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        goal3Frame.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        goal4Frame.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        goal1Image.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        goal2Image.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        goal3Image.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        goal4Image.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        goal1Label.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        goal2Label.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        goal3Label.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        goal4Label.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        let animSpark = WinSparkAnimation.shared.startAnimation(frame: sparkAnims.frame)
        self.view.addSubview(animSpark)
        self.view.sendSubviewToBack(animSpark)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + animSpark.animationDuration) {
            animSpark.removeFromSuperview()
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseOut]) { [self] in
            blueGlow.alpha = 1
            frameForAnimate.alpha = 1
            frameForAnimate.transform = .identity
        }
        
        UIView.animate(withDuration: 0.2, delay: 0.55) { [self] in
            spark1.alpha = 1
        }
        UIView.animate(withDuration: 0.2, delay: 0.65) { [self] in
            spark3.alpha = 1
        }
        UIView.animate(withDuration: 0.2, delay: 0.75) { [self] in
            spark2.alpha = 1
        }
        UIView.animate(withDuration: 0.2, delay: 0.7) { [self] in
            spark4.alpha = 1
        }
        UIView.animate(withDuration: 0.2, delay: 0.8) { [self] in
            spark5.alpha = 1
        }
        UIView.animate(withDuration: 0.2, delay: 0.9) { [self] in
            spark6.alpha = 1
        }
        UIView.animate(withDuration: 0.2, delay: 1.05) { [self] in
            spark7.alpha = 1
        }
        UIView.animate(withDuration: 0.2, delay: 0.95) { [self] in
            spark8.alpha = 1
        }
        
        UIView.animate(withDuration: 0.3, delay: 0.5) { [self] in
            levelSpark.alpha = 1
        }
        UIView.animate(withDuration: 0.3, delay: 0.8) { [self] in
            levelNumberLabel.alpha = 1
        }
        
        UIView.animate(withDuration: 0.15, delay: 0.65) { [self] in
            goal1Frame.alpha = 1
            goal1Frame.transform = .identity
            goal2Frame.alpha = 1
            goal2Frame.transform = .identity
            goal3Frame.alpha = 1
            goal3Frame.transform = .identity
            goal4Frame.alpha = 1
            goal4Frame.transform = .identity
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) { [self] in
            musicPlayer.playSoundSecond(withEffect: "Goal")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) { [self] in
            musicPlayer.playSound(withEffect: "Goal")
        }
        if is3Goals {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) { [self] in
                musicPlayer.playSoundSecond(withEffect: "Goal")
            }
        }
        if is4Goals {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [self] in
                musicPlayer.playSound(withEffect: "Goal")
            }
        }
        
        UIView.animate(withDuration: 0.1, delay: 1.1) { [self] in
            goal1Image.alpha = 1
            goal1Label.alpha = 1
        }
        UIView.animate(withDuration: 0.1, delay: 1.4) { [self] in
            goal2Image.alpha = 1
            goal2Label.alpha = 1
        }
        UIView.animate(withDuration: 0.1, delay: 1.7) { [self] in
            goal3Image.alpha = 1
            goal3Label.alpha = 1
        }
        UIView.animate(withDuration: 0.1, delay: 2.0) { [self] in
            goal4Image.alpha = 1
            goal4Label.alpha = 1
        }
        
        UIView.animate(withDuration: 0.3, delay: 1.1) { [self] in
            goal1Image.transform = .identity
            goal1Label.transform = .identity
        }
        UIView.animate(withDuration: 0.3, delay: 1.4) { [self] in
            goal2Image.transform = .identity
            goal2Label.transform = .identity
        }
        UIView.animate(withDuration: 0.3, delay: 1.7) { [self] in
            goal3Image.transform = .identity
            goal3Label.transform = .identity
        }
        UIView.animate(withDuration: 0.3, delay: 2.0) { [self] in
            goal4Image.transform = .identity
            goal4Label.transform = .identity
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [self] in
            musicPlayer.playSound(withEffect: "Transition")
            UIView.animate(withDuration: 0.2, animations: { [self] in
                spark1.alpha = 0
                spark2.alpha = 0
                spark3.alpha = 0
                spark4.alpha = 0
                spark5.alpha = 0
                spark6.alpha = 0
                spark7.alpha = 0
                spark8.alpha = 0
                blueGlow.alpha = 0
            })
            
            UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn], animations: { [self] in
                frameForAnimate.frame.origin.x = -frameForAnimate.frame.width
                frameForAnimate.alpha = 0
                frameForAnimate.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            }, completion: { [self] _ in
                closeFrame()
            })
        }
    }
    
    private func closeFrame() {
        self.view.removeFromSuperview()
        self.removeFromParent()
        boardVC.showTimerVC()
    }
    
    private func getGoalsFrames() {
        let labels = [goal1Label, goal2Label, goal3Label, goal4Label]
        var count = 0
        for label in labels {
            if label!.text != "" {
                count += 1
            }
        }
        switch count {
            case 2:
                goal1Frame.translatesAutoresizingMaskIntoConstraints = false
                goal2Frame.translatesAutoresizingMaskIntoConstraints = false
                goal1Label.translatesAutoresizingMaskIntoConstraints = false
                goal2Label.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    goal1Frame.centerYAnchor.constraint(equalTo: goalsFrame.centerYAnchor, constant: -20),
                    goal2Frame.centerYAnchor.constraint(equalTo: goalsFrame.centerYAnchor, constant: -20),
                    goal1Label.topAnchor.constraint(equalTo: goal1Frame.bottomAnchor, constant: -55),
                    goal2Label.topAnchor.constraint(equalTo: goal2Frame.bottomAnchor, constant: -55),
                ])
            case 3:
                goal3Frame.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    goal3Frame.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                ])
            default: break
        }
    }
    
    private func getFrameLifeStack() {
        
        switch currentHeight {
            case .iPhone8Plus:
                levelNumberLabel.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    levelNumberLabel.centerYAnchor.constraint(equalTo: self.frameForAnimate.centerYAnchor, constant: 220),
                ])
            case .iPhone8:
                levelNumberLabel.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    levelNumberLabel.centerYAnchor.constraint(equalTo: self.frameForAnimate.centerYAnchor, constant: 200),
                ])
            case .iPhoneSE1:
                levelNumberLabel.translatesAutoresizingMaskIntoConstraints = false
                goal1Label.font = levelNumberLabel.font.withSize(25)
                goal2Label.font = levelNumberLabel.font.withSize(25)
                goal3Label.font = levelNumberLabel.font.withSize(25)
                goal4Label.font = levelNumberLabel.font.withSize(25)
                levelNumberLabel.font = levelNumberLabel.font.withSize(50)
                NSLayoutConstraint.activate([
                    levelNumberLabel.centerYAnchor.constraint(equalTo: self.frameForAnimate.centerYAnchor, constant: 170),
                ])
            default: break
        }
    }
}
