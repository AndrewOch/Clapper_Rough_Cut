//import Foundation
//import PythonKit
//
//class TextsMatcher_Wrapper {
//
//    var waveFunction: PythonObject
//
//    init() {
//        guard let path = Bundle.main.path(forResource: "text_matcher", ofType: "py") as NSString? else {
//            print("File not found")
//            self.waveFunction = []
//            return
//        }
//        let folder = path.deletingLastPathComponent
//        let sys = Python.import("sys")
//        sys.path.append(folder)
//        let file = Python.import("text_matcher")
//        self.waveFunction = file
//    }
//
//    func matchingSequenceLengths(text1: String, text2: String) -> [Int] {
//        let response = waveFunction.matching_sequence_lengths(text1: text1, text2: text2)
//        let array = response.map { Int($0)! }
//        return array
//    }
//
//    func matchingSequenceLength(text1: String, text2: String) -> Int {
//        let response = waveFunction.longest_matching_sequence_length(text1: text1, text2: text2)
//        return Int(response)!
//    }
//}

import Foundation

class TextMatcher {
    
    private let baseUrl = "http://localhost:5000" // Измените на ваш URL

    func matchingSequenceLengths(text1: String, text2: String, completion: @escaping ([Int]?) -> Void) {
        let url = URL(string: "\(baseUrl)/matching_sequence_lengths")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = [
            "text1": text1,
            "text2": text2
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: [])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error during the HTTP request")
                completion(nil)
                return
            }
            
            do {
                let sequenceLengths = try JSONDecoder().decode([Int].self, from: data)
                completion(sequenceLengths)
            } catch {
                print("Failed to decode response: \(error)")
                completion(nil)
            }
        }.resume()
    }

    func matchingSequenceLength(text1: String, text2: String, completion: @escaping (Int?) -> Void) {
        let url = URL(string: "\(baseUrl)/longest_matching_sequence_length")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = [
            "text1": text1,
            "text2": text2
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: [])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error during the HTTP request")
                completion(nil)
                return
            }
            
            do {
                let sequenceLength = try JSONDecoder().decode(Int.self, from: data)
                completion(sequenceLength)
            } catch {
                print("Failed to decode response: \(error)")
                completion(nil)
            }
        }.resume()
    }
}
