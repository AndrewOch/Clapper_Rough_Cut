struct AudioSyncResult: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var timeOffsets: [UUID: Double]
    var matchConfidence: [UUID: Double]

    init(timeOffsets: [UUID: Double] = [:],
         matchConfidence: [UUID: Double] = [:]) {
        self.timeOffsets = timeOffsets
        self.matchConfidence = matchConfidence
    }
}
