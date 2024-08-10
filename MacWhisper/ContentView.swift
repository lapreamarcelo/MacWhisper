//
//  ContentView.swift
//  MacWhisper
//
//  Created by Marcelo Laprea on 10/8/24.
//

import OpenAI
import SwiftUI

struct ContentView: View {
    @State private var transcription: String = ""
    @State private var voiceType: AudioSpeechQuery.AudioSpeechVoice = .echo
    
    let openAI = OpenAI(apiToken: "")
    
    @MainActor
    func createAudio(text: String) async {
        do {
            let query = AudioSpeechQuery(model: .tts_1, input: text, voice: voiceType, responseFormat: .mp3, speed: 1.0)
            let result = try await openAI.audioCreateSpeech(query: query)
            let savePanel = NSSavePanel()
            savePanel.title = "Save audio"
            savePanel.nameFieldStringValue = "MacWhisper audio"
            savePanel.allowedContentTypes = [.mp3]
            savePanel.canCreateDirectories = true
            let response = await savePanel.begin()
            if response == .OK, let url = savePanel.url {
                try result.audio.write(to: url)
            }
        } catch {
            print(error)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField(text: $transcription, axis: .vertical) {
                    Text("transcription")
                }
                Picker(selection: $voiceType) {
                    ForEach(AudioSpeechQuery.AudioSpeechVoice.allCases, id: \.self) { voiceType in
                        Text(voiceType.rawValue)
                    }
                } label: {
                    Text("Voice type")
                }
            }
            .navigationTitle("MacWhisper")
            .padding()
            .toolbar(content: {
                ToolbarItem() {
                    Button("createAudio") {
                        Task {
                            await createAudio(text: transcription)
                        }
                    }
                }
            })
        }
    }
}

#Preview {
    ContentView()
}
