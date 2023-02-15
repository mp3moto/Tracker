import Foundation

struct Schedule: Codable {
    let mon: Bool
    let tue: Bool
    let wed: Bool
    let thu: Bool
    let fri: Bool
    let sat: Bool
    let sun: Bool
    
    func everyday() -> Bool {
        return mon && tue && wed && thu && fri && sat && sun
    }
    
    func isEmpty() -> Bool {
        return !mon && !tue && !wed && !thu && !fri && !sat && !sun
    }
    
    func text() -> String? {
        if everyday() {
            return "Каждый день"
        } else {
            var tempArray: [String] = []
            if mon { tempArray.append("Пн") }
            if tue { tempArray.append("Вт") }
            if wed { tempArray.append("Ср") }
            if thu { tempArray.append("Чт") }
            if fri { tempArray.append("Пт") }
            if sat { tempArray.append("Сб") }
            if sun { tempArray.append("Вс") }
            return tempArray.map{$0}.joined(separator: ", ")
        }
    }
}
