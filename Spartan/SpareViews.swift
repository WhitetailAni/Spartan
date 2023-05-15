//
//  SpareView.swift
//  Spartan
//
//  Created by RealKGB on 4/10/23.
//

import SwiftUI
import UIKit

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
    let onCommit: () -> Void
    
    var body: some View {
        HStack {
            Button(action: {
                value -= 1
                onCommit()
            }) {
                Image(systemName: "minus")
                    .font(.system(size: 30))
                    .frame(width: 30, height: 30)
            }
            
            Text("\(value)")
                .font(.headline)
            
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
    @State var fontSize: Int

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        let opacity = 0.25
        textView.delegate = context.coordinator
        textView.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
        
        if #available(tvOS 15.0, *) {
            if let dynamicColor = UIColor(named: "systemBackground") {
                textView.backgroundColor = dynamicColor.withAlphaComponent(opacity)
            } else {
                textView.backgroundColor = UIColor.darkGray.withAlphaComponent(opacity)
            }
        } else {
            textView.backgroundColor = UIColor.darkGray.withAlphaComponent(opacity)
        }
        
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        let parent: UIKitTextView
        
        init(_ parent: UIKitTextView) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
    }
}

func task(launchPath: String, arguments: String...) -> NSString {
    let task = NSTask.init()
    task?.setLaunchPath(launchPath)
    task?.arguments = arguments

    let pipe = Pipe()
    task?.standardOutput = pipe

    task?.launch()
    task?.waitUntilExit()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue)

    return output!
}
//https://stackoverflow.com/a/56628715
