//
//  PlistDateView.swift
//  Spartan
//
//  Created by RealKGB on 8/24/23.
//

import SwiftUI

struct PlistDateView: View {
	@Binding var newDate: Any
	@State var nameOfKey: String = ""
	@State var isFromDict: Bool
	@Binding var isPresented: Bool
	
	@State var value: Date = Date()

    var body: some View {
        if isFromDict {
			Text(nameOfKey)
				.if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
					view.scaledFont(name: "BotW Sheikah Regular", size: 35)
				}
		}
	
		DatePickerTV(date: value)
		
		Button(action: {
			newDate = value
			isPresented = false
		}) {
			Text(LocalizedString("CONFIRM"))
		}
		.onAppear {
			value = newDate as! Date
		}
    }
}

struct DatePickerTV: View {
	@State var date: Date
	
	@State var calendar = Calendar.current
	@State var components: DateComponents = DateComponents()

	var body: some View {
		VStack {
			if components.year != nil {
				HStack {
					Button(action: {
						components.year! -= 1
					}) {
						Image(systemName: "minus")
					}
					TextField(LocalizedString("PLIST_YEAR"), value: $components.year, formatter: NumberFormatter())
						.keyboardType(.numberPad)
					Button(action: {
						components.year! += 1
					}) {
						Image(systemName: "plus")
					}
				}
			}
			if components.month != nil {
				Picker(LocalizedString("PLIST_MONTH"), selection: $components.month) {
					VStack {
						ForEach(0..<6, id: \.self) { i in
							Text(calendar.monthSymbols[i]).tag(i + 1)
						}
						ForEach(6..<12, id: \.self) { i in
							Text(calendar.monthSymbols[i]).tag(i + 1)
						}
					}
				}
			}
			if components.day != nil {
				let maxDays = getDaysInMonth(month: components.day!, year: components.year!)
				HStack {
					Button(action: {
						if !(components.day! < 1) {
							components.day! -= 1
						}
					}) {
						Image(systemName: "minus")
					}
					TextField(LocalizedString("PLIST_DAY"), value: $components.day, formatter: NumberFormatter(), onCommit: {
						if components.day! > maxDays {
							components.day = maxDays
						}
						if components.day! < 1 {
							components.day = 1
						}
					})
					.keyboardType(.numberPad)
					Button(action: {
						if !(components.day! > maxDays) {
							components.day! += 1
						}
					}) {
						Image(systemName: "plus")
					}
				}
			}
			
			HStack {
				if components.hour != nil {
					VStack {
						Button(action: {
							if components.hour == 0 {
								components.hour = 23
							} else {
								components.hour! -= 1
							}
						}) {
							Image(systemName: "minus")
						}
						TextField(LocalizedString("PLIST_HOUR"), value: $components.hour, formatter: NumberFormatter(), onEditingChanged: { _ in
							if components.hour! < 0 {
								components.hour! = 0
							}
							if components.hour! > 23 {
								components.hour! -= 23
							}
						})
						.keyboardType(.numberPad)
						Button(action: {
							if components.hour == 23 {
								components.hour = 0
							} else {
								components.hour! += 1
							}
						}) {
							Image(systemName: "plus")
						}
					}
				}
				if components.minute != nil {
					VStack {
						Button(action: {
							if components.minute == 0 {
								components.minute = 59
							} else {
								components.minute! -= 1
							}
						}) {
							Image(systemName: "minus")
						}
						TextField(LocalizedString("PLIST_HOUR"), value: $components.minute, formatter: NumberFormatter(), onEditingChanged: { _ in
							if components.minute! < 0 {
								components.minute! = 0
							}
							if components.minute! > 59 {
								components.minute! -= 59
							}
						})
						.keyboardType(.numberPad)
						Button(action: {
							if components.minute == 59 {
								components.minute = 0
							} else {
								components.minute! += 1
							}
						}) {
							Image(systemName: "plus")
						}
					}
				}
				if components.second != nil {
					VStack {
						Button(action: {
							if components.second == 0 {
								components.second = 59
							} else {
								components.second! -= 1
							}
						}) {
							Image(systemName: "minus")
						}
						TextField(LocalizedString("PLIST_HOUR"), value: $components.second, formatter: NumberFormatter(), onEditingChanged: { _ in
							if components.second! < 0 {
								components.second! = 0
							}
							if components.second! > 59 {
								components.second! -= 59
							}
						})
						.keyboardType(.numberPad)
						Button(action: {
							if components.second == 59 {
								components.second = 0
							} else {
								components.second! += 1
							}
						}) {
							Image(systemName: "plus")
						}
					}
				}
			}
			.onAppear {
				calendar.locale = .autoupdatingCurrent
				components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
			} //why is the .onAppear on this? what other view element should I put it on lol
		}
	}
}
