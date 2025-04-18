//
//  ContentView.swift
//  PokemonAPI_Learning
//
//  Created by cmStudent on 2025/04/14.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var vm = PokemonDataManager()
    var body: some View {
        VStack {
            HStack {
                TextField("ポケモン名を入力",text: $vm.inputName)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
            }
            List(vm.pokemonList) { item in
                Link(destination: item.link) {
                    HStack {
                        AsyncImage(url: item.image) { image in
                            image.resizable().scaledToFit().frame(width: 50)
                        } placeholder: {
                            ProgressView()
                        }
                        Text(item.name)
                            .font(.headline)
                    }
                }
            }
            
        }
        .onAppear() {
                
            Task {
                await vm.loadPokemonNames()
            }
        }
    }
}

#Preview {
    ContentView()
}
