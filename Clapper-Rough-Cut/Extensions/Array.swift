extension Array where Element: Hashable {
    func unique() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}
