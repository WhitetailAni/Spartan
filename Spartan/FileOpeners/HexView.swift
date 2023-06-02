//
//  HexView.swift
//  Spartan
//
//  Created by RealKGB on 5/1/23.
//

import SwiftUI

struct HexView: View {
    @Binding var filePath: String
    @Binding var fileName: String
    
    @State private var hexString: String = ""
    @State private var hexArray: [String] = []

    var body: some View {
        
        HStack {
            Spacer()
            Text(UserDefaults.settings.bool(forKey: "verboseTimestamps") ? filePath + fileName : fileName)
                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                }
                .font(.system(size: 40))
                .multilineTextAlignment(.center)
                .padding(-10)
                .focusable(true) //makes it so you can access the save button
            Spacer()
            Button(action: {
                var cleanedHexString: String = ""
                for i in 0..<hexArray.count {
                    cleanedHexString += hexArray[i].replacingOccurrences(of: " ", with: "")
                }
                let newData = Data(fromHexEncodedString: cleanedHexString) // convert hex string to data object
                do {
                    try newData?.write(to: URL(fileURLWithPath: filePath + fileName)) // write data to file
                } catch {
                    print("Error writing data to file: \(error.localizedDescription)")
                }
            }) {
                Image(systemName: "square.and.arrow.down")
            }
        }
        
        List(hexArray.indices, id: \.self) { index in
            let hexValue = 0x0 + index * 4
            var hexString = String(hexValue, radix: 16)
            HStack {
                Text("0x\(hexString)")
                    .onAppear {
                        while(hexString.count < 8) {
                            hexString = hexString + " "
                        }
                    }
                    .padding()
                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                    }
                TextField(NSLocalizedString("HEX_DATA", comment: ""), text: $hexArray[index])
                    .frame(width: UIScreen.main.nativeBounds.width - 500)
                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                    }
                let cleanedHexString = hexArray[index].replacingOccurrences(of: " ", with: "")
                let hexData = Data(fromHexEncodedString: cleanedHexString)
                Text(String(data: hexData!, encoding: .utf8) ?? "Unable to read file")
                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                    }
            }
        }
        .onAppear {
            var data: Data
            do {
                data = try Data(contentsOf: URL(fileURLWithPath: filePath + fileName))
                hexString = data.map { String(format: "%02hhx", $0) }.joined(separator: "")
                for index in stride(from: 0, to: hexString.count, by: 8) {
                    let startIndex = hexString.index(hexString.startIndex, offsetBy: index)
                    let endIndex = hexString.index(startIndex, offsetBy: 8, limitedBy: hexString.endIndex) ?? hexString.endIndex
                    let chunk = String(hexString[startIndex..<endIndex])
                    let one = chunk.prefix(2)
                    let two = chunk.dropFirst(2).prefix(2)
                    let three = chunk.dropFirst(4).prefix(2)
                    let four = chunk.dropFirst(6).prefix(2)
                    hexArray.append("\(one) \(two) \(three) \(four)")
                    //hacky but no out of bounds
                }
            } catch {
                print("L")
            }
        }
    }
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
