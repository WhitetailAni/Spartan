//
//  PlistDateView.swift
//  Spartan
//
//  Created by RealKGB on 8/24/23.
//

import SwiftUI

struct PlistDateView: View {
	@Binding var value: Date
	@Binding var isPresented: Bool
	
	@State var components: DateComponents = DateComponents()
	@State var calendar = Calendar.current

    var body: some View {
		ScrollView {
			HStack {
				/*Button(action: {
					
				}) {
					Image(systemName: "plus")
				}
				Spacer()*/
			}
			Text(" ")
		
			DatePickerTV(date: $value, components: $components)
			
			Button(action: {
				value = calendar.date(from: components) ?? Date(timeIntervalSinceNow: 6969)
				isPresented = false
			}) {
				Text(LocalizedString("CONFIRM"))
			}
		}
    }
}

struct DatePickerTV: View {
	@Binding var date: Date
	@Binding var components: DateComponents
	
	@State var calendar = Calendar.current

	var body: some View {
		VStack {
			if components.year != nil {
				Text(LocalizedString("PLIST_YEAR"))
				HStack {
					Button(action: {
						components.year! -= 1
					}) {
						Image(systemName: "minus")
							.frame(width: 30, height: 30)
					}
					.disabled(components.year! <= 1970)
					
					TextField(LocalizedString("PLIST_YEAR"), value: $components.year, formatter: NumberFormatter(), onEditingChanged: { _ in
						if components.year! <= 1970 {
							components.year = 1970
						}
					})
					.keyboardType(.numberPad)
					
					Button(action: {
						components.year! += 1
					}) {
						Image(systemName: "plus")
							.frame(width: 30, height: 30)
					}
				}
			}
			if components.month != nil {
				Text(LocalizedString("PLIST_MONTH"))
				HStack {
					Button(action: {
						components.month! -= 1
					}) {
						Image(systemName: "minus")
							.frame(width: 30, height: 30)
					}
					.disabled(components.month! <= 1)
					
					TextField(LocalizedString("PLIST_MONTH"), value: $components.month, formatter: NumberFormatter(), onEditingChanged: { _ in
						if components.month! <= 1 {
							components.month = 1
						}
						if components.month! >= 12 {
							components.month = 12
						}
					})
					.keyboardType(.numberPad)
						
					Button(action: {
						components.month! += 1
					}) {
						Image(systemName: "plus")
							.frame(width: 30, height: 30)
					}
					.disabled(components.month! >= 12)
				}
			}
			if components.day != nil {
				let maxDays = calendar.range(of: .day, in: .month, for: date)?.count
				
				Text(LocalizedString("PLIST_DAY"))
				HStack {
					Button(action: {
						components.day! -= 1
					}) {
						Image(systemName: "minus")
							.frame(width: 30, height: 30)
					}
					.disabled(components.day! <= 1)
					
					TextField(LocalizedString("PLIST_DAY"), value: $components.day, formatter: NumberFormatter(), onEditingChanged: { _ in
						if components.day! <= 1 {
							components.day = 1
						}
						if components.day! >= maxDays ?? 28 {
							components.day = maxDays ?? 28
						}
					})
						.keyboardType(.numberPad)
					
					Button(action: {
						components.day! += 1
					}) {
						Image(systemName: "plus")
							.frame(width: 30, height: 30)
					}
					.disabled(components.month! >= maxDays ?? 28)
				}
			}
			
			if components.hour != nil {
				Text(LocalizedString("PLIST_HOUR"))
				HStack {
					Button(action: {
						if components.hour == 0 {
							components.hour = 23
						} else {
							components.hour! -= 1
						}
					}) {
						Image(systemName: "minus")
							.frame(width: 30, height: 30)
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
						if components.hour! == 23 {
							components.hour = 0
						} else {
							components.hour! += 1
						}
					}) {
						Image(systemName: "plus")
							.frame(width: 30, height: 30)
					}
				}
			}
			if components.minute != nil {
				Text(LocalizedString("PLIST_MINUTE"))
				HStack {
					Button(action: {
						if components.minute == 0 {
							components.minute = 59
						} else {
							components.minute! -= 1
						}
					}) {
						Image(systemName: "minus")
							.frame(width: 30, height: 30)
					}
					
					TextField(LocalizedString("PLIST_HOUR"), value: $components.minute, formatter: NumberFormatter(), onEditingChanged: { _ in
						if components.minute! < 0 {
							components.minute! = 0
						}
						if components.minute! > 59 {
							components.minute = 59
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
							.frame(width: 30, height: 30)
					}
				}
			}
			if components.second != nil {
				Text(LocalizedString("PLIST_SECOND"))
				HStack {
					Button(action: {
						if components.second! <= 0 {
							components.second = 59
						} else {
							components.second! -= 0
						}
					}) {
						Image(systemName: "minus")
							.frame(width: 30, height: 30)
					}
					
					TextField(LocalizedString("PLIST_HOUR"), value: $components.second, formatter: NumberFormatter(), onEditingChanged: { _ in
						if components.second! < 0 {
							components.second = 0
						}
						if components.second! > 59 {
							components.second = 59
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
							.frame(width: 30, height: 30)
					}
				}
			}
		}
		.onAppear {
			calendar.locale = .autoupdatingCurrent
			components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
		}
	}
}
