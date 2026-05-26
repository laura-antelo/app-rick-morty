//
//  PDFGenerator.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 25/5/26.
//

import Foundation
import UIKit

final class PDFGenerator {
    
    func generatePDF(title: String, content: String, filename: String) -> URL? {
        let pageRect = CGRect(x:0, y: 0, width: 595, height: 842)
        
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(safeFileName(filename))
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        
        do {
            try renderer.writePDF(to: fileURL) { context in
                context.beginPage()
                
                drawTitle(title, in: pageRect)
            }
            
            return fileURL
        } catch {
            print("ERROR generating PDF: ", error)
            return nil
        }
    }
    
    private func drawTitle(_ title: String, in pageRect: CGRect) {
        let titleAttributes: [NSAttributedString.Key: Any] = [ .font: UIFont.boldSystemFont(ofSize: 22)]
        
        let titleRect = CGRect(x: 40, y: 40, width: pageRect.width - 80, height: 40)
        
        title.draw(in: titleRect, withAttributes: titleAttributes)
    }
    
    private func drawContent(_ content: String, in pageRect: CGRect) {
        let contentAttributes: [NSAttributedString.Key: Any] = [ .font: UIFont.systemFont(ofSize: 12)]
        
        let contentRect = CGRect(x: 40, y: 100, width: pageRect.width - 80, height: pageRect.height - 140)
        
        content.draw(in: contentRect, withAttributes: contentAttributes)
    }
    
    private func safeFileName(_ fileName: String) -> String {
        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_"))
        
        let cleanedName = fileName
            .components(separatedBy: allowedCharacters.inverted)
            .joined(separator: "_")
        
        if cleanedName.hasSuffix(".pdf") {
            return cleanedName
        }
        
        return "\(cleanedName).pdf"
    }
}
