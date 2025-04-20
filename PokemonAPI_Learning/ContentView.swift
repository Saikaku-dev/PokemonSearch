//
//  ContentView.swift
//  PokemonAPI_Learning
//
//  Created by cmStudent on 2025/04/14.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var vm = PokemonDataManager()
    @State var showImageViewer = false
    @State var selectedImageURL: URL?
    
    var body: some View {
        VStack {
            TextField("ポケモン名かIDを入力してください",text: $vm.inputName)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            List(vm.pokemonList) { item in
                Link(destination: item.link) {
                    HStack {
                        AsyncImage(url: item.image) { image in
                            Button(action: {
                                selectedImageURL = item.image
                                showImageViewer = true
                            }) {
                                ZStack(alignment: .topTrailing) {
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100)
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(.white)
                                        .padding(4)
                                        .background(Color.black.opacity(0.5))
                                        .clipShape(Circle())
                                        .offset(x: 10, y: 4)
                                }
                            }
                        } placeholder: {
                            ProgressView()
                        }
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.jpName)
                                Text(item.name)
                            }
                            .foregroundColor(.black)
                            .padding(.leading,20)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            Button(action: {
                Task {
                    await vm.loadPokemonNames()
                }
            }) {
                Text("ランダム表示(10体)")
            }
        }
        .fullScreenCover(isPresented: $showImageViewer) {
            FullScreenImageViewer(imageURL: $selectedImageURL, isPresented: $showImageViewer)
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
