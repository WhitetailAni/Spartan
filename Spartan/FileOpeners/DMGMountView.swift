//
//  DMGMountView.swift
//  Spartan
//
//  Created by RealKGB on 10/4/23.
//

import SwiftUI
import DiskImagesWrapper

struct DMGMountView: View {
	@State var filePath: String
	@State var fileName: String
	@Binding var directory: String
	@Binding var isPresented: Bool

	@State var dmgDevPath = ""
	@State var dmgFilesAreAvailableAt: String = ""
	@State var dmgHandle: DeviceHandle?
	@State var errorOccurred = false
	@State var errorDesc = ""
	
	@State var filesystem = 0
	@State var mountAsReadOnly = true
	@State var mountedSuccessfully = false
	@State var goToMountedFiles = false

    var body: some View {
		/*VStack {
			Text(UserDefaults.settings.bool(forKey: "descriptiveTitles") ? filePath + fileName : fileName)
				.font(Font.system(size: 40))
				.multilineTextAlignment(.center)
			
			TextField(LocalizedString("DMG_MOUNTPATH"), text: $dmgFilesAreAvailableAt)
			Text(NSLocalizedString("DMG_MOUNTPATH_CREATE", comment: "Wow! That blew my mind!"))
				.if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
					view.scaledFont(name: "BotW Sheikah Regular", size: 25)
				}
				.font(.system(size: 25))
			
			HStack {
				/*Picker(NSLocalizedString("DMG_FSTYPE", comment: "Phantom R"), selection: $filesystem) {
					Text(LocalizedString("HFS")).tag(0)
					Text(LocalizedString("APFS")).tag(1)
				}*/
				Checkbox(value: $mountAsReadOnly, label: LocalizedString("DMG_READONLY")) { }
			}
			
			Button(action: {
				var isDir: ObjCBool = false
				if Spartan.fileManager.fileExists(atPath: dmgFilesAreAvailableAt, isDirectory: &isDir) {
					do {
						try Spartan.fileManager.createDirectory(atPath: dmgFilesAreAvailableAt, withIntermediateDirectories: true, attributes: nil)
					} catch {
						errorDesc = LocalizedString("DMG_COULDNTCREATE")
						errorOccurred = true
					}
				}
				if !isDir.boolValue {
					errorDesc = LocalizedString("DMG_NOTDIR")
					errorOccurred = true
				}
				do {
					try dmgHandle = DiskImages.shared.attachDiskImage(with: AttachParameters(itemURL: URL(fileURLWithPath: filePath + fileName)))
					let devPath = dmgHandle?.deviceHandlePath.relativePath
					guard devPath != nil else {
						throw LocalizedString("DMG_FAILTOATTACH")
					}
					print(mount(devPath!, dmgFilesAreAvailableAt, 0, nil))
				} catch {
					errorOccurred = true
					errorDesc = error.localizedDescription
				}
			}) {
				Text(LocalizedString("CONFIRM"))
			}
			.alert(isPresented: $errorOccurred) {
				Alert(
					title: Text(LocalizedString("ERROR")),
					message: Text(errorDesc),
					dismissButton: .default(Text(LocalizedString("DISMISS")))
				)
			}
			.alert(isPresented: $mountedSuccessfully) {
				Alert(
					title: Text(LocalizedString("DMG_SUCCESS")),
					message: Text(LocalizedString("DMG_GOTOFILES")),
					primaryButton: .default(Text(LocalizedString("YES")), action: {
						directory = dmgFilesAreAvailableAt
						isPresented = false
					}),
					secondaryButton: .default(Text(LocalizedString("NO")), action: {
						isPresented = false
					})
				)
			}
		}*/
		Text("Support is coming soon.")
    }
}
