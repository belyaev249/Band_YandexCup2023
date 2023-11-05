//
//  FileManager.swift
//  Band
//
//  Created by Egor on 05.11.2023.
//

import Foundation

extension FileManager {
    func getDocumentsDirectory() -> URL {
        let paths = urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    func getFileUrl(_ path: String) -> URL {
        let filePath = getDocumentsDirectory().appendingPathComponent(path)
        return filePath
    }
}
