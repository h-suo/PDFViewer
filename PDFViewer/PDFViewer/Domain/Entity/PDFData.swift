//
//  PDFData.swift
//  PDFViewer
//
//  Created by Erick on 2023/10/10.
//

import Foundation

struct PDFData: Hashable {
    let id: UUID
    var title: String
    var url: URL
}