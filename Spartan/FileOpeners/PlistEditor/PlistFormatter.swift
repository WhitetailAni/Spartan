//
//  PlistFormatters.swift
//  Spartan
//
//  Created by RealKGB on 8/21/23.
//

import Foundation

struct PlistKey {
	var key: String
	var value: Any
	var type: PlistKeyType
	
	init() {
		key = ""
		value = 0
		type = .unknown
	}
	
	init(key: String, value: Any, type: PlistKeyType) {
		self.key = key
		self.value = value
		self.type = type
	}
}

struct PlistValue {
	var value: Any
	var type: PlistKeyType
	
	init () {
		value = 0
		type = .unknown
	}
	
	init(value: Any, type: PlistKeyType) {
		self.value = value
		self.type = type
	}
}

enum PlistKeyType {
	case bool
	case int
	case string
	case array
	case dict
	case data
	case date
	case unknown
	
	func stringRepresentation() -> String {
		switch self {
		case .bool:
			return "Boolean"
		case .int:
			return "Integer"
		case .string:
			return "String"
		case .array:
			return "Array"
		case .dict:
			return "Dictionary"
		case .data:
			return "Data"
		case .date:
			return "Date"
		default:
			return "Data"
		}
	}
}

class PlistFormatter {
	class func swiftDictToPlistKeyArray(_ dict: [String: Any]) -> [PlistKey] {
		var array: [PlistKey] = []
		
		for (key, value) in dict {
			let type: PlistKeyType = {
				switch value {
				case is Bool:
					return .bool
				case is Int:
					return .int
				case is String:
					return .string
				case is [Any]:
					return .array
				case is [String: Any]:
					return .dict
				case is Data:
					return .data
				case is Date:
					return .date
				default:
					return .data
				}
			}()
			switch type {
			case .array:
				array.append(PlistKey(key: key, value: swiftArrayToPlistValueArray(value as! [Any]), type: type))
			case .dict:
				array.append(PlistKey(key: key, value: swiftDictToPlistKeyArray(value as! [String: Any]), type: type))
			default:
				array.append(PlistKey(key: key, value: value, type: type))
			}
		}
		
		array.sort { $0.key < $1.key }
		
		return array
	}
	
	class func plistKeyArrayToSwiftDict(_ array: [PlistKey]) -> [String: Any] {
		var dict: [String: Any] = [:]
		for i in 0..<array.count {
			dict.updateValue(array[i].value, forKey: array[i].key)
		}
		return dict
	}
	
	class func swiftArrayToPlistValueArray(_ array: [Any]) -> [PlistValue] {
		var newArray: [PlistValue] = []
		
		for value in array {
			let type: PlistKeyType = {
				switch value {
				case is Bool:
					return .bool
				case is Int:
					return .int
				case is String:
					return .string
				case is [Any]:
					return .array
				case is [String: Any]:
					return .dict
				case is Data:
					return .data
				case is Date:
					return .date
				default:
					return .data
				}
			}()
			switch type {
			case .dict:
				let key = PlistValue(value: swiftDictToPlistKeyArray(value as! [String: Any]), type: type)
				newArray.append(key)
			case .array:
				newArray.append(PlistValue(value: swiftArrayToPlistValueArray(value as! [Any]), type: type))
			default:
				newArray.append(PlistValue(value: value, type: type))
			}
		}
		
		return newArray
	}

	class func formatPlistKeyForDisplay(_ plistKey: PlistKey) -> String {
		switch plistKey.type {
		case .bool:
			return "\(plistKey.key): \(formatKeyValue(plistKey)) (Boolean)"
		case .int:
			return "\(plistKey.key): \(formatKeyValue(plistKey)) (Integer)"
		case .string:
			return "\(plistKey.key): \(formatKeyValue(plistKey)) (String)"
		case .array:
			return "\(plistKey.key): \(formatKeyValue(plistKey)) (Array)"
		case .dict:
			return "\(plistKey.key): \(formatKeyValue(plistKey)) (Dictionary)"
		case .data:
			return "\(plistKey.key): \(formatKeyValue(plistKey)) (Data)"
		case .date:
			return "\(plistKey.key): \(formatKeyValue(plistKey)) (Date)"
		case .unknown:
			return "The data for key \(plistKey.key) is of an unknown type (Error ID 686)."
		}
	}
	
	class func formatArrayValue(_ plistArray: PlistValue) -> String {
		switch plistArray.type {
		case .bool:
			return "\(formatBool(plistArray.value as! Bool))"
		case .int:
			return formatInt(plistArray.value as! Int)
		case .string:
			return formatString(plistArray.value as! String)
		case .array:
			return formatArray(plistArray.value as! [PlistValue])
		case .dict:
			return formatDict(plistArray.value as! [PlistKey])
		case .data:
			return formatData(plistArray.value as! Data)
		case .date:
			return formatDate(plistArray.value as! Date)
		case .unknown:
			return "The data is of an unknown type (Error ID 686)."
		}
	}
	
	class func formatKeyValue(_ plistKey: PlistKey) -> String {
		switch plistKey.type {
		case .bool:
			return "\(formatBool(plistKey.value as! Bool))"
		case .int:
			return formatInt(plistKey.value as! Int)
		case .string:
			return formatString(plistKey.value as! String)
		case .array:
			return formatArray(plistKey.value as! [PlistValue])
		case .dict:
			return formatDict(plistKey.value as! [PlistKey])
		case .data:
			return formatData(plistKey.value as! Data)
		case .date:
			return formatDate(plistKey.value as! Date)
		case .unknown:
			return "The data is of an unknown type (Error ID 686)."
		}
	}
	
	class func formatBool(_ bool: Bool) -> String {
		return bool ? "True" : "False"
	}
	
	class func formatInt(_ int: Int) -> String {
		return "\(int)"
	}
	
	class func formatString(_ string: String) -> String {
		return string
	}//i know int and string formatters are redundant, but it makes my life easier
	
	class func formatArray(_ array: [PlistValue]) -> String {
		var string: String = "["
		for item in array {
			string += "\(formatArrayValue(item)), "
		}
		return String(string[..<string.index(string.endIndex, offsetBy: -2)]) + "]"
	}
	
	class func formatDict(_ dict: [PlistKey]) -> String {
		var string: String = "{"
		for item in dict {
			string += formatKeyValue(item)
		}
		return String(string/*[..<string.index(string.endIndex, offsetBy: -2)]*/) + "} "
	}
	
	class func formatData(_ data: Data) -> String {
		return String(data: data, encoding: .utf8) ?? "The data could not be read (Error ID 1284)"
	} //the error numbers are just IEEE standards.
	
	class func formatDate(_ date: Date) -> String {
		let formatter = DateFormatter()
		let format = UserDefaults.settings.string(forKey: "dateFormat")
		if format == nil {
			formatter.dateFormat = "yyyy-MM-dd’T’HH:mm:ssZ"
		} else {
			formatter.dateFormat = format
		}
		return formatter.string(from: date)
	}


	class func formatAnyVarForDisplay(_ value: Any) -> String {
		switch value {
		case is Bool:
			return formatBool(value as! Bool)
		case is Int:
			return formatInt(value as! Int)
		case is String:
			return formatString(value as! String)
		case is [Any]:
			return formatArray(swiftArrayToPlistValueArray(value as! [Any]))
		case is [String: Any]:
			return formatDict(swiftDictToPlistKeyArray(value as! [String: Any]))
		case is Data:
			return formatData(value as! Data)
		case is Date:
			return formatDate(value as! Date)
		default:
			return "The value could not be read (Error ID 488)"
		}
	}
	
	class func getPlistKeyTypeFromAnyVar(_ value: Any) -> PlistKeyType {
		switch value {
		case is Bool:
			return .bool
		case is Int:
			return .int
		case is String:
			return .string
		case is [Any]:
			return .array
		case is [String: Any]:
			return .dict
		case is Data:
			return .data
		case is Date:
			return .date
		default:
			return .unknown
		}
	}
	
	class func plistKeyTypeToString(_ type: PlistKeyType) -> String {
		switch type {
		case .bool:
			return "Boolean"
		case .int:
			return "Integer"
		case .string:
			return "String"
		case .array:
			return "Array"
		case .dict:
			return "Dictionary"
		case .data:
			return "Data"
		case .date:
			return "Date"
		case .unknown:
			return "The data is of an unknown type (Error ID 686)."
		}
	}
}
