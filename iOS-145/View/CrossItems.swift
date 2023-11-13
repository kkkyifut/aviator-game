import UIKit

final class CrossItemView: UIView {
    private var storage = UserDefaults.standard
    
    lazy var frontSideView: UIView = self.getFrontSideView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func getFrontSideView() -> UIView {
        let numberLevel = storage.integer(forKey: .keyCurrentNumberLevel)
        
        var roundNumberLevel = numberLevel
        while roundNumberLevel > 12 {
            roundNumberLevel -= 12
        }
        
        let view = UIView(frame: self.bounds)
        let viewImage = UIImageView(frame: self.bounds)
        
        var numbersCrossItems: [Int] = []
        if let item = levelsCrossItems[roundNumberLevel] {
            switch item {
                case .type1(let numbers),
                        .type2(let numbers),
                        .type3(let numbers),
                        .type4(let numbers),
                        .type5(let numbers),
                        .type6(let numbers),
                        .type7(let numbers),
                        .type8(let numbers),
                        .type9(let numbers),
                        .type10(let numbers),
                        .type11(let numbers),
                        .type12(let numbers):
                    numbersCrossItems = numbers
            }
        }
        
        if numbersCrossItems.contains(self.tag - 50) {
            viewImage.image = GameApp.imageProvider(named: "Closed-Item")
        }

        view.addSubview(viewImage)
        viewImage.contentMode = .scaleAspectFit
        
        return view
    }
    
    override func draw(_ rect: CGRect) {
        frontSideView.removeFromSuperview()
        self.addSubview(frontSideView)
    }
}
