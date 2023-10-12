//
//  PlistArrayView.swift
//  Spartan
//
//  Created by RealKGB on 8/21/23.
//

import SwiftUI
import Foundation

struct PlistArrayView: View {
	@Binding var values: [PlistValue]
	@Binding var isPresented: Bool
	
	@State var showEditView = false
	@State var showAddView = false

	var body: some View {
		VStack {
			HStack {
				Button(action: {
					showAddView = true
				}) {
					Image(systemName: "plus")
				}
				.sheet(isPresented: $showAddView, content: {
					PlistAddArrayView(plistValue: $values, isPresented: $showAddView)
				})
				
				Spacer()
				Text(" ")
					.if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
						view.scaledFont(name: "BotW Sheikah Regular", size: 40)
					}
					.font(.system(size: 40))
					.multilineTextAlignment(.center)
					.padding(-10)
					.focusable(true)
				Spacer()
				Button(action: {
					isPresented = false
				}) {
					Image(systemName: "checkmark")
				}
			}
			List(values.indices, id: \.self) { index in
				Button(action: {
					if values[index].type == .bool {
						values[index].value = !(values[index].value as! Bool)
					} else {
						showEditView = true
					}
				}) {
					HStack {
						if values[index].value is Bool {
							Image(systemName: values[index].value as! Bool ? "checkmark.square" : "square")
						}
						Text("\(PlistFormatter.formatAnyVarForDisplay(values[index].value)) (\(PlistFormatter.plistKeyTypeToString(values[index].type)))")
					}
				}
				.sheet(isPresented: $showEditView, content: {
					PlistArrayEditor(keyToEdit: $values[index], isPresented: $showEditView)
				})
			}
		}
	}
}
