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
    @State var fontSize: Int

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        let opacity = 0.25
        let sheikahFont = UIFont(name: "BotW Sheikah Regular", size: CGFloat(fontSize))
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
        if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) {
            textView.font = sheikahFont
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

func task(launchPath: String, arguments: String, envVars: String) {
    var pid: pid_t = 0

    let argumentsC = strdup(arguments)
    let argv: [UnsafeMutablePointer<CChar>?] = [argumentsC, nil]
    let envC = strdup(envVars)
    let envv: [UnsafeMutablePointer<CChar>?] = [envC, nil]

    posix_spawnp(&pid, launchPath, nil, nil, argv, envv)
}

func taskSnoop(_ closure: () -> Void) -> String {
    let outPipe = Pipe()
    var outString = ""
    let sema = DispatchSemaphore(value: 0)
    outPipe.fileHandleForReading.readabilityHandler = { fileHandle in
        let data = fileHandle.availableData
        if data.isEmpty  { // end-of-file condition
            fileHandle.readabilityHandler = nil
            sema.signal()
        } else {
            outString += String(data: data,  encoding: .utf8)!
        }
    }
    print("Capturing command line")

    // Redirect
    setvbuf(stdout, nil, _IONBF, 0)
    let savedStdout = dup(STDOUT_FILENO)
    dup2(outPipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)

    closure()

    // Undo redirection
    dup2(savedStdout, STDOUT_FILENO)
    try! outPipe.fileHandleForWriting.close()
    close(savedStdout)
    sema.wait() // Wait until read handler is done

    print("Ending capture")
    return outString
}
//https://stackoverflow.com/questions/73034426/swift-stdout-redirect-to-a-string

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

class AppInfo {
    func bundleDir(bundleID: String) -> String {
        return Bundle.main.bundleURL.appendingPathComponent(bundleID).path
    }
    
    func dataDir(bundleID: String) -> String? {
        if let dataDirectoryURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?.appendingPathComponent(bundleID) {
            return dataDirectoryURL.path
        } else {
            return nil
        }
    }
    
    func appGroupDir(bundleID: String) -> String? {
        if let appGroupDirectoryURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group." + bundleID)?.appendingPathComponent("Library") {
            return appGroupDirectoryURL.path
        } else {
            return nil
        }
    }
}
