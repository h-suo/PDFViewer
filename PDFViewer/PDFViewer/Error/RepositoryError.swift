//
//  RepositoryError.swift
//  PDFViewer
//
//  Created by Erick on 2023/10/16.
//

import Foundation

enum RepositoryError: LocalizedError {
  case creationFailed
  case updateFailed
  case deletionFailed
  case invalidURL
  
  public var errorDescription: String? {
    switch self {
    case .creationFailed:
      return "Creation from repository failed."
    case .updateFailed:
      return "Update from repository failed."
    case .deletionFailed:
      return "Deletion from repository failed."
    case .invalidURL:
      return "The url is not in pdf format."
    }
  }
}
