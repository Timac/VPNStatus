
import Cocoa
import SwiftUI

class ACCheckForUpdateWindowController<RootView: View>: NSWindowController {
	convenience init(rootView: RootView) {
		let hostingController = NSHostingController(rootView: rootView)
		let window = NSWindow(contentViewController: hostingController)
		window.setContentSize(NSSize(width: 620, height: 370))
		window.title = "Software Update"
		window.styleMask.remove(.resizable)
		self.init(window: window)
	}
}

@objc class ACCheckForUpdateViewFactory: NSView {
	@objc class func makeWindow(currentVersion: String, newVersion: String, releaseNotes: String) -> NSWindowController {
		ACCheckForUpdateWindowController(rootView: ACCheckForUpdateView(currentVersion: currentVersion, newVersion: newVersion, releaseNotes: releaseNotes))
	}
}

