import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct Taskmaster: Codable {
    let Filename: String
    let DisplayName: String
    let Country: String
    let Season: String
}

struct ContentView: View {
    let columns = [
        GridItem(.fixed(105)),
        GridItem(.fixed(105)),
        GridItem(.fixed(105)),
        GridItem(.fixed(105)),
        GridItem(.fixed(105)),
        GridItem(.fixed(105))
    ]
    
    @State private var taskmasters: [Taskmaster] = []
    @State private var selectedFilenames: [String] = []
    @State private var selectedImages: Set<String> = []
    @State private var randomTaskmaster: Taskmaster?
    
    var body: some View {
        VStack {
            HStack {
                if let randomTaskmaster = randomTaskmaster {
                    VStack {
                        Image(randomTaskmaster.Filename)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 200)
                            .padding(5)
                            .foregroundColor(.white)
                        Text("\(randomTaskmaster.DisplayName)\n\(randomTaskmaster.Country) - \(randomTaskmaster.Season)")
                            .font(.caption)
                            .padding(5)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                    .padding(5)
                }
                LazyVGrid(columns: columns, spacing: 5) {
                    ForEach(selectedFilenames, id: \.self) { filename in
                        if let taskmaster = taskmasters.first(where: { $0.Filename == filename }) {
                            ZStack {
                                VStack {
                                    Image(filename)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 100, height: 100)
                                        .padding(10)
                                        .colorMultiply(selectedImages.contains(filename) ? Color.gray : Color.white)
                                        .onTapGesture {
                                            toggleSelection(for: filename)
                                        }
                                    Spacer()
                                }
                                VStack {
                                    Spacer()
                                    VStack {
                                        Text("\(taskmaster.DisplayName)\n\(taskmaster.Country) - \(taskmaster.Season)")
                                            .font(.caption)
                                            .padding(5)
                                            .background(selectedImages.contains(filename) ? Color.gray : Color.red)
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.center)
                                    }
                                }
                            }
                            .padding(5)
                        }
                    }
                }
                .padding(10)
            }
            HStack {
                Button(action: {
                    loadTaskmasters()
                }) {
                    Text("New Board")
                }
                .padding()
                
                Button(action: {
                    exportBoard()
                }) {
                    Text("Export Board")
                }
                .padding()
                
                Button(action: {
                    importBoard()
                }) {
                    Text("Import Board")
                }
                .padding()
            }
        }
        .onAppear {
            loadTaskmasters()
        }
    }
    
    func loadTaskmasters() {
        if let url = Bundle.main.url(forResource: "Taskmaster", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let taskmasters = try? JSONDecoder().decode([Taskmaster].self, from: data) {
            self.taskmasters = taskmasters.shuffled()
            self.selectedFilenames = Array(self.taskmasters.prefix(24)).map { $0.Filename }
            let selectedTaskmasters = self.taskmasters.filter { self.selectedFilenames.contains($0.Filename) }
            self.randomTaskmaster = selectedTaskmasters.randomElement()
        }
    }
    
    func toggleSelection(for filename: String) {
        if selectedImages.contains(filename) {
            selectedImages.remove(filename)
        } else {
            selectedImages.insert(filename)
        }
    }
    
    func exportBoard() {
        let selectedTaskmasters = taskmasters.filter { selectedFilenames.contains($0.Filename) }
        if let jsonData = try? JSONEncoder().encode(selectedTaskmasters),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            let savePanel = NSSavePanel()
            savePanel.allowedContentTypes = [UTType.json]
            savePanel.nameFieldStringValue = "ExportedBoard.json"
            if savePanel.runModal() == .OK, let url = savePanel.url {
                try? jsonString.write(to: url, atomically: true, encoding: .utf8)
            }
        }
    }
    
    func importBoard() {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [UTType.json]
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        if openPanel.runModal() == .OK, let url = openPanel.url {
            if let data = try? Data(contentsOf: url),
               let importedTaskmasters = try? JSONDecoder().decode([Taskmaster].self, from: data) {
                self.taskmasters = importedTaskmasters
                self.selectedFilenames = importedTaskmasters.map { $0.Filename }
                self.randomTaskmaster = importedTaskmasters.randomElement()
            }
        }
    }
}

#Preview {
    ContentView()
}
