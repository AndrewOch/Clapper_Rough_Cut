import Foundation
import PythonKit
//
//class MFCC_Wrapper {
//
//    var waveFunction: PythonObject
//
//    init() {
//        guard let path = Bundle.main.path(forResource: "MFCC", ofType: "py") as NSString? else {
//            print("File not found")
//            self.waveFunction = []
//            return
//        }
//        let folder = path.deletingLastPathComponent
//        let sys = Python.import("sys")
//        sys.path.append(folder)
//        let file = Python.import("MFCC")
//        self.waveFunction = file
//    }
//
//    func extractMFCCS(file: URL) -> [[Float]]? {
//        let response = waveFunction.get_normalized_mfcc(audio_file: file.path)
//
//        let numRows = response.count
//        let numCols = response[0].count
//
//        var swiftArray: [[Float]] = Array(repeating: Array(repeating: 0.0, count: numCols), count: numRows)
//
//        for i in 0..<numRows {
//            for j in 0..<numCols {
//                swiftArray[i][j] = Float(response[i][j])!
//            }
//        }
//        return swiftArray
//    }
//
//    func distanceDTW(mfccs1: [[Float]], mfccs2: [[Float]]) -> Float {
//       let response = waveFunction.get_dtw(mfccs1: mfccs1, mfccs2: mfccs2)
//        return Float(response[0])!
//    }
//}

import Foundation

class MFCCService {
    
    private let baseUrl = "http://localhost:5000"

    func extractMFCCs(fileURL: URL, completion: @escaping ([[Float]]?) -> Void) {
        // Преобразование файла в Data для отправки в теле запроса
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
