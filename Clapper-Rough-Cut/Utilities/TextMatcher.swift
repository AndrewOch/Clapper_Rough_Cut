import Foundation

class TextMatcher {
    private let baseUrl = "http://localhost:5000"

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
