import Foundation
import PythonKit

class TextsMatcher_Wrapper {
    
    var waveFunction: PythonObject

    init() {
        guard let path = Bundle.main.path(forResource: "Texts_Matcher", ofType: "py") as NSString? else {
            print("File not found")
            self.waveFunction = []
            return
        }
        let folder = path.deletingLastPathComponent
        let sys = Python.import("sys")
        sys.path.append(folder)
        let file = Python.import("Texts_Matcher")
        self.waveFunction = file
    }
    
    func matchingSequenceLengths(text1: String, text2: String) -> [Int] {
        let response = waveFunction.matching_sequence_lengths(text1: text1, text2: text2)
        let array = response.map { Int($0)! }
        return array
    }
}



