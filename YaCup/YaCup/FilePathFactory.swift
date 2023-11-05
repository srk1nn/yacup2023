//
//  FilePathFactory.swift
//  YaCup
//
//  Created by igor.sorokin on 05.11.2023.
//

import Foundation

struct FilePathFactory {

    private let documentsDirectory: URL = {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }()

    func getFileURL() -> URL {
        documentsDirectory.appending(path: "\(UUID().uuidString).wav")
    }

}
