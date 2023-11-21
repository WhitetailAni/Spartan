//
//  SettingsView.swift
//  Spartan
//
//  Created by RealKGB on 4/6/23.
//

import SwiftUI

struct SettingsView: View {
    @State private var showView: [Bool] = [Bool](repeating: false, count: 3)
    @State private var descriptiveTitlesPre = UserDefaults.settings.bool(forKey: "descriptiveTitles")
    @State private var descriptiveTimestampsPre = UserDefaults.settings.bool(forKey: "verboseTimestamps")
    @State private var autoCompletePre = UserDefaults.settings.bool(forKey: "autoComplete")
    @State private var logWindowFontSizePre = UserDefaults.settings.integer(forKey: "logWindowFontSize")
    @State private var sheikahFontApplyPre = UserDefaults.settings.bool(forKey: "sheikahFontApply")
    @State private var dateFormatPre: String = UserDefaults.settings.string(forKey: "dateFormat") ?? ""

    var body: some View {
		ScrollView {
			Text(NSLocalizedString("SETTINGS", comment: "But choose carefully because you'll stay in the job you pick for the rest of your life."))
				.if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
					view.scaledFont(name: "BotW Sheikah Regular", size: 60)
				}
				.font(.system(size: 60))
			
			StepperTV(value: $logWindowFontSizePre, isHorizontal: true) {
				UserDefaults.settings.set(logWindowFontSizePre, forKey: "logWindowFontSize")
				UserDefaults.settings.synchronize()
			}
			.padding(5)
			Text(NSLocalizedString("SETTINGS_LOGFONTSIZE", comment: "The same job the rest of your life?"))
				.if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
					view.scaledFont(name: "BotW Sheikah Regular", size: 25)
				}
				.font(.system(size: 25))
				
			Text(" ")
				
			descriptiveThings
			Text(" ")
			autoCompleteFileExtensions
			Text(" ")
			sheikahFont
			Text(" ")
			
			GeometryReader { geometry in
				HStack {
					Spacer()
					TextField("SETTINGS_DATEFORMAT", text: $dateFormatPre)
						.frame(maxWidth: geometry.size.width * 0.8)
					Spacer()
				}
			}
			Text(" ")
				.font(.system(size: 15))
			Text(NSLocalizedString("SETTINGS_DATEFORMATDESC1", comment: "Halls Of Science 4"))
				.if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
					view.scaledFont(name: "BotW Sheikah Regular", size: 25)
				}
				.font(.system(size: 25))
			Text(NSLocalizedString("SETTINGS_DATEFORMATDESC2", comment: "Halls Of Science... 5?"))
				.if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
					view.scaledFont(name: "BotW Sheikah Regular", size: 25)
				}
				.font(.system(size: 25))
			Text(" ")
            
            Button(action: {
                cacheFolder("/")
            }) {
                Text(localizedString: "SETTINGS_CACHEALL")
            }
            Text(NSLocalizedString("SETTINGS_CACHEALLDESC", comment: "Halls Of Science... 5?"))
                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                    view.scaledFont(name: "BotW Sheikah Regular", size: 25)
                }
                .font(.system(size: 25))
            Text(" ")
			
			Button(action: {
				showView[2] = true
			}) {
				HStack {
					Image(systemName: "pencil")
					Text(NSLocalizedString("APPICON", comment: """
					LET'S GO BABY LOVE THE [[METS]] HIT A HOME RUN BABY
					1987 *CAN* HAPPEN AGAIN
					"""))
					.if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
						view.scaledFont(name: "BotW Sheikah Regular", size: 25)
					}
				}
			}
			
			/*Button(action: {
				showView[1] = true
			}) {
				Text(LocalizedString("SETTINGS_WEBSERVERSTART"))
			}*/
			
			Button(action: { //info
				showView[0] = true
			}) {
				HStack {
					Image(systemName: "info.circle")
						.frame(width: 50, height: 50)
					Text(NSLocalizedString("CREDITS", comment: """
					"What's the difference?"
					"""))
					.if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
						view.scaledFont(name: "BotW Sheikah Regular", size: 40)
					}
				}
			}
			
			Text(" ")
				.font(.system(size: 25))
			Text("Spartan v\((Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "Don't edit") (\((Bundle.main.infoDictionary?["CFBundleVersion"] as? String) ?? "Info.plists"))")
                .foregroundColor(.secondary)
                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
					view.scaledFont(name: "BotW Sheikah Regular", size: 20)
				}
				.font(.footnote)
        }
        .sheet(isPresented: $showView[0], content: {
			CreditsView()
		})
		.sheet(isPresented: $showView[1], content: {
			WebServerView()
		})
		.sheet(isPresented: $showView[2], content: {
			IconView()
		})
    }
    
    @ViewBuilder
    var descriptiveThings: some View {
        Button(action: {
            descriptiveTitlesPre.toggle()
            UserDefaults.settings.set(descriptiveTitlesPre, forKey: "descriptiveTitles")
            UserDefaults.settings.synchronize()
        }) {
            Text(NSLocalizedString("SETTINGS_TITLES", comment: "The same job the rest of your life?"))
                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                }
            Image(systemName: descriptiveTitlesPre ? "checkmark.square" : "square")
        }
        Text(NSLocalizedString("SETTINGS_TITLES_DESC", comment: "I didn't know that."))
            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                view.scaledFont(name: "BotW Sheikah Regular", size: 25)
            }
            .font(.system(size: 25))
		
		Text(" ")
        Button(action: {
            descriptiveTimestampsPre.toggle()
            UserDefaults.settings.set(descriptiveTimestampsPre, forKey: "verboseTimestamps")
            UserDefaults.settings.synchronize()
        }) {
            Text(NSLocalizedString("SETTINGS_TIMESTAMPS", comment: "What's the difference?"))
                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                }
            Image(systemName: descriptiveTimestampsPre ? "checkmark.square" : "square")
        }
        Text(NSLocalizedString("SETTINGS_TIMESTAMPS_DESC", comment: "You'll be happy to know that bees, as a species"))
            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                view.scaledFont(name: "BotW Sheikah Regular", size: 25)
            }
            .font(.system(size: 25))
    }
    
    @ViewBuilder
    var autoCompleteFileExtensions: some View {
        Button(action: {
            autoCompletePre.toggle()
            UserDefaults.settings.set(autoCompletePre, forKey: "autoComplete")
            UserDefaults.settings.synchronize()
        }) {
            Text(NSLocalizedString("SETTINGS_AUTOCOMPLETE", comment: "haven't had one day off in 27 million years."))
                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                }
            Image(systemName: autoCompletePre ? "checkmark.square" : "square")
        }
        Text("""
        \(NSLocalizedString("SETTINGS_AUTOCOMPLETE_DESC_1", comment: "So you'll just work us to death?"))
        \(NSLocalizedString("SETTINGS_AUTOCOMPLETE_DESC_2", comment: "We'll sure try."))
        """)
            .multilineTextAlignment(.center)
            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                view.scaledFont(name: "BotW Sheikah Regular", size: 25)
            }
            .font(.system(size: 25))
        Text(NSLocalizedString("SETTINGS_AUTOCOMPLETE_WARNING", comment: "Wow! That blew my mind!"))
            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                view.scaledFont(name: "BotW Sheikah Regular", size: 25)
            }
            .font(.system(size: 25))
    }
    
    @ViewBuilder
    var sheikahFont: some View {
        Button(action: {
            sheikahFontApplyPre.toggle()
            UserDefaults.settings.set(sheikahFontApplyPre, forKey: "sheikahFontApply")
            UserDefaults.settings.synchronize()
            if(sheikahFontApplyPre) {
                buttonWidth *= 1.5
            } else {
                buttonWidth /= 1.5
            }
        }) {
            Text(NSLocalizedString("SETTINGS_SHEIKAH", comment: "YOU LOST IT WHEN YOU TRIED TO SEE TOO FAR"))
                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                }
            Image(systemName: sheikahFontApplyPre ? "checkmark.square" : "square")
        }
    }
}

struct IconView: View {
	var body: some View {
		VStack {
			Text(NSLocalizedString("APPICON_TITLE", comment: "But choose carefully because you'll stay in the job you pick for the rest of your life."))
				.if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
					view.scaledFont(name: "BotW Sheikah Regular", size: 60)
				}
				.font(.system(size: 60))
			VStack {
				HStack {
					IconButton(iconName: "Alpha", creator: "WhitetailAni")
					IconButton(iconName: "Megamind", creator: "WhitetailAni")
					IconButton(iconName: "Terabyte", creator: "WhitetailAni")
				}
				HStack {
                    IconButton(iconName: "Beta", creator: "WhitetailAni")
					IconButton(iconName: "Summit", creator: "Noel Berry? Unsure")
					IconButton(iconName: "Finda", creator: "JamesnLollify")
				}
			}
		}
	}
}

struct IconButton: View {
	@State var iconName: String
	@State var creator: String

	var body: some View {
		Button(action: {
			UIApplication.shared.setAlternateIconName(iconName) { error in
				if let error = error {
					print(error.localizedDescription)
				}
			}
		}) {
			VStack {
				Image(uiImage: UIImage(named: iconName)!)
					.resizable()
					.cornerRadius(10)
					.frame(width: 300, height: 180)
				Text(iconName)
						.if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
							view.scaledFont(name: "BotW Sheikah Regular", size: 30)
						}
				Text(creator)
					.if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
						view.scaledFont(name: "BotW Sheikah Regular", size: 25).foregroundColor(.gray)
					}
					.foregroundColor(.gray)
			}
			.frame(width: 350, height: 300)
		}
	}
}

func cacheFolder(_ directory: String) {
    let decoder = JSONDecoder()
    var decoded: [SpartanFile] = []
    var masterFiles: [SpartanFile] = []
    do {
        let contents = try FileManager.default.contentsOfDirectory(atPath: directory)
        var files: [String]
        files = contents.map { file in
            let filePath = "/" + directory + "/" + file
            var isDirectory: ObjCBool = false
            FileManager.default.fileExists(atPath: filePath, isDirectory: &isDirectory)
            return isDirectory.boolValue ? "\(file)/" : file
        }
        files.remove(at: files.firstIndex(of: metadataName!)!) //hide the metadata file from view
        for i in 0..<files.count {
            if let j = decoded.map({ $0.name }).firstIndex(of: files[i]) {
                masterFiles.append(decoded[j])
            } else {
                masterFiles.append(SpartanFile(name: files[i], fullPath: directory + files[i], isSelected: false, fileType: FileInfo.yandereDevFileType(file: directory + files[i]), isLoadingFile: false))
            }
        }
    } catch {
        print(error)
    }
    DispatchQueue.global().asyncAfter(deadline: .now() + 0.01) { //removes files that no longer exist from the cache (so the filesize doesn't grow until you run out of disk space)
        var decoded2 = decoded
        for i in 0..<decoded.count {
            if !(masterFiles.contains(decoded[i])) {
                decoded2.remove(at: i)
            }
        }
        let encoder = JSONEncoder()
        do {
            let encoded = try encoder.encode(decoded2)
            try encoded.write(to: URL(fileURLWithPath: tempPath))
        } catch {
            print("failed to update and/or save cached metadata: \(error)")
        }
        RootHelperActs.mvtemp(directory + metadataName!)
    }
}
