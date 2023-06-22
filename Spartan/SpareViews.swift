//
//  SpareView.swift
//  Spartan
//
//  Created by RealKGB on 4/10/23.
//

import SwiftUI
import UIKit
import Foundation

//this is to put extra views that are used by other views - UIKit progress bar, checkbox, etc.

struct SpareView: View {
    var body: some View {
        VStack {
            Text("Take wrong turns. Talk to strangers. Open unmarked doors. And if you see a group of people in a field, go find out what they are doing.")
            Text("")
            Text("Except when that wrong turn leads you to a nonexistent file.")
        }
    }
}

struct UIKitProgressView: UIViewRepresentable {
    typealias UIViewType = UIProgressView
    
    @Binding var value: Double
    var total: Double
    
    func makeUIView(context: Context) -> UIProgressView {
        let progressView = UIProgressView()
        progressView.progressTintColor = .white
        progressView.trackTintColor = .gray
        return progressView
    }
    
    func updateUIView(_ uiView: UIProgressView, context: Context) {
        uiView.progress = Float(value / total)
    }
}

struct Checkbox: ToggleStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(configuration.isOn ? .green : .gray)
            configuration.label
        }
    }
}

struct StepperTV: View {
    @Binding var value: Int
    @State var isHorizontal: Bool
    let onCommit: () -> Void
    
    var body: some View {
        if(isHorizontal) {
            HStack {
                minus
                valueText
                plus
            }
        } else {
            VStack {
                plus
                valueText
                minus
            }
        }
    }
    
    var minus: some View {
        Button(action: {
            value -= 1
            onCommit()
        }) {
            Image(systemName: "minus")
                .font(.system(size: 30))
                .frame(width: 30, height: 30)
        }
    }
    
    var valueText: some View {
        Text("\(value)")
            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
            }
            .font(.headline)
    }
    
    var plus: some View {
        Button(action: {
            value += 1
            onCommit()
        }) {
            Image(systemName: "plus")
                .font(.system(size: 30))
                .frame(width: 30, height: 30)
        }
    }
}


struct UIViewControllerWrapper<UIViewControllerType: UIViewController>: UIViewControllerRepresentable {
    let viewControllerFactory: () -> UIViewControllerType
    
    init(_ viewControllerFactory: @escaping () -> UIViewControllerType) {
        self.viewControllerFactory = viewControllerFactory
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<UIViewControllerWrapper>) -> UIViewControllerType {
        viewControllerFactory()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: UIViewControllerRepresentableContext<UIViewControllerWrapper>) {
    }
}

extension View {
    public func blending(color: Color) -> some View {
        modifier(ColorBlended(color: color))
    }
}

public struct ColorBlended: ViewModifier {
    fileprivate var color: Color
  
    public func body(content: Content) -> some View {
        VStack {
            ZStack {
                content
                color.blendMode(.sourceAtop)
            }
            .drawingGroup(opaque: false)
        }
    }
}

struct ContextMenuButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        let paddingInt: CGFloat = -7
        let opacityInt: CGFloat = 1.0
        
        configuration.label
            .padding(paddingInt)
            .opacity(opacityInt)
    }
}

struct UIKitTapGesture: UIViewRepresentable {
    let action: () -> Void
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.onTap))
        view.addGestureRecognizer(tapGesture)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }
    
    class Coordinator: NSObject {
        let action: () -> Void
        
        init(action: @escaping () -> Void) {
            self.action = action
        }
        
        @objc func onTap() {
            action()
        }
    }
}

struct UIKitTextView: UIViewRepresentable {
    @Binding var text: String
    @State var fontSize: CGFloat
    @Binding var isTapped: Bool

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        let opacity = 0.25
        textView.delegate = context.coordinator
        textView.isUserInteractionEnabled = !text.isEmpty
        textView.isSelectable = true
        
        if #available(tvOS 15.0, *) {
            if let dynamicColor = UIColor(named: "systemBackground") {
                textView.backgroundColor = dynamicColor.withAlphaComponent(opacity)
            } else {
                textView.backgroundColor = UIColor.darkGray.withAlphaComponent(opacity)
            }
        } else {
            textView.backgroundColor = UIColor.darkGray.withAlphaComponent(opacity)
        }
        if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) {
            textView.font = UIFont(name: "BotW Sheikah Regular", size: fontSize)
        } else {
            textView.font = UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
        }
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.textViewTapped))
        textView.addGestureRecognizer(tapGesture)
        
        if isTapped {
            textView.panGestureRecognizer.allowedTouchTypes = [NSNumber(value: UITouch.TouchType.indirect.rawValue)]
        } else {
            textView.panGestureRecognizer.allowedTouchTypes = [0]
        }
        
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        uiView.isUserInteractionEnabled = !text.isEmpty
        if isTapped {
            uiView.panGestureRecognizer.allowedTouchTypes = [NSNumber(value: UITouch.TouchType.indirect.rawValue)]
        } else {
            uiView.panGestureRecognizer.allowedTouchTypes = [0]
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, isTapped: $isTapped)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        let parent: UIKitTextView
        @Binding var isTapped: Bool
    
        init(_ parent: UIKitTextView, isTapped: Binding<Bool>) {
            self.parent = parent
            _isTapped = isTapped
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
        
        @objc func textViewTapped() {
            parent.isTapped.toggle()
        }
    }
}

struct ScaledFont: ViewModifier {
    @Environment(\.sizeCategory) var sizeCategory
    var name: String
    var size: Double

    func body(content: Content) -> some View {
       let scaledSize = UIFontMetrics.default.scaledValue(for: size)
        return content.font(.custom(name, size: scaledSize))
    }
}
extension View {
    func scaledFont(name: String, size: Double) -> some View {
        return self.modifier(ScaledFont(name: name, size: size))
    }
}

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, content: (Self) -> Content) -> some View {
        if condition {
            content(self)
        } else {
            self
        }
    }
}

extension Font {
    init(cgFont: CGFont, size: CGFloat) {
        let fontName = cgFont.postScriptName as String?
        self = Font.custom(fontName!, size: size) // Adjust the size as per your requirements
    }
}

extension Image {
    init(cgImage: CGImage) {
        self = Image(uiImage: UIImage(cgImage: cgImage))
    }
}
