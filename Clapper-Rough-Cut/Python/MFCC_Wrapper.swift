import Foundation
import PythonKit

class MFCC_Wrapper {

    var waveFunction: PythonObject

    init() {
        guard let path = Bundle.main.path(forResource: "MFCC", ofType: "py") as NSString? else {
            print("File not found")
            self.waveFunction = []
            return
        }
        let folder = path.deletingLastPathComponent
        let sys = Python.import("sys")
        sys.path.append(folder)
        let file = Python.import("MFCC")
        self.waveFunction = file
    }

    func extractMFCCS(file: URL) -> [[Float]]? {
        let response = waveFunction.get_normalized_mfcc(audio_file: file.path)

        let numRows = response.count
        let numCols = response[0].count

        var swiftArray: [[Float]] = Array(repeating: Array(repeating: 0.0, count: numCols), count: numRows)

        for i in 0..<numRows {
            for j in 0..<numCols {
                swiftArray[i][j] = Float(response[i][j])!
            }
        }
        return swiftArray
    }

    func distanceDTW(mfccs1: [[Float]], mfccs2: [[Float]]) -> Float {
       let response = waveFunction.get_dtw(mfccs1: mfccs1, mfccs2: mfccs2)
        return Float(response[0])!
    }

    func distanceAndOffsetDTW(mfccs1: [[Float]], mfccs2: [[Float]]) -> (distance: Float, offset: Float) {
        let response = waveFunction.get_dtw_offset(mfccs1: mfccs1, mfccs2: mfccs2)
        let distance = Float(response[0])!
        let offset = Float(response[1])!
        return (distance, offset)
    }
}
