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
    
    func daysOfweek() -> [Int] {
        var daysOfWeek: [Int] = []
        if everyday() {
            return [1,2,3,4,5,6,7]
        } else {
            if mon { daysOfWeek.append(2) }
            if tue { daysOfWeek.append(3) }
            if wed { daysOfWeek.append(4) }
            if thu { daysOfWeek.append(5) }
            if fri { daysOfWeek.append(6) }
            if sat { daysOfWeek.append(7) }
            if sun { daysOfWeek.append(1) }
            return daysOfWeek
        }
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
    
    func binary() -> String {
        var binary: String = ""
        if sat { binary += "1" } else { binary += "0" }
        if fri { binary += "1" } else { binary += "0" }
        if thu { binary += "1" } else { binary += "0" }
        if wed { binary += "1" } else { binary += "0" }
        if tue { binary += "1" } else { binary += "0" }
        if mon { binary += "1" } else { binary += "0" }
        if sun { binary += "1" } else { binary += "0" }
        print(binary)
        return binary
    }
    
    func packed() -> Int32 {
        Int32(binary(), radix: 2) ?? 0
    }
}
