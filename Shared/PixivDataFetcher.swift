//
//  PixivDataFetcher.swift
//  PixivViewer
//
//  Created by Venti on 26/06/2022.
//

import Foundation
import SwiftyJSON
import SwiftUI

class PixivImageContainer: ObservableObject, Equatable
{
    static func == (lhs: PixivImageContainer, rhs: PixivImageContainer) -> Bool {
        return lhs.illustID == rhs.illustID
    }
    
    @Published var illustID: String
    @Published var image: Image
    
    init(illustID: String) {
        self.illustID = illustID;
        self.image = Image(systemName: "")
    }
    
    func update(_ newID: String){
        self.illustID = newID
    }
}

struct PixivImageView: View {
    @ObservedObject var illustContainer: PixivImageContainer
    
    var body: some View {
        HStack{
            illustContainer.image
                .resizable()
                .scaledToFit()
        }
        .task {
            await downloadImage()
        }
    }
    
    func getImageUrl() async -> String? {
        let ajaxEndpoint = "https://www.pixiv.net/ajax/illust/" + illustContainer.illustID
        guard let ajaxUrl = URL(string: ajaxEndpoint) else {
            fatalError("No ajax endpoint")
        }
        
        let ajaxRequest = URLRequest(url: ajaxUrl)
        do {
            let (data, resp) = try await URLSession.shared.data(for: ajaxRequest)
            
            guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
                fatalError("Failed to get image metadata")
            }
            
            let illustMetadata = JSON(data as Any)
            
            return illustMetadata["body"]["urls"]["original"].stringValue
        } catch {
            return nil
        }
    }
    
    func downloadImage() async {
        print("Updating Image...")
        let url = "https://www.pixiv.net/en/artworks/" + illustContainer.illustID;
        print(url)
        guard let imageUrl = URL(string: await getImageUrl()!) else {
            fatalError("Wrong Image URL")
        }
        
        var imageRequest = URLRequest(url: imageUrl)
        imageRequest.addValue(url, forHTTPHeaderField: "Referer")
        do {
            let (data, resp) = try await URLSession.shared.data(for: imageRequest)
            guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
                print(resp)
                fatalError("Failed to fetch the image")
            }
            
            #if os(macOS)
            illustContainer.image = Image(nsImage: NSImage(data: data)!)
            #elseif os(iOS)
            illustContainer.image = Image(uiImage: UIImage(data: data)!)
            #endif
        } catch {
        }
        print("Updated")
    }
    
    init(illustID: String) {
        self.illustContainer = PixivImageContainer(illustID: illustID)
    }
}
