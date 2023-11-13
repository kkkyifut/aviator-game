import UIKit

// MARK: Разметка заблокированных items на уровнях
let levelsCrossItems: [Int: CrossItems.TypesItems] = [
    1: .type1(),
    2: .type2(),
    3: .type3(),
    4: .type4(),
    5: .type5(),
    6: .type6(),
    7: .type7(),
    8: .type8(),
    9: .type9(),
    10: .type10(),
    11: .type11(),
    12: .type12(),
]

// MARK: Разметка заблокированных items по типам
struct CrossItems {
    let type: TypesItems
    
    enum TypesItems {
        case type1([Int] = [])
        case type2([Int] = [22, 23, 24, 25, 26, 27, 28])
        case type3([Int] = [4, 11, 18, 25, 32, 39, 46])
        case type4([Int] = [1, 2, 3, 4, 5, 6, 7, 43, 44, 45, 46, 47, 48, 49])
        case type5([Int] = [1, 8, 15, 22, 29, 36, 43, 7, 14, 21, 28, 35, 42, 49])
        case type6([Int] = [1, 2, 3, 4, 5, 6, 7, 22, 23, 24, 25, 26, 27, 28, 43, 44, 45, 46, 47, 48, 49])
        case type7([Int] = [1, 8, 15, 22, 29, 36, 43, 4, 11, 18, 25, 32, 39, 46, 7, 14, 21, 28, 35, 42, 49])
        case type8([Int] = [1, 2, 3, 4, 5, 6, 7, 8, 15, 22, 29, 36, 43, 44, 45, 46, 47, 48, 49, 14, 21, 28, 35, 42])
        case type9([Int] = [22, 23, 24, 25, 26, 27, 28, 4, 11, 18, 32, 39, 46])
        case type10([Int] = [7, 13, 19, 25, 31, 37, 43])
        case type11([Int] = [1, 9, 17, 25, 33, 41, 49])
        case type12([Int] = [1, 9, 17, 33, 41, 49, 7, 13, 19, 31, 37, 43])
    }
}
