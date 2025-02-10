import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = RamayanaViewModel()
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            List {
                SearchBar(text: $searchText)
                
                if let kandas = viewModel.ramayanaData?.kandas {
                    ForEach(kandas) { kanda in
                        KandaView(
                            kanda: kanda,
                            themeColor: viewModel.getKandaColor(kanda.colorTheme)
                        )
                    }
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("श्रीरामायण")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Supporting Views
struct KandaView: View {
    let kanda: Kanda
    let themeColor: Color
    @State private var isExpanded = false
    
    var body: some View {
        DisclosureGroup(
            isExpanded: $isExpanded,
            content: {
                ForEach(kanda.sargas) { sarga in
                    NavigationLink(destination: SargaDetailView(sarga: sarga)) {
                        VStack(alignment: .leading) {
                            Text("Sarga \(sarga.id)")
                                .font(.headline)
                            Text(sarga.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                    }
                }
            },
            label: {
                HStack {
                    Rectangle()
                        .fill(themeColor)
                        .frame(width: 4)
                        .cornerRadius(2)
                    
                    VStack(alignment: .leading) {
                        Text(kanda.name)
                            .font(.title2)
                            .bold()
                        Text(kanda.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        )
        .padding(.vertical, 4)
    }
}

struct SargaDetailView: View {
    let sarga: Sarga
    
    var body: some View {
        List(sarga.shlokas) { shloka in
            ShlokaView(shloka: shloka)
        }
        .navigationTitle("Sarga \(sarga.id)")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ShlokaView: View {
    let shloka: Shloka
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("श्लोक \(shloka.id)")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Picker("View", selection: $selectedTab) {
                Text("संस्कृत").tag(0)
                Text("Transliteration").tag(1)
                Text("Meaning").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            
            switch selectedTab {
            case 0:
                Text(shloka.sanskrit)
                    .font(.system(.body, design: .serif))
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
            case 1:
                Text(shloka.romanTransliteration)
                    .font(.system(.body, design: .serif))
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            case 2:
                Text(shloka.meaning)
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
            default:
                EmptyView()
            }
        }
        .padding()
    }
}

// MARK: - Search Bar
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search Ramayana", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.horizontal)
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
