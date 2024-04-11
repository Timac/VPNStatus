import SwiftUI

public struct ACCheckForUpdateView: View {

	let currentVersion: String
	let newVersion: String
	let releaseNotes: String

	public var body: some View {
		HStack(alignment: .top) {
			Image("VPNStatus")
				.resizable()
				.aspectRatio(contentMode: .fit)
				.frame(width: 64)

			VStack {
				VStack(alignment: .leading) {
					Text("A new version of VPNStatus is available!")
						.bold()
						.padding(.bottom)
					Text("VPNStatus \(newVersion) is now available, you have \(currentVersion).")
						.padding(.bottom)

					VStack {
						ScrollView {
							Text(LocalizedStringKey(releaseNotes))
								.frame(maxWidth: .infinity, alignment: .leading)
						}
						.padding()

						Spacer()
					}
					.frame(height: 230)
					.background(Color(NSColor.windowBackgroundColor))
					.border(Color.black, width: 1)

					HStack {
						Button("Skip This Version") {
							UserDefaults.standard.setValue(newVersion, forKey: "SkipVersion")
							NSApplication.shared.keyWindow?.close()
						}

						Spacer()

						Button("Remind Me Later") {
							NSApplication.shared.keyWindow?.close()
						}

						Button("Install Update") {
							if let url = URL(string: "https://github.com/Timac/VPNStatus/releases") {
								NSWorkspace.shared.open(url)
							}
							NSApplication.shared.keyWindow?.close()
						}
						.keyboardShortcut(.defaultAction)
					}
				}
			}
		}
		.padding()
	}
}

#Preview {
	ACCheckForUpdateView(currentVersion: "1.0", newVersion: "2.0", releaseNotes: "Changes")
}
