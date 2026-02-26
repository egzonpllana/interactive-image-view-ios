//
//  ContentView.swift
//  InteractiveImageViewExample
//
//  Created by Egzon Pllana on 26.2.26.
//

import SwiftUI
import InteractiveImageView

// MARK: - ContentView -

struct ContentView: View {

    // MARK: - State

    @State private var croppedImage: UIImage?
    @State private var lastFailure: String?

    @State private var selectedContentMode: ContentModeOption = .customTwoThirds
    @State private var selectedFocusOffset: IIVFocusOffset = .center
    @State private var isPinchAllowed = true
    @State private var isScrollEnabled = true
    @State private var isDoubleTapToZoomAllowed = true
    @State private var doubleTapZoomFactor: CGFloat = 2.0

    @State private var configID = UUID()
    @State private var showMoreSheet = false

    private let actions = InteractiveImageViewActions()
    private let sampleImage = UIImage(named: "image.png")
    private let screenWidth = UIScreen.main.bounds.width

    // MARK: - Body

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Interactive image with floating pill
                    InteractiveImageViewRepresentable(
                        image: sampleImage,
                        nextContentMode: selectedContentMode.iivContentMode,
                        focusOffset: selectedFocusOffset,
                        isPinchAllowed: isPinchAllowed,
                        isScrollEnabled: isScrollEnabled,
                        isDoubleTapToZoomAllowed: isDoubleTapToZoomAllowed,
                        doubleTapZoomFactor: doubleTapZoomFactor,
                        actions: actions,
                        onCrop: { image in
                            withAnimation { croppedImage = image }
                        },
                        onScroll: { _, _ in },
                        onZoom: { _, _ in },
                        onFail: { fail in lastFailure = "\(fail)" }
                    )
                    .id(configID)
                    .frame(height: screenWidth)
                    .background(Color.black)
                    .overlay(
                        floatingPill
                            .padding(.trailing, 8),
                        alignment: .trailing
                    )

                    Divider()

                    // Crop result
                    resultSection
                }
            }
            .navigationTitle("InteractiveImageView")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
            }
        }
        .navigationViewStyle(.stack)
        .sheet(isPresented: $showMoreSheet) {
            SettingsSheet(
                selectedContentMode: $selectedContentMode,
                selectedFocusOffset: $selectedFocusOffset,
                isPinchAllowed: $isPinchAllowed,
                isScrollEnabled: $isScrollEnabled,
                isDoubleTapToZoomAllowed: $isDoubleTapToZoomAllowed,
                doubleTapZoomFactor: $doubleTapZoomFactor,
                lastFailure: lastFailure,
                onReconfigure: { configID = UUID() }
            )
            .mediumDetentIfAvailable()
        }
    }

    // MARK: - Floating Pill

    private var floatingPill: some View {
        VStack(spacing: 0) {
            pillButton(icon: "arrow.left.and.right.text.vertical") {
                actions.toggleContentMode()
            }
            pillDivider
            pillButton(icon: "crop") {
                actions.crop()
            }
            pillDivider
            pillButton(icon: "rotate.right") {
                actions.rotate(degrees: 90, keepChanges: true)
            }
            pillDivider
            pillButton(icon: "arrow.counterclockwise") {
                configID = UUID()
                withAnimation { croppedImage = nil }
                lastFailure = nil
            }
            pillDivider
            pillButton(icon: "ellipsis") {
                showMoreSheet = true
            }
        }
        .frame(width: 50)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
        .shadow(color: .black.opacity(0.3), radius: 6, y: 2)
    }

    private func pillButton(
        icon: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 50, height: 36)
                .contentShape(Rectangle())
        }
        .buttonStyle(PillButtonStyle())
    }

    private var pillDivider: some View {
        Rectangle()
            .fill(.white.opacity(0.15))
            .frame(height: 1)
            .padding(.horizontal, 6)
    }

    // MARK: - Result Section

    private var resultSection: some View {
        ScrollView {
            if let croppedImage {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Result")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.top, 12)

                    Image(uiImage: croppedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "crop")
                        .font(.system(size: 24))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text("Crop to see result")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary.opacity(0.5))
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 24)
            }
        }
    }
}

// MARK: - PillButtonStyle -

private struct PillButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.5 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - SettingsSheet -

private struct SettingsSheet: View {
    @Binding var selectedContentMode: ContentModeOption
    @Binding var selectedFocusOffset: IIVFocusOffset
    @Binding var isPinchAllowed: Bool
    @Binding var isScrollEnabled: Bool
    @Binding var isDoubleTapToZoomAllowed: Bool
    @Binding var doubleTapZoomFactor: CGFloat
    let lastFailure: String?
    let onReconfigure: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List {
                Section("Content Mode") {
                    Picker("Content Mode", selection: $selectedContentMode) {
                        ForEach(ContentModeOption.allCases) { opt in
                            Text(opt.label).tag(opt)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: selectedContentMode) { _ in onReconfigure() }
                }

                Section("Focus Offset") {
                    Picker("Focus Offset", selection: $selectedFocusOffset) {
                        Text("Beginning").tag(IIVFocusOffset.beginning)
                        Text("Center").tag(IIVFocusOffset.center)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: selectedFocusOffset) { _ in onReconfigure() }
                }

                Section("Gestures") {
                    Toggle("Scroll", isOn: $isScrollEnabled)
                    Toggle("Pinch to Zoom", isOn: $isPinchAllowed)
                    Toggle("Double-Tap Zoom", isOn: $isDoubleTapToZoomAllowed)
                }

                Section("Double-Tap Zoom Factor") {
                    HStack {
                        Slider(
                            value: $doubleTapZoomFactor,
                            in: 1...5,
                            step: 0.5
                        )
                        Text(String(format: "%.1fx", doubleTapZoomFactor))
                            .font(.caption)
                            .monospacedDigit()
                            .foregroundColor(.secondary)
                            .frame(width: 36)
                    }
                }

                if let lastFailure {
                    Section("Last Error") {
                        Label(lastFailure, systemImage: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - ContentModeOption -

private enum ContentModeOption: String, CaseIterable, Identifiable {
    case aspectFill
    case aspectFit
    case widthFill
    case heightFill
    case customTwoThirds

    var id: String { rawValue }

    var label: String {
        switch self {
        case .aspectFill: return "Fill"
        case .aspectFit: return "Fit"
        case .widthFill: return "Width"
        case .heightFill: return "Height"
        case .customTwoThirds: return "2:3"
        }
    }

    var iivContentMode: IIVContentMode {
        switch self {
        case .aspectFill: return .aspectFill
        case .aspectFit: return .aspectFit
        case .widthFill: return .widthFill
        case .heightFill: return .heightFill
        case .customTwoThirds: return .customOffset(offset: 2.0 / 3.0)
        }
    }
}

// MARK: - Medium Detent Modifier -

private struct MediumDetentModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .presentationDetents([.medium])
        } else {
            content
        }
    }
}

extension View {
    func mediumDetentIfAvailable() -> some View {
        modifier(MediumDetentModifier())
    }
}
