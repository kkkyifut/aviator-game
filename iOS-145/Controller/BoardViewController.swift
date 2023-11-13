import UIKit

final class BoardViewController: UIViewController, CAAnimationDelegate {
    private let storyboardInstance = GameApp.storyboardProvider(name: "Main")
    private let storage = UserDefaults.standard
    private let musicPlayer = MusicPlayer.shared
    private var isLevelPassedTrigger = false
    private var isSubLevelPassedTrigger = false
    
    private var animationPlanePos = CAKeyframeAnimation()
    private var animationPlaneRot = CABasicAnimation()
    private var timer: Timer?
    private var timeLeft: Double = 30
    var numberSubLevel = 0
    /// 0.1 сек
    private var timeInterval = 0.1
    private var originAirplane = CGPoint()
    private var itemViews = [UIView]()
    private var itemCrossViews = [UIView]()
    private var airplane = UIImageView()
    private var wayItem = UIImageView()

    let itemSize = CGSize(width: UIScreen.main.bounds.width * 0.844 / 7,
                          height: UIScreen.main.bounds.width * 0.844 / 7)
    
    private lazy var game: Game = getNewGame()
    private lazy var shuffledItemsOnView = getShuffledItemsOnView()
    
    @IBOutlet private var boardView: UIView!
    @IBOutlet private var background: UIImageView!
    @IBOutlet private var cloud1: UIImageView!
    @IBOutlet private var cloud2: UIImageView!
    @IBOutlet private var cloud3: UIImageView!
    @IBOutlet private var smokePlane: UIImageView!
    @IBOutlet private var stars: UIImageView!
    
    private var cloud1Add: UIImageView!
    private var cloud2Add: UIImageView!
    private var cloud3Add: UIImageView!
    private var starsAdd: UIImageView!
    
    @IBOutlet private var currentScoreLabel: UILabel!
    
    @IBOutlet var levelGoalImage: UIImageView!
    @IBOutlet var levelGoalCount: UILabel!
    
    @IBOutlet var levelNumberLabel: UILabel!
    @IBOutlet private var scoreView: UIView!
    @IBOutlet private var pauseButton: UIButton!
    
    @IBOutlet var bonusCrossButton: UIButton!
    
    @IBOutlet var progressTimeView: UIProgressView!
    
    @IBAction func resultButton(_ sender: UIButton) {
        showResultGame()
    }
    
    // MARK: - Timers
    private func resumeTimer() {
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(onTimeFires), userInfo: nil, repeats: true)
        timer?.tolerance = 0.1
    }
    
    private func pauseTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func onTimeFires() {
        timeLeft -= timeInterval
        
        let numberLevel = storage.integer(forKey: .keyCurrentNumberLevel)
        var roundNumberLevel = numberLevel
        while roundNumberLevel > 12 {
            roundNumberLevel -= 12
        }
        
//        if numberSubLevel >= levelsGoals[roundNumberLevel]! { return }
        
        let time = levelsTimers[roundNumberLevel]![numberSubLevel]
        UIView.animate(withDuration: timeInterval, delay: 0.0, options: .curveLinear) { [self] in
            progressTimeView.setProgress(Float(((time) - timeLeft) / (time)), animated: true)
        }
                
        currentScoreLabel.text = "\(LevelRatings.shared.getCurrentSessionRating() + LevelRatings.shared.getCurrentRating())"
//        currentScoreLabel.text = "\(LevelRatings.shared.getCurrentRating())"
        
        let currentGoalCount = storage.integer(forKey: .keyCurrentGoalCount)
        levelGoalCount.text = "\(currentGoalCount)"
        
        levelNumberLabel.text = String(numberLevel)
        
        let conditionFinishGame = currentGoalCount <= 0
        
        if timeLeft < timeInterval {
            pauseTimer()
            timeLeft = time
            progressTimeView.progress = 1
            showGameOver()
        } else if conditionFinishGame {
            pauseTimer()
            timeLeft = time
            isSubLevelPassedTrigger = true
            levelGoalCount.alpha = 0
            numberSubLevel += 1
            storage.set(numberSubLevel, forKey: .keyCurrentSubNumberLevel)
            if numberSubLevel >= levelsGoals[roundNumberLevel]! {
                isLevelPassedTrigger = true
            }
            createAirplaneOverflight()
        }
    }
    
    // MARK: - board and buttons
    @IBAction func showMenuPause(_ sender: UIButton) {
        let pauseView = storyboardInstance.instantiateViewController(withIdentifier: "alert") as! PauseViewController
        
        pauseView.view.alpha = 0
        pauseView.view.frame = self.view.bounds
        self.view.addSubview(pauseView.view)
        self.addChild(pauseView)
        pauseView.didMove(toParent: self)
        UIView.animate(withDuration: 0.3, animations: {
            pauseView.view.alpha = 1
        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationFromPauseView), name: NSNotification.Name(rawValue: "notificationPause"), object: nil)
        pauseTimer()
    }
    
    func showTimerVC() {
        let timerVC = storyboardInstance.instantiateViewController(withIdentifier: "TimerViewController") as! TimerViewController
        timerVC.boardVC = self
        
        timerVC.view.frame = self.view.bounds
        self.view.addSubview(timerVC.view)
        self.addChild(timerVC)
        timerVC.didMove(toParent: self)
    }
    
    private func showResultGame() {
        self.view.isUserInteractionEnabled = true
        storage.set(0, forKey: .keyCurrentSubNumberLevel)
        
        let winVC = storyboardInstance.instantiateViewController(withIdentifier: "WinViewController") as! WinViewController
        
        winVC.view.frame = self.view.bounds
        self.view.addSubview(winVC.view)
        self.addChild(winVC)
        winVC.didMove(toParent: self)
    }
    
    private func showGameOver() {
        self.view.isUserInteractionEnabled = true
        
        let gameOverVC = storyboardInstance.instantiateViewController(withIdentifier: "GameOverViewController") as! GameOverViewController
        
        gameOverVC.view.frame = self.view.bounds
        self.view.addSubview(gameOverVC.view)
        self.addChild(gameOverVC)
        gameOverVC.didMove(toParent: self)
        
        storage.set(1, forKey: .keyCurrentNumberLevel)

//            LevelRatings.shared.setCurrentRating(score: 0)
//            LevelRatings.shared.setCurrentSessionRating(score: 0)
    }
    
    // MARK: getNewGame
    private func getNewGame() -> Game {
        let game = Game()
        game.generateItems()
        isSubLevelPassedTrigger = false
        levelGoalCount.alpha = 1
        
        if storage.integer(forKey: .keyCurrentNumberLevel) <= 0 {
            storage.set(1, forKey: .keyCurrentNumberLevel)
        }
        let numberLevel = storage.integer(forKey: .keyCurrentNumberLevel)
//        let numberSubLevel = storage.integer(forKey: .keyCurrentSubNumberLevel)
        var roundNumberLevel = numberLevel
        while roundNumberLevel > 12 {
            roundNumberLevel -= 12
        }
        
        timeLeft = levelsTimers[roundNumberLevel]![numberSubLevel]
//        blockersCounter = levelsGoals[roundNumberLevel]!.3
        
        // 4 or 5 or 7 items on level
        var itemsType = [Int]()
        if levelsTypesItems[roundNumberLevel] == 4 {
            itemsType = ItemView().itemsImageInt
            itemsType.remove(at: 5)
            itemsType.remove(at: 4)
        } else if levelsTypesItems[roundNumberLevel] == 5 {
            itemsType = ItemView().itemsImageInt
            itemsType.remove(at: 5)
        } else {
            itemsType = ItemView().itemsImageInt
        }
        
        // first goal
        let currentItemColorInt = itemsType.randomElement()!
        let item2ColorInt = itemsType.randomElement()!
        var item3ColorInt = 0
        var item4ColorInt = 0
        if levelsGoals[roundNumberLevel] ?? 0 >= 3 {
            item3ColorInt = itemsType.randomElement()!
        }
        if levelsGoals[roundNumberLevel] ?? 0 >= 4 {
            item4ColorInt = itemsType.randomElement()!
        }

        levelGoalImage.image = GameApp.imageProvider(named: "\(currentItemColorInt)")
        storage.set(currentItemColorInt, forKey: .key1GoalImageInt)
        storage.set(item2ColorInt, forKey: .key2GoalImageInt)
        storage.set(item3ColorInt, forKey: .key3GoalImageInt)
        storage.set(item4ColorInt, forKey: .key4GoalImageInt)
        
        let currentGoal = levelsItems[roundNumberLevel]![numberSubLevel]
        if numberLevel <= 12 {
            levelGoalCount.text = "\(currentGoal)"
            storage.set(currentGoal, forKey: .keyCurrentGoalCount)
        } else {
            levelGoalCount.text = "\(currentGoal + 10)"
            storage.set(currentGoal + 10, forKey: .keyCurrentGoalCount)
        }
        
        return game
    }

    // MARK: getNewSublevel
    private func getNewSublevel() {
        var currentItemColorInt = 0
        switch numberSubLevel {
            case 1: currentItemColorInt = storage.integer(forKey: .key2GoalImageInt)
            case 2: currentItemColorInt = storage.integer(forKey: .key3GoalImageInt)
            case 3: currentItemColorInt = storage.integer(forKey: .key4GoalImageInt)
            default: break
        }

        levelGoalImage.image = GameApp.imageProvider(named: "\(currentItemColorInt)")
//        storage.set(currentItemColorInt, forKey: .key1GoalImageInt)
//        storage.set(item2ColorInt, forKey: .key2GoalImageInt)
//        storage.set(item3ColorInt, forKey: .key3GoalImageInt)
//        storage.set(item4ColorInt, forKey: .key4GoalImageInt)
        
        
        let numberLevel = storage.integer(forKey: .keyCurrentNumberLevel)
        var roundNumberLevel = numberLevel
        while roundNumberLevel > 12 {
            roundNumberLevel -= 12
        }
        
        let currentGoal = levelsItems[roundNumberLevel]![numberSubLevel]
        if numberLevel <= 12 {
            levelGoalCount.text = "\(currentGoal)"
            storage.set(currentGoal, forKey: .keyCurrentGoalCount)
        } else {
            levelGoalCount.text = "\(currentGoal + 10)"
            storage.set(currentGoal + 10, forKey: .keyCurrentGoalCount)
        }
        
        timeLeft = levelsTimers[roundNumberLevel]![numberSubLevel]
        UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveLinear) { [self] in
            progressTimeView.setProgress(0, animated: true)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            resumeTimer()
            createAirplane()
        }
    }
    
    private func getShuffledItemsOnView() -> UIButton {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 120, height: 50))
        button.center.x = view.center.x + 125
        
        let window = UIApplication.shared.windows[0]
        let topPadding  = window.safeAreaInsets.top
        button.frame.origin.y = topPadding
        
        button.setTitle("Перемешать", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.gray, for: .highlighted)
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 10
        
        button.addTarget(nil, action: #selector(shuffleItems), for: .touchUpInside)
        
        return button
    }
    
    // MARK: getItemsBy
    private func getItemsBy(modelData: [Item]) -> ([UIView], [UIView]) {
        var itemViews = [UIView]()
        var itemCrossViews = [UIView]()
        for (index, _) in modelData.enumerated() {
            let item = ItemView(frame: CGRect(origin: .zero, size: itemSize))
            let itemCross = CrossItemView(frame: CGRect(origin: .zero, size: itemSize))
            item.tag = index + 1
            itemCross.tag = index + 51
            itemViews.append(item)
            itemCrossViews.append(itemCross)
        }
        return (itemViews, itemCrossViews)
    }
    
    // MARK: placeItemsOnBoard
    private func placeItemsOnBoard(_ items: [UIView], _ itemsCross: [UIView]) {
        for item in itemViews {
            item.removeFromSuperview()
        }
        itemViews = items
        
        for itemCross in itemCrossViews {
            itemCross.removeFromSuperview()
        }
        itemCrossViews = itemsCross
        
        var originX = 13
        var originY = 13
        switch CGFloat.currentHeight {
            case .iPhone15ProMax, .iPhone11ProMax, .iPhone13ProMax, .iPhoneXR:
                originX = 15
                originY = 16
            case .iPhone8Plus:
                originX = 15
                originY = 15
            case .iPhone8:
                originX = 12
                originY = 12
            case .iPhoneSE1:
                originX = 11
                originY = 11
            case .iPhone12, .iPhone12Mini, .iPhoneX:
                originX = 12
                originY = 12
            default: break
        }
        var x = Int(originX)
        var y = Int(originY)
        for (index, item) in itemViews.enumerated() {
            boardView.addSubview(item)
            item.center = CGPoint(x: Int(item.center.x) + x, y: Int(item.center.y) + y)
            x += Int(itemSize.width)
            if (index + 1) % 7 == 0 {
                y += Int(itemSize.height)
                x = Int(originX)
            }
        }
        
        x = Int(originX)
        y = Int(originY)
        for (index, itemCross) in itemCrossViews.enumerated() {
            boardView.addSubview(itemCross)
            itemCross.center = CGPoint(x: Int(itemCross.center.x) + x, y: Int(itemCross.center.y) + y)
            x += Int(itemSize.width)
            if (index + 1) % 7 == 0 {
                y += Int(itemSize.height)
                x = Int(originX)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                let viewImage = itemCross.subviews.first?.subviews[0] as! UIImageView
                if viewImage.image == nil {
                    itemCross.removeFromSuperview()
                }
            }
        }
    }
    
    // MARK: Bonuses Buttons
    @IBAction func timerBonusButton(_ sender: UIButton) {
        timeLeft = Bonuses.shared.addTime(to: timeLeft)
    }
    
    @IBAction func deleteCross4ArrowItemsBonusButton(_ sender: UIButton) {
//        pauseTimer()
//        if countBonusCross > 0 {
        Bonuses.shared.isActivatedBonusDelete2To5Rows = true
        let viewImage = boardView.viewWithTag(1)?.subviews.first?.subviews[0] as! UIImageView
        viewImage.touchesBegan([UITouch()], with: nil)
    }
        
    // MARK: Game Buttons
    private func startGame() {
        game = getNewGame()
        let (items, itemsCross) = getItemsBy(modelData: game.items)
        placeItemsOnBoard(items, itemsCross)
        currentScoreLabel?.text = "\(LevelRatings.shared.getCurrentSessionRating() + LevelRatings.shared.getCurrentRating())"
        pauseTimer()
        Bonuses.shared.deactivateAllBonuses()
//        LevelRatings.shared.setCurrentRating(score: 0)
        
        if timeLeft > 0 {
            resumeTimer()
        }
    }
    
    // MARK: shuffleItems
    @objc private func shuffleItems(_ sender: UIButton) {
        if boardView.subviews.count < 2 {
            return
        }
        let shuffledIndexex = (1...49).shuffled()
        for index in (1...49) {
            let viewImage = boardView.viewWithTag(index)?.subviews.first?.subviews[0] as! UIImageView
            let viewImage1 = boardView.viewWithTag(shuffledIndexex[index - 1])?.subviews.first?.subviews[0] as! UIImageView
            if !viewImage.subviews.isEmpty || !viewImage1.subviews.isEmpty {
                continue
            }
            let tempOrigin = boardView.viewWithTag(index)!.frame.origin
            let tempIndex = boardView.viewWithTag(index)!.tag
            
            UIView.animate(withDuration: 0.8, animations: { [self] in
                boardView.viewWithTag(index)!.frame.origin = boardView.viewWithTag(shuffledIndexex[index - 1])!.frame.origin
                boardView.bringSubviewToFront(boardView.viewWithTag(index)!)
                boardView.viewWithTag(index)!.tag = boardView.viewWithTag(shuffledIndexex[index - 1])!.tag
                
                boardView.viewWithTag(shuffledIndexex[index - 1])!.frame.origin = tempOrigin
                boardView.viewWithTag(shuffledIndexex[index - 1])!.tag = tempIndex
            }) { [self] _ in
                if let viewCross = boardView.viewWithTag(index + 50) {
                    boardView.bringSubviewToFront(viewCross)
                }
            }
        }
    }
    
    @objc private func notificationFromPauseView() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "notificationPause"), object: nil)
        if !Bonuses.shared.isActiveBonus {
            resumeTimer()
        }
    }
    
    @objc private func notificationFromPauseBonus() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "notificationPauseBonus"), object: nil)
        resumeTimer()
    }
    
    @objc private func notificationFromReadyView() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "notificationReady"), object: nil)
        startGame()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        getFrameButtons()
        
        cloud1Add = UIImageView(image: GameApp.imageProvider(named: "Cloud-Item-1"))
        cloud1Add.frame = cloud1.frame
        self.view.addSubview(cloud1Add)
        cloud2Add = UIImageView(image: GameApp.imageProvider(named: "Cloud-Item-2"))
        cloud2Add.frame = cloud2.frame
        self.view.addSubview(cloud2Add)
        cloud3Add = UIImageView(image: GameApp.imageProvider(named: "Cloud-Item-3"))
        cloud3Add.frame = cloud3.frame
        self.view.addSubview(cloud3Add)
        starsAdd = UIImageView(image: GameApp.imageProvider(named: "Stars"))
        starsAdd.frame = stars.frame
        self.view.addSubview(starsAdd)
        
        cloud1Add.frame.origin.x = -cloud1.frame.width
        cloud2Add.frame.origin.x = -cloud2.frame.width
        cloud3Add.frame.origin.x = -cloud3.frame.width
        starsAdd.frame.origin.x = -stars.frame.width
        
        showLevelGoal()
        smokePlane.alpha = 0
        levelGoalCount.alpha = 0
        
        self.view.sendSubviewToBack(cloud1)
        self.view.sendSubviewToBack(cloud1Add)
        self.view.sendSubviewToBack(wayItem)
        self.view.sendSubviewToBack(cloud2)
        self.view.sendSubviewToBack(cloud2Add)
        self.view.sendSubviewToBack(cloud3)
        self.view.sendSubviewToBack(cloud3Add)
        self.view.sendSubviewToBack(stars)
        self.view.sendSubviewToBack(starsAdd)
        self.view.sendSubviewToBack(background)
        self.view.bringSubviewToFront(levelGoalCount)
        self.view.bringSubviewToFront(airplane)
        
        animateClouds1()
        animateClouds2()
        animateClouds3()
        animateStars()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        musicPlayer.stopFlightMusic()
    }
    
    // MARK: animateClouds
    private func animateClouds1() {
        let animation1 = CABasicAnimation(keyPath: "position.x")
        animation1.fromValue = cloud1.layer.position.x
        animation1.toValue = cloud1.layer.position.x + cloud1.frame.width
        animation1.duration = 7
        animation1.repeatCount = .greatestFiniteMagnitude
        animation1.timingFunction = CAMediaTimingFunction(name: .linear)
        
        let animation1Add = CABasicAnimation(keyPath: "position.x")
        animation1Add.fromValue = cloud1Add.layer.position.x
        animation1Add.toValue = cloud1Add.layer.position.x + cloud1Add.frame.width
        animation1Add.duration = 7
        animation1Add.repeatCount = .greatestFiniteMagnitude
        animation1Add.timingFunction = CAMediaTimingFunction(name: .linear)
        
        cloud1.layer.add(animation1, forKey: "cloud1Animation")
        cloud1Add.layer.add(animation1Add, forKey: "cloud1AddAnimation")
    }

    
    private func animateClouds2() {
        let animation2 = CABasicAnimation(keyPath: "position.x")
        animation2.fromValue = cloud2.layer.position.x
        animation2.toValue = cloud2.layer.position.x + cloud2.frame.width
        animation2.duration = 10
        animation2.repeatCount = .greatestFiniteMagnitude
        animation2.timingFunction = CAMediaTimingFunction(name: .linear)
        
        let animation2Add = CABasicAnimation(keyPath: "position.x")
        animation2Add.fromValue = cloud2Add.layer.position.x
        animation2Add.toValue = cloud2Add.layer.position.x + cloud2Add.frame.width
        animation2Add.duration = 10
        animation2Add.repeatCount = .greatestFiniteMagnitude
        animation2Add.timingFunction = CAMediaTimingFunction(name: .linear)
        
        cloud2.layer.add(animation2, forKey: "cloud2Animation")
        cloud2Add.layer.add(animation2Add, forKey: "cloud2AddAnimation")
    }
    
    private func animateClouds3() {
        let animation3 = CABasicAnimation(keyPath: "position.x")
        animation3.fromValue = cloud3.layer.position.x
        animation3.toValue = cloud3.layer.position.x + cloud3.frame.width
        animation3.duration = 13
        animation3.repeatCount = .greatestFiniteMagnitude
        animation3.timingFunction = CAMediaTimingFunction(name: .linear)
        
        let animation3Add = CABasicAnimation(keyPath: "position.x")
        animation3Add.fromValue = cloud3Add.layer.position.x
        animation3Add.toValue = cloud3Add.layer.position.x + cloud3Add.frame.width
        animation3Add.duration = 13
        animation3Add.repeatCount = .greatestFiniteMagnitude
        animation3Add.timingFunction = CAMediaTimingFunction(name: .linear)
        
        cloud3.layer.add(animation3, forKey: "cloud3Animation")
        cloud3Add.layer.add(animation3Add, forKey: "cloud3AddAnimation")
    }
    
    private func animateStars() {
        let animation = CABasicAnimation(keyPath: "position.x")
        animation.fromValue = stars.layer.position.x
        animation.toValue = stars.layer.position.x + stars.frame.width
        animation.duration = 30
        animation.repeatCount = .greatestFiniteMagnitude
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        
        let animationAdd = CABasicAnimation(keyPath: "position.x")
        animationAdd.fromValue = starsAdd.layer.position.x
        animationAdd.toValue = starsAdd.layer.position.x + starsAdd.frame.width
        animationAdd.duration = 30
        animationAdd.repeatCount = .greatestFiniteMagnitude
        animationAdd.timingFunction = CAMediaTimingFunction(name: .linear)
        
        stars.layer.add(animation, forKey: "starsAnimation")
        starsAdd.layer.add(animationAdd, forKey: "starsAddAnimation")
    }
    
    // MARK: showLevelGoal
    private func showLevelGoal() {
        let newLevelVC = storyboardInstance.instantiateViewController(withIdentifier: "NewLevelViewController") as! NewLevelViewController
        newLevelVC.boardVC = self
        
        newLevelVC.view.frame = self.view.bounds
        self.view.addSubview(newLevelVC.view)
        self.addChild(newLevelVC)
        newLevelVC.didMove(toParent: self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationFromPauseView), name: NSNotification.Name(rawValue: "notificationPause"), object: nil)
        pauseTimer()
    }
    
    override func loadView() {
        super.loadView()
        
//        view.addSubview(shuffledItemsOnView)
        startGame()
    }
    
    private func getFrameButtons() {
        
        switch CGFloat.currentHeight {
            case .iPhone8Plus, .iPhone8:
                pauseButton.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    pauseButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 12),
                ])
            case .iPhoneSE1:
                pauseButton.translatesAutoresizingMaskIntoConstraints = false
                currentScoreLabel.font = currentScoreLabel.font.withSize(18)
                levelGoalCount.font = levelGoalCount.font.withSize(20)
                NSLayoutConstraint.activate([
                    pauseButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 12),
                ])
            default: break
        }
    }
}

// MARK: extension BoardViewController
extension BoardViewController {
    
    func createAirplane() {
        musicPlayer.startFlightMusic()
        self.view.isUserInteractionEnabled = false
        
        var numberSkin = storage.integer(forKey: .keyCurrentSkin)
        if numberSkin == 0 { numberSkin = 1 }
        //        let numberSkin = 4
        let airplaneName = "Plane-Item-\(numberSkin)"
        let airplaneImage = GameApp.imageProvider(named: airplaneName)
        airplane = UIImageView(image: airplaneImage)
        airplane.frame = CGRect(x: self.view.frame.midX, y: self.view.frame.midY, width: airplaneImage!.size.width / 5, height: airplaneImage!.size.height / 5)
        self.view.addSubview(airplane)
        airplane.alpha = 0
        airplane.center.x = self.view.frame.width * 0.5
        airplane.center.y = self.view.frame.height * 0.35
        
        switch CGFloat.currentHeight {
            case .iPhone8Plus, .iPhone8:
                airplane.center.y = self.view.frame.height * 0.3
            case .iPhoneSE1:
                airplane.frame.size = CGSize(width: airplaneImage!.size.width / 6, height: airplaneImage!.size.height / 6)
                airplane.center.x = self.view.frame.width * 0.6
                airplane.center.y = self.view.frame.height * 0.29
            default: break
        }
        
        originAirplane = CGPoint(x: airplane.center.x, y: airplane.center.y)
        
        var wayItemName = "Green Way-Item"
        switch numberSkin {
            case 1, 4: wayItemName = "Red Way-Item"
            case 2: wayItemName = "Green Way-Item"
            case 3: wayItemName = "Yellow Way-Item"
            default: break
        }
        let wayItemImage = GameApp.imageProvider(named: wayItemName)
        wayItem = UIImageView(image: wayItemImage)
        wayItem.frame = CGRect(x: self.view.frame.midX, y: self.view.frame.midY, width: wayItemImage!.size.width / 3, height: wayItemImage!.size.height / 3)
        self.view.addSubview(wayItem)
        wayItem.frame.origin = CGPoint(x: airplane.frame.origin.x - wayItem.frame.width / 1.34, y: airplane.frame.origin.y + airplane.frame.height / 1.5)
        
        levelGoalCount.frame.origin.x = airplane.frame.origin.x + 10
        levelGoalCount.center.y = wayItem.center.y - 35
        levelGoalCount.font = UIFont(name: "Audiowide Regular", size: 25)
        
        wayItem.alpha = 0
        levelGoalCount.alpha = 0
        
        self.view.sendSubviewToBack(cloud1)
        self.view.sendSubviewToBack(cloud1Add)
        self.view.sendSubviewToBack(wayItem)
        self.view.sendSubviewToBack(cloud2)
        self.view.sendSubviewToBack(cloud2Add)
        self.view.sendSubviewToBack(cloud3)
        self.view.sendSubviewToBack(cloud3Add)
        self.view.sendSubviewToBack(stars)
        self.view.sendSubviewToBack(starsAdd)
        self.view.sendSubviewToBack(background)
        self.view.bringSubviewToFront(levelGoalCount)
        self.view.bringSubviewToFront(airplane)
        
        isSubLevelPassedTrigger = false
        
        airplane.frame.origin.x = -airplane.frame.width
        airplane.alpha = 1
        UIView.animate(withDuration: 0.55, delay: 0.0, options: .curveEaseOut, animations: { [self] in
            airplane.center.x = CGFloat(originAirplane.x)
        }) { [self] _ in
            self.view.isUserInteractionEnabled = true
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationPause"), object: nil, userInfo: nil)
            //            notificationFromPauseView()
            createAirplaneAnimUp()
        }
        UIView.animate(withDuration: 0.3, delay: 0.43, animations: { [self] in
            wayItem.alpha = 1
            levelGoalCount.alpha = 1
        })
    }
    
    private func deleteAirplane() {
        musicPlayer.stopFlightMusic()
        airplane.removeFromSuperview()
        wayItem.removeFromSuperview()
    }
    
    private func createAirplaneAnimDown() {
        if isSubLevelPassedTrigger { return }
        UIView.animate(withDuration: 1.0, animations: { [self] in
            airplane.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 6.0)
        })
        UIView.animate(withDuration: 3.0, animations: { [self] in
            airplane.center.y = CGFloat(originAirplane.y)
            wayItem.frame.origin.y = airplane.frame.origin.y + airplane.frame.height / 1.5
            levelGoalCount.center.y = wayItem.center.y - 50
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.1) { [self] in
            createAirplaneAnimUp()
        }
    }
    
    private func createAirplaneAnimUp() {
        if isSubLevelPassedTrigger { return }
        UIView.animate(withDuration: 1.0, animations: { [self] in
            airplane.transform = .identity
        })
        UIView.animate(withDuration: 2.5, animations: { [self] in
            airplane.center.y = originAirplane.y - 150
            wayItem.frame.origin.y = airplane.frame.origin.y + airplane.frame.height / 1.5
            levelGoalCount.center.y = wayItem.center.y - 35
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) { [self] in
            createAirplaneAnimDown()
        }
    }
    
    private func createAirplaneOverflight() {
        self.view.isUserInteractionEnabled = false
        pauseTimer()
        UIView.animate(withDuration: 0.5, animations: { [self] in
            wayItem.alpha = 0
        })
        
        let topPoint = -airplane.frame.height
//        let currentPointY = airplane.layer.contentsCenter.minY
        let currentPointY = airplane.layer.frame.origin.y
        let centerPoint = currentPointY + topPoint
        
        let arcPath = UIBezierPath()
        arcPath.move(to: CGPoint(x: airplane.center.x, y: currentPointY))
        arcPath.addQuadCurve(to: CGPoint(x: view.frame.width * 0.5, y: topPoint), controlPoint: CGPoint(x: view.frame.width * 0.67, y: centerPoint))
        
        animationPlanePos = CAKeyframeAnimation(keyPath: "position")
        animationPlanePos.path = arcPath.cgPath
        animationPlanePos.rotationMode = .none
        animationPlanePos.duration = 0.7
        animationPlanePos.calculationMode = .paced
        animationPlanePos.delegate = self
        airplane.layer.add(animationPlanePos, forKey: "animateAirplaneInArc")
        
        animationPlaneRot = CABasicAnimation(keyPath: "transform.rotation")
        animationPlaneRot.fromValue = 0.0
        animationPlaneRot.toValue = -CGFloat.pi
        animationPlaneRot.duration = 0.7
        airplane.layer.add(animationPlaneRot, forKey: "rotateAirplane")
        
        musicPlayer.playSoundSecond(withEffect: "Takeoff")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) { [self] in
            airplane.alpha = 0
            if isLevelPassedTrigger {
                return
            }
            airplane.alpha = 1
            airplane.transform = .identity
            airplane.center.y = boardView.center.y
            airplane.frame.origin.x = -airplane.frame.width
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [self] in
                musicPlayer.playSound(withEffect: "Plane")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [self] in
                    musicPlayer.playSoundSecond(withEffect: "Removing items")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [self] in
                        musicPlayer.playSoundSecond(withEffect: "Falling elements")
                    }
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) { [self] in
                let smokePlaneAnim = SmokePlaneAnimation.shared.startAnimation(frame: self.smokePlane.frame)
                self.view.addSubview(smokePlaneAnim)
                DispatchQueue.main.asyncAfter(deadline: .now() + smokePlaneAnim.animationDuration) {
                    smokePlaneAnim.removeFromSuperview()
                }
            }
            
            UIView.animate(withDuration: 0.7, delay: 0.0, options: .curveLinear, animations: { [self] in
                airplane.frame.origin.x = self.view.frame.width
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [self] in
                    deleteCross4ArrowItemsBonusButton(UIButton())
                    currentScoreLabel.text = "\(LevelRatings.shared.getCurrentSessionRating() + LevelRatings.shared.getCurrentRating())"
                }
            }) { [self] _ in
                self.view.isUserInteractionEnabled = true
                deleteAirplane()
                if isSubLevelPassedTrigger {
                    getNewSublevel()
                }
            }
        }
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            if isLevelPassedTrigger {
                self.view.isUserInteractionEnabled = true
                deleteAirplane()
                showResultGame()
            }
        }
    }

}

