import UIKit

final class Bonuses {
    static let shared = Bonuses()
    private let animationKey = "rotationAnimation"
    private var views = [UIView]()
    
    var isActiveBonus = false
    var isActivatedBonusDelete2To5Rows = false
    var isActivatedBonusDeleteAreaItems = false
    var isActivatedBonusDeleteOneColor = false
    var isActivatedBonusDeleteCrossItems = false
    var isActivatedBonusDeleteUpDownItems = false
    var isActivatedBonusDeleteLeftRightItems = false
    let leftLine = [1, 8, 15, 22, 29, 36, 43]
    let rightLine = [7, 14, 21, 28, 35, 42, 49]
    let topLine = [1, 2, 3, 4, 5, 6, 7]
    let bottomLine = [43, 44, 45, 46, 47, 48, 49]
    
    
    func activateBonus() {
        isActiveBonus = true
    }
    
    func deactivateAllBonuses() {
        isActiveBonus = false
        isActivatedBonusDelete2To5Rows = false
        isActivatedBonusDeleteAreaItems = false
        isActivatedBonusDeleteOneColor = false
        isActivatedBonusDeleteCrossItems = false
        isActivatedBonusDeleteUpDownItems = false
        isActivatedBonusDeleteLeftRightItems = false
    }
    
    // MARK: Bonus Time
    func addTime(to currentLeftTime: Double) -> Double {
        return currentLeftTime + 10.0
    }
    
    // MARK: Bonus AreaItems
    func deleteAreaItems(from index: Int) -> [Int] {
        var setRemoveItems = [Int]()
        if isActivatedBonusDeleteAreaItems {
            //            setRemoveItems = createDestroyAreaFromCenter(index)
            setRemoveItems = createDestroyCrossItems(index)
        }
        isActivatedBonusDeleteAreaItems.toggle()
        activateBonus()
        return setRemoveItems
    }
    
    private func createDestroyAreaFromCenter(_ mainIndex: Int) -> [Int] {
        let rightView = mainIndex % 7 != 0 ? mainIndex + 1 : -1
        let bottomView = mainIndex + 7
        let leftView = (mainIndex - 1) % 7 != 0 ? mainIndex - 1 : -1
        let topView = mainIndex - 7
        // TODO: реализовать взрыв с 1 и 2 позиций (слева/справа) в поле 3х3
        let topRightView = mainIndex % 7 != 0 ? mainIndex - 6 : -1
        let bottomRightView = mainIndex % 7 != 0 ? mainIndex + 8 : -1
        let topLeftView = (mainIndex - 1) % 7 != 0 ? mainIndex - 8 : -1
        let bottomLeftView = (mainIndex - 1) % 7 != 0 ? mainIndex + 6 : -1
        
        let tempSetRemoveItems = [mainIndex, rightView, bottomView, leftView, topView, topRightView, bottomRightView, topLeftView, bottomLeftView]
        
        return tempSetRemoveItems.filter { (1...49).contains($0) }
    }
    
    // MARK: Bonus OneColor
    func deleteOneColor(view: UIView) -> [Int] {
        var setRemoveItems = [Int]()
        if isActivatedBonusDeleteOneColor {
            setRemoveItems = createDestroyAreaOneColor(view: view)
            //            setRemoveItems = createDestroyAllItems()
        }
        isActivatedBonusDeleteOneColor.toggle()
        activateBonus()
        return setRemoveItems
    }
    
    private func createDestroyAreaOneColor(view: UIView) -> [Int] {
        let mainImage = view.subviews.first?.subviews[0] as! UIImageView
        var setRemoveItems = [Int]()
        for index in 1...49 {
            let viewImage = view.superview?.viewWithTag(index)?.subviews.first?.subviews[0] as! UIImageView
            if mainImage.image == viewImage.image {
                setRemoveItems.append(index)
            }
        }
        return setRemoveItems
    }
    
    private func createDestroyAllItems() -> [Int] {
        return Array(1...49)
    }
    
    // MARK: Bonus CrossItem
    func deleteCrossItems(from index: Int) -> [Int] {
        var setRemoveItems = [Int]()
        if isActivatedBonusDeleteCrossItems {
            setRemoveItems = createDestroyCrossItems(index)
        }
        isActivatedBonusDeleteCrossItems.toggle()
        activateBonus()
        return setRemoveItems
    }
    
    private func createDestroyCrossItems(_ mainIndex: Int) -> [Int] {
        var tempSetRemoveItems = [mainIndex]
        for i in 1...6 {
            if leftLine.contains(mainIndex - i + 1) {
                break
            }
            tempSetRemoveItems.append(mainIndex - i)
        }
        for i in 1...6 {
            if rightLine.contains(mainIndex + i - 1) {
                break
            }
            tempSetRemoveItems.append(mainIndex + i)
        }
        var i = mainIndex
        while i >= 1 {
            i -= 7
            tempSetRemoveItems.append(i)
        }
        i = mainIndex
        while i <= 49 {
            i += 7
            tempSetRemoveItems.append(i)
        }
        
        return tempSetRemoveItems.filter { (1...49).contains($0) }
    }
    
    // MARK: Bonus UpDownItem
    func deleteUpDownItems(from index: Int) -> [Int] {
        var setRemoveItems = [Int]()
        if isActivatedBonusDeleteUpDownItems {
            setRemoveItems = createDestroyUpDownItems(index)
        }
        isActivatedBonusDeleteUpDownItems.toggle()
        activateBonus()
        return setRemoveItems
    }
    
    private func createDestroyUpDownItems(_ mainIndex: Int) -> [Int] {
        var tempSetRemoveItems = [mainIndex]
        var i = mainIndex
        while i >= 1 {
            i -= 7
            tempSetRemoveItems.append(i)
        }
        i = mainIndex
        while i <= 49 {
            i += 7
            tempSetRemoveItems.append(i)
        }
        return tempSetRemoveItems.filter { (1...49).contains($0) }
    }
    
    // MARK: Bonus LeftRightItem
    func deleteLeftRightItems(from index: Int) -> [Int] {
        var setRemoveItems = [Int]()
        if isActivatedBonusDeleteLeftRightItems {
            setRemoveItems = createDestroyLeftRightItems(index)
        }
        isActivatedBonusDeleteLeftRightItems.toggle()
        activateBonus()
        return setRemoveItems
    }
    
    private func createDestroyLeftRightItems(_ mainIndex: Int) -> [Int] {
        var tempSetRemoveItems = [mainIndex]
        for i in 1...6 {
            if leftLine.contains(mainIndex - i + 1) {
                break
            }
            tempSetRemoveItems.append(mainIndex - i)
        }
        for i in 1...6 {
            if rightLine.contains(mainIndex + i - 1) {
                break
            }
            tempSetRemoveItems.append(mainIndex + i)
        }
        return tempSetRemoveItems.filter { (1...49).contains($0) }
    }
    
    // MARK: Bonus isActivatedBonusDelete2To5Rows
    func delete2To5Rows() -> [Int] {
        var setRemoveItems = [Int]()
        if isActivatedBonusDelete2To5Rows {
            setRemoveItems = createDestroy2To5Rows()
        }
        isActivatedBonusDelete2To5Rows.toggle()
        activateBonus()
        return setRemoveItems
    }
    
    private func createDestroy2To5Rows() -> [Int] {
        var mainIndex = 8
        let amountRows = [2, 3, 4, 5].randomElement()!
        let amountItems = amountRows * 7
        switch amountRows {
            case 2: mainIndex = [15, 22].randomElement()!
            case 3: mainIndex = 15
            case 4: mainIndex = [8, 15].randomElement()!
            case 5: mainIndex = 8
            default: break
        }
        let tempSetRemoveItems = Array(mainIndex..<mainIndex + amountItems)
        
        return tempSetRemoveItems.filter { (1...49).contains($0) }
    }
    
    // MARK: Swaying
    func swayingSideToSide(views: [UIView]) {
        self.views = views
        for view in views {
            CATransaction.begin()
            CATransaction.setCompletionBlock {
                view.transform = .identity
            }
            
            let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
            rotationAnimation.fromValue = NSNumber(value: -0.11)
            rotationAnimation.toValue = NSNumber(value: 0.11)
            rotationAnimation.duration = 0.23
            rotationAnimation.autoreverses = true
            rotationAnimation.repeatCount = Float.infinity
            
            view.layer.add(rotationAnimation, forKey: animationKey)
            
            CATransaction.commit()
        }
    }
    
    func stopSwayingSideToSide() {
        for view in self.views {
            view.layer.removeAnimation(forKey: animationKey)
        }
    }
}
