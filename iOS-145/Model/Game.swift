import Foundation

final class Game {
    var itemsCount = 49
    var items = [Item]()
    
    func generateItems() {
        var items = [Item]()
        for _ in 1...itemsCount {
            items.append(Item.red)
        }
        self.items = items
    }
    
}
