//
//  ContentView.swift
//  Shared
//
//  Created by Venti on 26/06/2022.
//

import SwiftUI

struct ContentView: View {
    @State var illustID: String
    @State var illust: PixivImageView
    
    init(){
        self.illustID = "98984002"
        self.illust = PixivImageView(illustID: "98984002")
    }
    
    var body: some View {
        GeometryReader{ geometry in
        VStack{
            illust
            HStack
            {
                TextField("Illust ID", text: $illustID)
                    .disableAutocorrection(true)
                    .onSubmit {
                        illust.illustContainer.update(illustID)
                        Task.init {
                            await illust.downloadImage()
                        }
                    }
                Button()
                {
                    illust.illustContainer.update(illustID)
                    Task.init {
                        await illust.downloadImage()
                    }
                }
                label :
                {
                    Text("Load")
                }
            }}
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
