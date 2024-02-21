import Foundation
import Foundation

class MFCCService {
    
    private let baseUrl = "http://localhost:5000"

    func extractMFCCs(fileURL: URL, completion: @escaping ([[Float]]?) -> Void) {
        guard let fileData = try? Data(contentsOf: fileURL) else {
            print("Failed to load file data")
            completion(nil)
            return
        }
        
        let url = URL(string: "\(baseUrl)/extract_mfcc")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = fileData
        request.addValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error during the HTTP request")
                completion(nil)
                return
            }
            
            do {
                let mfccs = try JSONDecoder().decode([[Float]].self, from: data)
                completion(mfccs)
            } catch {
                print("Failed to decode response: \(error)")
                completion(nil)
            }
        }.resume()
    }

    func distanceDTW(mfccs1: [[Float]], mfccs2: [[Float]], completion: @escaping (Float?) -> Void) {
        let url = URL(string: "\(baseUrl)/distance_dtw")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = [
            "mfccs1": mfccs1,
            "mfccs2": mfccs2
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: [])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error during the HTTP request")
                completion(nil)
                return
            }
            
            do {
                let result = try JSONDecoder().decode([Float].self, from: data)
                completion(result.first)
            } catch {
                print("Failed to decode response: \(error)")
                completion(nil)
            }
        }.resume()
    }
}
