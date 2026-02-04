import SwiftUI

struct GeneratorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = GeneratorViewModel()
    var onUsePassword: ((String) -> Void)?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Generated password display
                Text(viewModel.generatedPassword)
                    .font(.system(.title3, design: .monospaced))
                    .fontWeight(.medium)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.theme.secondaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .textSelection(.enabled)
                    .padding(.horizontal)

                StrengthMeterView(strength: viewModel.strength)
                    .padding(.horizontal)

                // Options
                Form {
                    Section {
                        HStack {
                            Text("Length: \(viewModel.options.length)")
                            Slider(
                                value: Binding(
                                    get: { Double(viewModel.options.length) },
                                    set: {
                                        viewModel.options.length = Int($0)
                                        viewModel.regenerate()
                                    }
                                ),
                                in: 8...64,
                                step: 1
                            )
                        }
                    }

                    Section {
                        toggleRow("Uppercase (A-Z)", isOn: $viewModel.options.includeUppercase)
                        toggleRow("Lowercase (a-z)", isOn: $viewModel.options.includeLowercase)
                        toggleRow("Numbers (0-9)", isOn: $viewModel.options.includeNumbers)
                        toggleRow("Symbols (!@#$)", isOn: $viewModel.options.includeSymbols)
                        toggleRow("Exclude Ambiguous (0O1lI)", isOn: $viewModel.options.excludeAmbiguous)
                    }
                }
                .formStyle(.grouped)
                .scrollContentBackground(.hidden)

                HStack(spacing: 12) {
                    Button {
                        ClipboardService.copy(viewModel.generatedPassword)
                    } label: {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                    .buttonStyle(.bordered)

                    Button {
                        viewModel.regenerate()
                    } label: {
                        Label("Regenerate", systemImage: "arrow.clockwise")
                    }
                    .buttonStyle(.bordered)

                    if onUsePassword != nil {
                        Button {
                            onUsePassword?(viewModel.generatedPassword)
                            dismiss()
                        } label: {
                            Text("Use")
                        }
                        .buttonStyle(.primary)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("Password Generator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func toggleRow(_ title: String, isOn: Binding<Bool>) -> some View {
        Toggle(title, isOn: isOn)
            .onChange(of: isOn.wrappedValue) { _, _ in
                viewModel.regenerate()
            }
    }
}
