import Foundation

class TranslationViewModel: ObservableObject {
    private let sourceLanguage = Language(id: "en", name: "English")

    @Published var languages: [Language] = []
    @Published var translatedText: String = ""
    
    init() {
        print("TranslationViewModel init")
        //fetchLanguages()
    }
    
    func fetchLanguages() {
        guard let url = URL(string: "https://libretranslate.com/languages") else { return }
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            if error == nil {
                if let data = data {
                    do {
                        let languages = try JSONDecoder().decode([Language].self, from: data)
                        DispatchQueue.main.async {
                            self?.languages = languages
                        }
                    } catch {
                        print(error)
                    }
                }
            }
        }
        task.resume()
    }
    
    func fetchLanguagesAsynchronously() async {
        guard let url = URL(string: "https://libretranslate.com/languages") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let decodedResponse = try? JSONDecoder().decode([Language].self, from: data) {
                let languages = decodedResponse
                DispatchQueue.main.async {
                    self.languages = languages
                }
            }
        } catch {
            print("--> there was an error decoding the response: ", error)
        }
    }
    
}
