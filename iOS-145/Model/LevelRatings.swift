import Foundation

class LevelRatings {
    static let shared = LevelRatings()
    private let storage = UserDefaults.standard
    
    private var currentRating = 0
    private var currentSessionRating = 0
    private var maxRating = 0
    
    /// Получить текущий счёт
    func getCurrentRating() -> Int {
        currentRating = storage.integer(forKey: .keyForCurrentRating)
        return currentRating
    }
    
    /// Установить текущий счёт
    func setCurrentRating(score: Int) {
        storage.set(score, forKey: .keyForCurrentRating)
    }
    
    /// Добавить к текущему счёту
    func addCurrentRating(add score: Int) {
        currentRating = storage.integer(forKey: .keyForCurrentRating)
        storage.set(currentRating + score, forKey: .keyForCurrentRating)
    }
    
    /// Получить счёт текущей сессии
    func getCurrentSessionRating() -> Int {
        currentSessionRating = storage.integer(forKey: .keyForCurrentSessionRating)
        return currentSessionRating
    }
    
    /// Установить счёт текущей сессии
    func setCurrentSessionRating(score: Int) {
        storage.set(score, forKey: .keyForCurrentSessionRating)
    }
    
    /// Добавить к текущему счёту
    func addCurrentSessionRating(add score: Int) {
        currentSessionRating = storage.integer(forKey: .keyForCurrentSessionRating)
        storage.set(currentSessionRating + score, forKey: .keyForCurrentSessionRating)
    }
    
    /// Получить максимальный счёт за сессию
    func getMaxRating() -> Int {
        maxRating = storage.integer(forKey: .keyForMaxRating)
        return maxRating
    }
    
    /// Установить новый рекорд
    func setMaxRating(score: Int) {
        storage.set(score, forKey: .keyForMaxRating)
    }
}
