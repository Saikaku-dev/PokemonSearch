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
        NavigationStack {
            VStack {
                TextField("ポケモン名かIDを入力してください",text: $vm.inputName)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                List(vm.pokemonList) { item in
                    Button(action: {
                        vm.selectedPokemon = item
                        vm.isDetailview = true
                    }) {
                        HStack {
                            AsyncImage(url: item.image) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100)
                            } placeholder: {
                                ProgressView()
                            }
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(item.jpName)
                                    Text(item.name)
                                }
                                .fixedSize()
                                .foregroundColor(.black)
                                .padding(.leading,20)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .navigationDestination(isPresented: $vm.isDetailview) {
                        if let selected = vm.selectedPokemon {
                            PokemonDetailInfoView(pokemon: selected, vm: vm)
                                .onDisappear {
                                    vm.isDetailview = false
                                    vm.selectedPokemon = nil
                                }
                        }
                    }
                }
            }
            Button(action: {
                Task {
                    await vm.loadPokemonNames()
                }
                print(vm.isDetailview)
            }) {
                Text("ランダム表示(10体)")
            }
        }
        .onAppear() {
            Task {
                await vm.loadPokemonNames()
            }
        }
    }
}

struct FullScreenImageViewer: View {
    @Binding var imageURL: URL?
    @Binding var isPresented: Bool
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            AsyncImage(url: imageURL) { img in
                img
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(scale)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                scale = lastScale * value
                            }
                            .onEnded { value in
                                lastScale = scale
                            }
                    )
            } placeholder: {
                ProgressView()
                    .scaleEffect(2)
                    .foregroundColor(.white)
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }
}

#Preview {
    ContentView()
}

#Preview {
    FullScreenImageViewer(
        imageURL: .constant(URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/460.png")),
        isPresented: .constant(true)
    )
}
