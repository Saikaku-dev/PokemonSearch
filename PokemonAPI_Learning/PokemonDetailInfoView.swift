//
//  PokemonDetailInfoView.swift
//  PokemonAPI_Learning
//
//  Created by cmStudent on 2025/04/20.
//

import SwiftUI

struct PokemonDetailInfoView: View {
    @ObservedObject var pokemon: PokemonModel
    @State var showImageViewer = false
    @State var selectedImageURL: URL?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Button(action: {
                selectedImageURL = pokemon.image
                showImageViewer = true
            }) {
                AsyncImage(url: pokemon.image) { image in
                    ZStack(alignment: .topTrailing)  {
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300)
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white)
                            .padding(4)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                            .offset(x: 10, y: 4)
                    }
                } placeholder: {
                    ProgressView()
                }
            }
            
            HStack {
                Text("JP")
                    .infoTitleStyle()
                Text(pokemon.jpName)
                    .underline()
            }
            
            HStack {
                Text("EN")
                    .infoTitleStyle()
                Text(pokemon.name)
                    .underline()
            }
            
            Link(destination: pokemon.link) {
                Text("ポケモン図鑑 →")
            }
        }
        .fullScreenCover(isPresented: $showImageViewer) {
            FullScreenImageViewer(imageURL: $selectedImageURL, isPresented: $showImageViewer)
        }
    }
}

extension View {
    func infoTitleStyle() -> some View {
        self
            .padding()
            .background(Color.green.opacity(0.3))
            .cornerRadius(15)
    }
}

#Preview {
    PokemonDetailInfoView(pokemon: PokemonModel(
        name: "Pikachu",
        jpName: "ピカチュウ",
        image: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/25.png")!,
        link: URL(string: "https://www.pokemon.com/us/pokedex/pikachu")!,
        pokemonId: "25"
    ))
}
