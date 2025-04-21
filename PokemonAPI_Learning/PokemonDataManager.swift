//
//  PokemonDataManager.swift
//  PokemonAPI_Learning
//
//  Created by cmStudent on 2025/04/14.
//

import Foundation
import Combine
import AVFoundation

class PokemonModel:Identifiable,ObservableObject {
    let id = UUID()
    let name: String
    let jpName: String
    let image: URL
    let link: URL
    let pokemonId: String
    let soundURL: URL
    
    init(name: String, jpName: String, image: URL, link: URL, pokemonId: String, soundURL: URL) {
        self.name = name
        self.jpName = jpName
        self.image = image
        self.link = link
        self.pokemonId = pokemonId
        self.soundURL = soundURL
    }
}

@MainActor
class PokemonDataManager:ObservableObject {
    @Published var inputName:String = ""
    var cancellables = Set<AnyCancellable>()
    @Published var selectedPokemon: PokemonModel? = nil
    @Published var isDetailview:Bool = false
    @Published var pokemonList: [PokemonModel] = []
    @Published var allPokemonList: [String] = []
    
    var player: AVPlayer?
    
    init() {
        self.addListenerToInputName()
    }
    
    func addListenerToInputName() {
        $inputName
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink {[weak self] word in
                guard let self = self else {
                    
                    return
                }
                print(word)
                Task {
                    await self.searchPokemon(text: word)
                }
            }
            .store(in: &cancellables)
    }
    
    deinit {
        cancellables.forEach{ $0.cancel() }
        cancellables.removeAll()
    }
    
    struct PokemonListResponse:Codable {
        struct Entry: Codable {
            let name: String
            let url: String
        }
        let results: [Entry]
    }
    
    struct Sprites: Codable {
        let front_default: URL
    }
    
    struct PokemonResponse: Codable {
        let name: String
        let sprites: Sprites
        let id: Int
    }
    
    struct PokemonSpeciesResponse: Codable {
        let names: [LocalizaedName]
    }
    
    struct LocalizaedName: Codable {
        let name: String
        let language: Language
    }

    struct Language: Codable {
        let name: String
    }
    
    func loadPokemonNames() async {
        guard let apiUrlStr = SecretsManager.shared.get("PokemonAPIURL"),
              let url = URL(string: apiUrlStr) else {
            print("URL取得失敗")
            return
        }
        do {
            print("URL取得成功: \(apiUrlStr)")
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(PokemonListResponse.self, from: data)
            self.allPokemonList = decoded.results.map { $0.name }.sorted()
            print("データ取得成功 \(allPokemonList.count)個")
            
            await showDefaultPokemons()
        } catch {
            print("データ取得失敗: \(error.localizedDescription)")
        }
    }
    
    func searchPokemon(text:String) async {
        
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return }
        
        var newList:[PokemonModel] = []
        
        if let _ = Int(text) {
            await fetchPokemon(by: text, into: &newList)
        } else {
            let filteredNames = allPokemonList.filter {
                $0.lowercased().contains(text.lowercased())
            }
            
            for name in filteredNames.prefix(10) {
                await fetchPokemon(by: name, into: &newList)
            }
        }
        self.pokemonList = newList
    }
    
    private func fetchPokemon(by key: String, into list: inout [PokemonModel]) async {
        guard let reqUrl = URL(string: "https://pokeapi.co/api/v2/pokemon/\(key)") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: reqUrl)
            let result = try JSONDecoder().decode(PokemonResponse.self, from: data)
            
            let imageURL = result.sprites.front_default
            let pokemonId = result.id
            let pokemonIdStr = String(format: "%04d", pokemonId)
            let link = URL(string: "https://zukan.pokemon.co.jp/detail/\(pokemonIdStr)")!
            
            let speciesURL = URL(string:"https://pokeapi.co/api/v2/pokemon-species/\(pokemonId)")!
            let (speciesData, _) = try await URLSession.shared.data(from: speciesURL)
            let speciesResult = try JSONDecoder().decode(PokemonSpeciesResponse.self, from: speciesData)
            let japaneseName = speciesResult.names.first(where: { $0.language.name == "ja" })?.name ?? result.name.capitalized
            
            let cryURL = URL(string: "https://play.pokemonshowdown.com/audio/cries/\(result.name.lowercased()).mp3")!

            
            
            let newPokemon = PokemonModel(
                name: result.name.capitalized,
                jpName: japaneseName,
                image: imageURL,
                link: link,
                pokemonId: pokemonIdStr,
                soundURL: cryURL
            )
            
            list.append(newPokemon)
        } catch {
            print("検索できません: \(error.localizedDescription)")
        }
    }
    
    func showDefaultPokemons() async {
        var newList: [PokemonModel] = []
        
        let randomNames = allPokemonList.shuffled().prefix(10)
        
        for name in randomNames {
            await fetchPokemon(by: name, into: &newList)
        }
        self.pokemonList = newList
    }
    
    func playSound(from url: URL) {
        player = AVPlayer(url: url)
        player?.play()
    }
}
