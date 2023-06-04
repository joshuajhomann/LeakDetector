//
//  DebugView.swift
//  LeakDetector
//
//  Created by Joshua Homann on 6/4/23.
//

import SwiftUI

@MainActor
final class DebugViewModel: ObservableObject {
    @Published private(set) var sections: [SectionModel] = []
    private let canary = Canary(for: DebugViewModel.self)
    func callAsFunction() async {
        var tracked = (await TattleTale.shared.tracked).map { ($0.key, $0.value) }
        let startOfSecondPartition = tracked.partition { key, value in
            value == 1
        }
        sections = [
            .init(
                title: "Duplicates",
                items: tracked[..<startOfSecondPartition]
                    .sorted { $0.1 > $1.1}
                    .map { "\($0) count: \($1)"}
            ),
            .init(
                title: "Single Instances",
                items: tracked[startOfSecondPartition...]
                    .sorted { $0.0 < $1.0}
                    .map { $0.0 }
            )
        ]
    }
}

extension DebugViewModel {
    struct SectionModel: Identifiable, Hashable {
        var id: String { title }
        var title: String
        var items: [String]
    }
}

struct DebugView: View {
    @Binding var shouldShow: Bool
    @StateObject private var viewModel = DebugViewModel()
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.sections) { section in
                    Section {
                        ForEach(section.items, id: \.self) { item in
                            Text(item)
                        }
                    } header: {
                        Text(section.title)
                    }
                }
            }
            .toolbar {
                ToolbarItem { Button("Done") { shouldShow = false } }
            }
        }
        .task {
            await viewModel()
        }
    }
}

