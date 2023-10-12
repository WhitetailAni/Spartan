//
//  PlistDataView.swift
//  Spartan
//
//  Created by RealKGB on 8/21/23.
//

import SwiftUI

struct PlistDataView: View {
	@Binding var value: Data
	@Binding var isPresented: Bool
	
	@State var displayData = [""]
	@State var null = false

	var body: some View {
		VStack {
			HStack {
				Spacer()
				Button(action: {
					var dataAsString: String {
						var string = ""
						for i in 0..<displayData.count {
							string += displayData[i]
						}
						return string
					}
					value = Data(fromHexEncodedString: dataAsString)
					isPresented = false
				}) {
					Image(systemName: "checkmark")
				}
				.onAppear {
					var hexString = ""
					hexString = value.map { String(format: "%02hhx", $0) }.joined(separator: "")
					for index in stride(from: 0, to: hexString.count, by: 8) {
						let startIndex = hexString.index(hexString.startIndex, offsetBy: index)
						let endIndex = hexString.index(startIndex, offsetBy: 8, limitedBy: hexString.endIndex) ?? hexString.endIndex
						let chunk = String(hexString[startIndex..<endIndex])
						displayData.append(chunk)
					}
				}
			}
			
			List(displayData.indices, id: \.self) { index in
				TextField("", text: $displayData[index], onCommit: {
					while displayData[index].count < 7 {
						displayData[index] += "0"
					}
				})
			}
		}
	}
}
