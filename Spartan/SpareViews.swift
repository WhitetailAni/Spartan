//
//  SpareView.swift
//  Spartan
//
//  Created by RealKGB on 4/10/23.
//

import SwiftUI
import UIKit
import Foundation

//this is for various global stuff that doesn't belong to a specific view. frameworks, view modifiers, view elements, UIViewRepresentables, etc

let fileManager = FileManager.default

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

struct Checkbox: View {
	@Binding var value: Bool
	@State var label: String = ""
	let onCommit: () -> Void

	var body: some View {
		Button(action: {
			value.toggle()
			onCommit()
		}) {
			HStack {
				Image(systemName: value ? "checkmark.square.fill" : "square")
				Text(label)
			}
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
    public func blending(color: Color) -> some View {
        modifier(ColorBlended(color: color))
    }
    
    func scaledFont(name: String, size: Double) -> some View {
        return self.modifier(ScaledFont(name: name, size: size))
    }
    
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, content: (Self) -> Content) -> some View {
        if condition {
            content(self)
        } else {
            self
        }
    } //this is one of the best things I've ever written tbh
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
} //this comes close

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
            textView.font = UIFont(name: "SF Mono Regular", size: fontSize)
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

func removeLastChar(_ string: String) -> String {
    return String(substring(str: string, startIndex: string.index(string.startIndex, offsetBy: 0), endIndex: string.index(string.endIndex, offsetBy: -1)))
}

func substring(str: String, startIndex: String.Index, endIndex: String.Index) -> Substring {
    let range: Range = startIndex..<endIndex
    return str[range]
}

var helperPath: String = Bundle.main.bundlePath + "/RootHelper"

func LocalizedString(_ key: String) -> String {
	return NSLocalizedString(key, comment: "")
} //this was not added until much later in the project, which is why it's not used much

func nop() { }

struct null: View {
	var body: some View { EmptyView() }
}

extension Data {
    init?(fromHexEncodedString hexString: String) {
        var hexString = hexString
        let length = hexString.count / 2
        var data = Data(capacity: length)
        
        for _ in 0..<length {
            guard let byte = UInt8(hexString.prefix(2), radix: 16) else {
                return nil
            }
            data.append(byte)
            hexString = String(hexString.dropFirst(2))
        }
        self = data
    }
}

class RootHelperActs {
	class func mv(_ filePath: String, _ fileDest: String) {
	
	}
	
	class func chmod(_ filePath: String, _ perms: Int) {
		spawn(command: "/private/var/containers/Bundle/Application/RootHelper", args: ["ch", filePath, String(perms)], env: [], root: true)
	}
}

extension String: Error { }
