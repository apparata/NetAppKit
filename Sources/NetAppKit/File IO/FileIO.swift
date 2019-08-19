//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

// It would be better to use NIO's NonBlockingFileIO for this,
// but we will use DispatchQueue for now.

public final class FileIO {
        
    public typealias ReadResult = Result<Data, Error>
        
    public func readFile(_ path: String,
                        completion: @escaping (ReadResult) -> Void) {
        do {
            let url = URL(fileURLWithPath: path)
            completion(.success(try Data(contentsOf: url)))
        } catch {
            completion(.failure(error))
        }
    }
}
