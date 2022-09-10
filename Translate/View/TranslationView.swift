import SwiftUI


struct TranslationView: View {

    @State private var selectedLanguage: Language = Language(id: "en", name: "English")
    @State private var inputText: String = ""
    @StateObject private var viewModel = TranslationViewModel()
    
    var body: some View {
        
        NavigationView {
            VStack {
                List {
                    Section(header: Text("Original")) {
                        TextField("Input text to translate", text: $inputText)
                            .padding()
                    }
                    Section(header: Text("Translated")) {
                        Text(viewModel.translatedText)
                            .padding()
                    }
                    Section {
                        if viewModel.languages.count > 0 {
                            Picker("Translate to:", selection: $selectedLanguage) {
                                ForEach(viewModel.languages, id: \.self) { language in
                                    Text(language.name)
                                }
                            }
                        }
                        else {
                            Text("Loading languages...")
                                .padding()
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                
                Button {
                    viewModel.translate(inputText: inputText, selectedLanguage: selectedLanguage)
                    dismissKeyboard()
                } label: {
                    Text("Translate!")
                }
                .buttonStyle(.bordered)
                .padding()
                
            }
            .navigationTitle("Translator")
            .task {
                await viewModel.fetchLanguages()
            }
        }
        .navigationViewStyle(.stack)
        .disabled(viewModel.languages.count == 0)
        .brightness(viewModel.languages.count == 0 ? -0.3 : 0.0)
        .overlay(
            ProgressView()
                .padding()
                .background(.mint.opacity(0.5))
                .cornerRadius(20)
                .opacity(viewModel.languages.count == 0 ? 1.0 : 0.0)
        )
        .animation(.spring(), value: viewModel.translatedText)
    }
    
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TranslationView()
    }
}
