//
//  PDFDetailViewModel.swift
//  PDFViewer
//
//  Created by Erick on 2023/10/11.
//

import PDFKit

struct PDFDetailViewModelAction {
    let showBookmarkAlert: (UIAlertController) -> Void
}

protocol PDFDetailViewModelInput {
    func viewDidLoad()
    func tapNextButton(_ pdfView: PDFView)
    func tapBackButton(_ pdfView: PDFView)
    func addBookmark(_ pdfView: PDFView)
    func deleteBookmark(_ pdfView: PDFView)
    func moveBookmark(_ pdfView: PDFView)
}

protocol PDFDetailViewModelOutput {
    var pdfDocumentPublisher: Published<PDFDocument?>.Publisher { get }
}

typealias PDFDetailViewModel = PDFDetailViewModelInput & PDFDetailViewModelOutput

final class DefaultPDFDetailViewModel: PDFDetailViewModel {
    
    // MARK: - Private Property
    private let useCase: PDFViewerUseCase
    private let actions: PDFDetailViewModelAction
    private var pdfData: PDFData
    @Published private var pdfDocument: PDFDocument?
    
    // MARK: - Life Cycle
    init(useCase: PDFViewerUseCase, pdfData: PDFData, actions: PDFDetailViewModelAction) {
        self.useCase = useCase
        self.pdfData = pdfData
        self.actions = actions
        
        loadPDFDocument()
    }
    
    // MARK: - OUTPUT
    var pdfDocumentPublisher: Published<PDFDocument?>.Publisher { $pdfDocument }
}

// MARK: - Load Data
extension DefaultPDFDetailViewModel {
    private func loadPDFDocument() {
        let pdfURL = pdfData.url
        
        Task {
            pdfDocument = await useCase.convertPDFDocument(url: pdfURL)
        }
    }
}

// MARK: - INPUT View event methods
extension DefaultPDFDetailViewModel {
    func viewDidLoad() {
    }
    
    func tapNextButton(_ pdfView: PDFView) {
        pdfView.goToNextPage(nil)
    }
    
    func tapBackButton(_ pdfView: PDFView) {
        pdfView.goToPreviousPage(nil)
    }
    
    func addBookmark(_ pdfView: PDFView) {
        guard let currentPage = pdfView.currentPage,
              let currentIndex = pdfView.document?.index(for: currentPage) else {
            return
        }
        
        pdfData.bookMark[currentIndex] = true
        
        useCase.addBookmarkPDF(to: pdfData, with: currentIndex)
    }
    
    func deleteBookmark(_ pdfView: PDFView) {
        guard let currentPage = pdfView.currentPage,
              let currentIndex = pdfView.document?.index(for: currentPage) else {
            return
        }
        
        pdfData.bookMark[currentIndex] = false
        
        useCase.deleteBookmarkPDF(to: pdfData, with: currentIndex)
    }
    
    func moveBookmark(_ pdfView: PDFView) {
        let alert = UIAlertController(title: "bookmark", message: "", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel)
        let bookmarkIndexs = pdfData.bookMark.filter { $0.value == true }
        bookmarkIndexs.keys.forEach { index in
            let action = UIAlertAction(title: "page \(index + 1)", style: .default) { _ in
                guard let page = pdfView.document?.page(at: index) else {
                    return
                }
                
                pdfView.go(to: page)
            }
            
            alert.addAction(action)
        }
        
        alert.addAction(cancelAction)
        
        actions.showBookmarkAlert(alert)
    }
}
