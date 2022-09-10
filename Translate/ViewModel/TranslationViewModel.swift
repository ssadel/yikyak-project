import Foundation

class TranslationViewModel: ObservableObject {
    private let sourceLanguage = Language(id: "en", name: "English")

    @Published var languages: [Language] = []
    @Published var translatedText: String = ""
    
    init() {
        print("TranslationViewModel init")
    }
    
    func fetchLanguages() async {
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
    
    func translate(inputText:String, selectedLanguage:Language) {
        guard let url = URL(string: "https://libretranslate.de/") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let body: [String: AnyHashable] = [
            "q": inputText,
            "source": sourceLanguage.id,
            "target": selectedLanguage.id
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
        
        print(request.description)
        
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            
            guard let data = data, error == nil else {
                return
            }
            
            do {
                let response = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                print(response)
            } catch {
                print("error: ", error)
            }
            
        }
        
        task.resume()
        
        //https://libretranslate.de/?q=\(inputText)&source=\(sourceLanguage.id)&target=\(selectedLanguage.id)
    }
    
}
