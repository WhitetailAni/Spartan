//
//  PlistDataView.swift
//  Spartan
//
//  Created by RealKGB on 8/21/23.
//

import SwiftUI

struct PlistDataView: View {
	@Binding var newData: Any
	@State var nameOfKey: String = ""
	@State var isFromDict: Bool
	@Binding var isPresented: Bool
	
	@State var displayData = [""]
	@State var value: Data = Data()
	@State var null = false

	var body: some View {
		VStack {
			HStack {
				Spacer()
				if isFromDict {
					Text(nameOfKey)
						.if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
							view.scaledFont(name: "BotW Sheikah Regular", size: 35)
						}
				}
				
				Spacer()
				Button(action: {
					var dataAsString: String {
						var string = ""
						for i in 0..<displayData.count {
							string += displayData[i]
						}
						return string
					}
					let data = Data(fromHexEncodedString: dataAsString)
					newData = data! as Data //to make sure that we don't end up with Data? anywhere. would cause HUGE problems.
					isPresented = false
				}) {
					Image(systemName: "checkmark")
				}
				.onAppear {
					let data: Data = newData as! Data
					var hexString = ""
					hexString = data.map { String(format: "%02hhx", $0) }.joined(separator: "")
					for index in stride(from: 0, to: hexString.count, by: 8) {
						let startIndex = hexString.index(hexString.startIndex, offsetBy: index)
						let endIndex = hexString.index(startIndex, offsetBy: 8, limitedBy: hexString.endIndex) ?? hexString.endIndex
						let chunk = String(hexString[startIndex..<endIndex])
						displayData.append(chunk)
					}
				}
			}
			
			List(displayData.indices, id: \.self) { index in
				TextField("", text: $displayData[index])
			}
		}
	}
}
