//
//  ContentView.swift
//  LeakDetector
//
//  Created by Joshua Homann on 6/2/23.
//

import SwiftUI

@MainActor
final class ViewModel: ObservableObject {
    @Published var x = ""
    private let canary = Canary(for: ViewModel.self)
    private let a = Timer
        .publish(every: 1, on: .main, in: .common)
        .autoconnect()
        .map {_ in 1 }
        .scan(0, +)
        .prepend(0)
        .map { "A: \($0)"}

    func callAsFunction() async {
        Task {
            for await value in a.values {
                x = value
            }
        }
    }
}

struct Modal: View {
    @StateObject private var viewModel = ViewModel()
    @Binding var shouldShow: Bool
    @State private var path = NavigationPath()
    var body: some View {
        NavigationStack(path: $path) {
            Text(viewModel.x)
            .font(.largeTitle)
            .navigationTitle("Modal View Root")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("Done") { shouldShow = false }
                }
            }
            .task {
                await viewModel()
            }
        }
    }
}

struct ContentView: View {
    @State private var shouldShow = false
    var body: some View {
        Button("Show") { shouldShow.toggle() }
            .sheet(isPresented: $shouldShow) { Modal(shouldShow: $shouldShow) }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
