import UIKit

final class TimerViewController: UIViewController {
    private let musicPlayer = MusicPlayer.shared
    var boardVC: BoardViewController!
    
    @IBOutlet private var timerLabel: UILabel!
    @IBOutlet private var timerLabel2: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = UIColor(red: 5, green: 24, blue: 73).withAlphaComponent(0.8)
        
        animTimer3(count: 3)
    }
    
    private func animTimer3(count: Int) {
        MusicPlayer.shared.playSound(withEffect: "Timer")
        timerLabel.text = "\(count)"
        timerLabel.alpha = 0
        timerLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        timerLabel2.text = "\(count)"
        timerLabel2.alpha = 0
        timerLabel2.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration: 0.2, animations: { [self] in
            timerLabel.alpha = 1
            timerLabel.transform = .identity
            timerLabel2.alpha = 1
            timerLabel2.transform = .identity
        })
        UIView.animate(withDuration: 0.1, delay: 0.6, animations: { [self] in
            timerLabel.alpha = 0
            timerLabel2.alpha = 0
        }) { [self] _ in
            if count > 1 {
                animTimer3(count: count - 1)
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.alpha = 0
                }) { _ in
                    self.view.removeFromSuperview()
                    self.removeFromParent()
                    self.boardVC.createAirplane()
                }
            }
        }
    }
}
