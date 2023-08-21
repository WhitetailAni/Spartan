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
}

enum PlistKeyType {
	case bool
	case int
	case string
	case array
	case dict
	case data
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
				default:
					return .data
				}
			}()
			if type == .dict {
				array.append(PlistKey(key: key, value: swiftDictToPlistKeyArray(value as! [String: Any]), type: type))
			} else {
				array.append(PlistKey(key: key, value: value, type: type))
			}
		}
		
		return array
	}
	
	class func plistKeyArrayToSwiftDict(_ array: [PlistKey]) -> [String: Any] {
		var dict: [String: Any] = [:]
		for i in 0..<array.count {
			dict.updateValue(array[i].value, forKey: array[i].key)
		}
		return dict
	}

	class func formatPlistKey(_ plistKey: PlistKey) -> String {
		switch plistKey.type {
		case .bool:
			return "\(plistKey.key): \(formatValue(plistKey)) (Boolean)"
		case .int:
			return "\(plistKey.key): \(formatValue(plistKey)) (Integer)"
		case .string:
			return "\(plistKey.key): \(formatValue(plistKey)) (String)"
		case .array:
			return "\(plistKey.key): \(formatValue(plistKey)) (Array)"
		case .dict:
			return "\(plistKey.key): \(formatValue(plistKey)) (Dictionary)"
		case .data:
			return "\(plistKey.key): \(formatValue(plistKey)) (Data)"
		}
	}
	
	class func formatValue(_ plistKey: PlistKey) -> String {
		switch plistKey.type {
		case .bool:
			return "\(PlistFormatter.formatBool(plistKey.value as! Bool))"
		case .int:
			return PlistFormatter.formatInt(plistKey.value as! Int)
		case .string:
			return PlistFormatter.formatString(plistKey.value as! String)
		case .array:
			return PlistFormatter.formatArray(plistKey.value as! [Any])
		case .dict:
			return PlistFormatter.formatDict(plistKey.value as! [String: Any])
		case .data:
			return PlistFormatter.formatData(plistKey.value as! Data)
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
	}//i know int and string formatters are redundant, but it makes
	
	class func formatArray(_ array: [Any]) -> String {
		var string: String = "["
		for item in array {
			string += "\(item), "
		}
		return String(string[..<string.index(string.endIndex, offsetBy: -2)]) + "]"
	}
	
	class func formatDict(_ dict: [String: Any]) -> String {
		var string: String = "{"
		for i in 0..<dict.count {
			let keypair = dict.keyPairAtIndex(i)
			string += "\(keypair.key): \(keypair.value), "
		}
		return String(string[..<string.index(string.endIndex, offsetBy: -2)]) + "}"
	}
	
	class func formatData(_ data: Data) -> String {
		return String(data: data, encoding: .utf8) ?? "The data could not be read (Error ID 1284)"
	} //the error numbers are just IEEE standards.


	class func formatAnyVarForDisplay(_ value: Any) -> String {
		switch value {
		case is Bool:
			return formatBool(value as! Bool)
		case is Int:
			return formatInt(value as! Int)
		case is String:
			return formatString(value as! String)
		case is [Any]:
			return formatArray(value as! [Any])
		case is [String: Any]:
			return formatDict(value as! [String: Any])
		case is Data:
			return formatData(value as! Data)
		default:
			return "The value could not be read (Error ID 488)"
		}
	}
}

extension Dictionary {
	func keyPairAtIndex(_ i: Int) -> (key: Key, value: Value) {
		return self[index(startIndex, offsetBy: i)]
	}
}
