import UIKit

final class ItemView: UIView {
    private var storage = UserDefaults.standard
    private var musicPlayer = MusicPlayer.shared
    private var currentTouchImage = UIImage()
    private var counter = 0
    private var blockersCounter = 0
    private var multiplierCounter = 1
    private var sizeScoreCount = 10
    private var levelFirstGoalLeftCount = 0

    var itemsImage: [UIImage] = [
        GameApp.imageProvider(named: "0")!,
        GameApp.imageProvider(named: "1")!,
        GameApp.imageProvider(named: "2")!,
        GameApp.imageProvider(named: "3")!,
        GameApp.imageProvider(named: "4")!,
        GameApp.imageProvider(named: "5")!,
    ]
    var itemsImageInt: [Int] = [0, 1, 2, 3, 4, 5]
    
    lazy var frontSideView: UIView = self.getFrontSideView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let delay = checkColorItems()
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [self] in
            moveDownItems()
            newItems()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [self] in
            checkAloneItems()
        }
    }
    
    private func checkColorItems() -> TimeInterval {
        let mainImage = self.subviews.first?.subviews[0] as! UIImageView
        let mainIndex = self.tag
        var setRemoveItems = [Int]()
    
        Bonuses.shared.stopSwayingSideToSide()
        
        if Bonuses.shared.isActivatedBonusDelete2To5Rows {
            setRemoveItems = Bonuses.shared.delete2To5Rows()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationPauseBonus"), object: nil, userInfo: nil)
        } else {
            var visitedIndexes: Set<Int> = []
            var stack: [Int] = [mainIndex]
            
            while !stack.isEmpty {
                let currentIndex = stack.popLast()!
                visitedIndexes.insert(currentIndex)
                
                let viewImage = superview?.viewWithTag(currentIndex)?.subviews.first?.subviews[0] as! UIImageView
                if let _ = superview?.viewWithTag(currentIndex + 50) {
                    continue
                }
                
                if mainImage.image == viewImage.image {
                    setRemoveItems.append(currentIndex)
                    let neighbors = createFiveViewFromCenter(currentIndex)
                    for neighbor in neighbors {
                        if !visitedIndexes.contains(neighbor) {
                            stack.append(neighbor)
                        }
                    }
                }
            }
        }
        
        var delay: TimeInterval = 0.0
        if mainImage.subviews.isEmpty || Bonuses.shared.isActiveBonus {
            delay = destroingItems(Set(setRemoveItems))
        }
        return delay
    }
    
    private func destroingItems(_ setRemoveItems: Set<Int>) -> TimeInterval {
        var setRemoveGoalItems = [Int]()
        
        if setRemoveItems.count < 2 {
            musicPlayer.playSound(withEffect: "clickButtonSound")
//            multiplierCounter = 1
            UIView.animate(withDuration: 0.08, delay: 0.0, options: .curveEaseIn) {
                self.transform = CGAffineTransform(rotationAngle: .pi / 4)
            }
            UIView.animate(withDuration: 0.16, delay: 0.08, options: .curveEaseInOut) {
                self.transform = CGAffineTransform(rotationAngle: .pi / -4)
            }
            UIView.animate(withDuration: 0.08, delay: 0.24, options: .curveEaseOut) {
                self.transform = .identity
            }
        } else {
            musicPlayer.playSound(withEffect: "Coincidence")
            var imageData = 0
            let numberSubLevel = storage.integer(forKey: .keyCurrentSubNumberLevel)
            switch numberSubLevel {
                case 1: imageData = storage.integer(forKey: .key2GoalImageInt)
                case 2: imageData = storage.integer(forKey: .key3GoalImageInt)
                case 3: imageData = storage.integer(forKey: .key4GoalImageInt)
                default: imageData = storage.integer(forKey: .key1GoalImageInt)
            }
            
            let currentGoalImage = GameApp.imageProvider(named: String(imageData))!
            for index in setRemoveItems {
                let viewImage = superview?.viewWithTag(index)?.subviews.first?.subviews[0] as! UIImageView
                if viewImage.image == currentGoalImage && viewImage.subviews.isEmpty {
                    setRemoveGoalItems.append(index)
                }
            }
            
            var delay: TimeInterval = 0.0
            let distances = calculateDistance(clickedTag: self.tag)
            for index in setRemoveItems {
                delay = Double(distances[index - 1]) * 0.03
                
                let view = superview!.viewWithTag(index)!
                UIView.animate(withDuration: 0.05, delay: delay / 2, animations: {
                    view.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                }) { _ in
                    UIView.animate(withDuration: 0.1, animations: {
                        view.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                    })
                    UIView.animate(withDuration: 0.05, delay: delay / 1.5, animations: {
                        view.alpha = 0
                    }) { [self] _ in
                        view.transform = .identity
                    }
                }
            }
            counter = setRemoveItems.count * sizeScoreCount
            LevelRatings.shared.addCurrentRating(add: counter)
            
            if !setRemoveGoalItems.isEmpty {
                let currentGoalCount = storage.integer(forKey: .keyCurrentGoalCount)
                let counter = currentGoalCount - setRemoveGoalItems.count <= 0 ? 0 : currentGoalCount - setRemoveGoalItems.count
                storage.set(counter, forKey: .keyCurrentGoalCount)
            }
        }
        Bonuses.shared.deactivateAllBonuses()
        
        let counter = setRemoveItems.count >= 14 ? 5 : setRemoveItems.count
        return Double(counter) * 0.05
    }

    private func moveDownItems() {
        for index in (1...49).reversed() {
            UIView.animate(withDuration: 0.0, delay: 0.0, animations: {
                self.superview?.viewWithTag(index)!.transform = .identity
            })
            let tempY = (superview?.viewWithTag(index)!.frame.origin.y)!
            var indexEmpty = index
            
            if superview?.viewWithTag(indexEmpty)!.alpha == 0 {
                while indexEmpty > 7 && superview?.viewWithTag(indexEmpty)!.alpha == 0 {
                    indexEmpty -= 7
                    let viewImage = superview?.viewWithTag(indexEmpty)?.subviews.first?.subviews[0] as! UIImageView
                    if !viewImage.subviews.isEmpty {
                        while indexEmpty > 7 && !(superview?.viewWithTag(indexEmpty)?.subviews.first?.subviews[0].subviews.isEmpty)! {
                            indexEmpty -= 7
                        }
                    }
                }
            }
            if indexEmpty <= 5 && !(superview?.viewWithTag(indexEmpty)?.subviews.first?.subviews[0].subviews.isEmpty)! {
                indexEmpty = index
            }
            
            superview?.viewWithTag(indexEmpty)!.transform = .identity
            superview?.viewWithTag(index)!.frame.origin.y = (superview?.viewWithTag(indexEmpty)!.frame.origin.y)!
            superview?.bringSubviewToFront((superview?.viewWithTag(index)!)!)
            superview?.viewWithTag(index)!.tag = indexEmpty
            
            let duration: TimeInterval
            if index - indexEmpty <= 7 {
                duration = TimeInterval(0.1)
            } else if index - indexEmpty <= 14 {
                duration = TimeInterval(0.14)
            } else if index - indexEmpty <= 21 {
                duration = TimeInterval(0.18)
            } else if index - indexEmpty <= 28 {
                duration = TimeInterval(0.22)
            } else if index - indexEmpty <= 35 {
                duration = TimeInterval(0.26)
            } else if index - indexEmpty <= 42 {
                duration = TimeInterval(0.30)
            } else if index - indexEmpty <= 49 {
                duration = TimeInterval(0.35)
            } else {
                duration = TimeInterval(0.3)
            }
            
            UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseOut, animations: { [self] in
                superview?.viewWithTag(indexEmpty)!.frame.origin.y = tempY
                superview?.viewWithTag(indexEmpty)!.tag = index
            })
        }
    }
    
    private func newItems() {
        let numberLevel = storage.integer(forKey: .keyCurrentNumberLevel)
        
        var roundNumberLevel = numberLevel
        while roundNumberLevel > 20 {
            roundNumberLevel -= 20
        }
        
        // 4 or 5 or 7 items on level
        var itemsTypeImage = [UIImage]()
        if levelsTypesItems[roundNumberLevel] == 4 {
            itemsTypeImage = ItemView().itemsImage
            itemsTypeImage.remove(at: 5)
            itemsTypeImage.remove(at: 4)
        } else if levelsTypesItems[roundNumberLevel] == 5 {
            itemsTypeImage = ItemView().itemsImage
            itemsTypeImage.remove(at: 5)
        } else {
            itemsTypeImage = ItemView().itemsImage
        }
        
        for index in 1...49 {
            let tempY = (superview?.viewWithTag(index)!.frame.origin.y)!
            if superview?.viewWithTag(index)!.alpha == 0 {
                superview?.viewWithTag(index)!.frame.origin.y = -200
                let viewImage = superview?.viewWithTag(index)?.subviews.first?.subviews[0] as! UIImageView
                viewImage.image = itemsTypeImage.randomElement()
                viewImage.subviews.first?.removeFromSuperview()
                
                let delay: TimeInterval
                if index <= 7 {
                    delay = TimeInterval(0.14)
                } else if index <= 14 {
                    delay = TimeInterval(0.12)
                } else if index <= 21 {
                    delay = TimeInterval(0.1)
                } else if index <= 28 {
                    delay = TimeInterval(0.08)
                } else if index <= 35 {
                    delay = TimeInterval(0.06)
                } else if index <= 42 {
                    delay = TimeInterval(0.04)
                } else if index <= 49 {
                    delay = TimeInterval(0.02)
                } else {
                    delay = TimeInterval(0.0)
                }
                
                UIView.animate(withDuration: 0.12, delay: delay) { [self] in
                    superview?.viewWithTag(index)!.alpha = 1
                }
                
                UIView.animate(withDuration: 0.2, delay: delay) { [self] in
                    superview?.viewWithTag(index)!.frame.origin.y = tempY
                }
            }
            superview?.bringSubviewToFront((superview?.viewWithTag(index)!)!)
            
            if let viewCross = superview?.viewWithTag(index + 50) {
                superview?.bringSubviewToFront(viewCross)
            }
        }
    }
    
    private func checkAloneItems() {
        var lastView = UIView()
        var counter = 0
        for indexView in 1...49 {
            let view = superview?.viewWithTag(indexView)!
            guard let mainImage = view!.subviews.first?.subviews[0] as? UIImageView else { return }
            let indexes: [Int] = createFiveViewFromCenter(indexView)
            
            for index in indexes {
                if indexView != index {
                    let newImage = superview?.viewWithTag(index)!.subviews.first?.subviews[0] as! UIImageView
                    if mainImage.image == newImage.image && superview?.viewWithTag(indexView + 50) == nil && superview?.viewWithTag(index + 50) == nil {
                        counter += 1
                        lastView = superview!.viewWithTag(index)!
                    }
                }
            }
        }
//        print("counter:", counter)
        if counter == 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                Bonuses.shared.swayingSideToSide(views: [lastView])
            }
        }
        if counter == 0 {
            shufflingItems()
        }
    }
    
    private func createFiveViewFromCenter(_ mainIndex: Int) -> [Int] {
        let rightView = mainIndex % 7 != 0 ? mainIndex + 1 : -1
        let bottomView = mainIndex + 7
        let leftView = (mainIndex - 1) % 7 != 0 ? mainIndex - 1 : -1
        let topView = mainIndex - 7
        return [mainIndex, rightView, bottomView, leftView, topView].filter { (1...49).contains($0) }
    }
    
    private func shufflingItems() {
        let shuffledIndexex = (1...49).shuffled()
        for index in (1...49) {
            let viewImage = superview?.viewWithTag(index)?.subviews.first?.subviews[0] as! UIImageView
            let viewImage1 = superview?.viewWithTag(shuffledIndexex[index - 1])?.subviews.first?.subviews[0] as! UIImageView
            if !viewImage.subviews.isEmpty || !viewImage1.subviews.isEmpty {
                continue
            }
            
            let tempOrigin = (superview?.viewWithTag(index)!.frame.origin)!
            let tempIndex = (superview?.viewWithTag(index)!.tag)!
            
            UIView.animate(withDuration: 0.8, animations: { [self] in
                superview?.viewWithTag(index)!.frame.origin = (superview?.viewWithTag(shuffledIndexex[index - 1])!.frame.origin)!
                superview?.bringSubviewToFront((superview?.viewWithTag(index)!)!)
                superview?.viewWithTag(index)!.tag = (superview?.viewWithTag(shuffledIndexex[index - 1])!.tag)!
                
                superview?.viewWithTag(shuffledIndexex[index - 1])!.frame.origin = tempOrigin
                superview?.viewWithTag(shuffledIndexex[index - 1])!.tag = tempIndex
            }, completion: { [self] _ in
                if let viewCross = superview?.viewWithTag(index + 50) {
                    superview?.bringSubviewToFront(viewCross)
                }
            })
        }
        checkAloneItems()
    }
    
    private func calculateDistance(clickedTag: Int) -> [Int] {
        let clickedRow = (clickedTag - 1) / 7
        let clickedCol = (clickedTag - 1) % 7
        var array = [Int]()
        
        for tag in 1...49 {
            let row = (tag - 1) / 7
            let col = (tag - 1) % 7
            
            let distance = abs(col - clickedCol) + abs(row - clickedRow)
            array.append(distance)
        }
        
        return array
    }
    
    private func getFrontSideView() -> UIView {
        let numberLevel = storage.integer(forKey: .keyCurrentNumberLevel)
        
        var roundNumberLevel = numberLevel
        while roundNumberLevel > 12 {
            roundNumberLevel -= 12
        }
        
        // 4 or 5 or 7 items on level
        var itemsTypeImage = [UIImage]()
        if levelsTypesItems[roundNumberLevel] == 4 {
            itemsTypeImage = ItemView().itemsImage
            itemsTypeImage.remove(at: 5)
            itemsTypeImage.remove(at: 4)
        } else if levelsTypesItems[roundNumberLevel] == 5 {
            itemsTypeImage = ItemView().itemsImage
            itemsTypeImage.remove(at: 5)
        } else {
            itemsTypeImage = ItemView().itemsImage
        }
        
        let view = UIView(frame: self.bounds)
        
        let viewImage = UIImageView(frame: self.bounds)
        viewImage.image = itemsTypeImage.randomElement()
        
        view.addSubview(viewImage)
        viewImage.contentMode = .scaleAspectFit
        
        return view
    }
    
    override func draw(_ rect: CGRect) {
        frontSideView.removeFromSuperview()
        self.addSubview(frontSideView)
//        checkAloneItems()
    }
}
