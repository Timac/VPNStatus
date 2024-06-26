//
//  UpdateManager.swift
//  VPNStatus
//
//  Created by Alexandre Colucci on 09.04.2024.
//  Copyright © 2024 Timac. All rights reserved.
//

import Foundation
import Cocoa

@objc public final class UpdateManager: NSObject {
	@objc public static let shared = UpdateManager()

	let gitHubURL = URL(string: "https://api.github.com/repos/Timac/VPNStatus/releases")
	let currentRelease: GitHubRelease

	override private init() {
		var version = "1.0"
		if let appShortVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
			version = appShortVersion
		}
		
		currentRelease = GitHubRelease(tag_name: version, prerelease: false, draft: false, body: nil)
	}

	@objc public func checkForUpdate(showUpToDateAlert: Bool) {
		let skipVersion = checkForUpdateSkipVersion()
		checkForUpdate(skippedVersion: skipVersion) { currentVersion, newVersion, releaseNotes in
			if let currentVersion = currentVersion, !currentVersion.isEmpty,
			   let newVersion = newVersion, !newVersion.isEmpty {
				let checkForUpdateWindowController = ACCheckForUpdateViewFactory.makeWindow(currentVersion: currentVersion, newVersion: newVersion, releaseNotes: releaseNotes ?? "")
				checkForUpdateWindowController.showWindow(self)
			} else {
				if showUpToDateAlert {
					let alert = NSAlert()
					alert.messageText = "You’re up to date!"
					alert.informativeText = "You are already using the latest version of VPNStatus."
					alert.addButton(withTitle: "OK")
					alert.runModal()
				}
			}
		}
	}

	private func checkForUpdate(skippedVersion: String?, completion: @escaping (String?, String?, String?) -> Void) {
		guard let gitHubURL = gitHubURL else {
			DispatchQueue.main.async {
				completion(nil, nil, nil)
			}
			return
		}

		let requestURL = URLRequest(url: gitHubURL)
		URLSession.shared.dataTask(with: requestURL) { (data, response, error) in
			if let error = error {
				debugPrint("\(requestURL) returned: \(error)")
			} else if let data = data {
				var lastRelease: GitHubRelease?
				let jsonDecoder = JSONDecoder()
				if let releases = try? jsonDecoder.decode([GitHubRelease].self, from: data) {
					let sortedReleases = GitHubRelease.sortReleases(releases).reversed()
					for sortedRelease in sortedReleases {
						// Ignore draft
						if sortedRelease.draft || sortedRelease.prerelease {
							continue
						}

						lastRelease = sortedRelease
						break
					}
				}

				if let lastRelease = lastRelease {
					if self.currentRelease < lastRelease {
						debugPrint("A new version is available")

						if let skippedVersion = skippedVersion {
							let skippedRelease = GitHubRelease(tag_name: skippedVersion, prerelease: false, draft: false, body: nil)
							if lastRelease <= skippedRelease {
								debugPrint("Skip the new version")
								DispatchQueue.main.async {
									completion(nil, nil, nil)
								}

								return
							}
						}

						DispatchQueue.main.async {
							completion(self.currentRelease.tag_name, lastRelease.tag_name, lastRelease.body)
						}
						return
					} else {
						// Already up-to-date
						DispatchQueue.main.async {
							completion(nil, nil, nil)
						}
						return
					}
				}
			} else {
				debugPrint("GitHub returned an empty data")
				DispatchQueue.main.async {
					completion(nil, nil, nil)
					return
				}
			}
		}.resume()
	}

	// MARK: - Preferences

	static let skipVersionPrefKey: String = "SkipVersion"

	public func setCheckForUpdateSkipVersion(version: String?) {
		UserDefaults.standard.setValue(version, forKey: UpdateManager.skipVersionPrefKey)
	}

	public func checkForUpdateSkipVersion() -> String? {
		return UserDefaults.standard.string(forKey: UpdateManager.skipVersionPrefKey)
	}
}
