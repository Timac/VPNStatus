//
//  UpdateManager.swift
//  VPNStatus
//
//  Created by Alexandre Colucci on 09.04.2024.
//  Copyright © 2024 Timac. All rights reserved.
//

import Foundation

@objc public final class UpdateManager: NSObject {
	@objc public static let shared = UpdateManager()

	let gitHubURL = URL(string: "https://api.github.com/repos/Timac/VPNStatus/releases")
	let currentRelease: GitHubRelease

	override private init() {
		let appShortVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
		if let appShortVersion = appShortVersion {
			currentRelease = GitHubRelease(name: appShortVersion, prerelease: false, draft: false)
		} else {
			currentRelease = GitHubRelease(name: "1.0", prerelease: false, draft: false)
		}
	}

	@objc public func checkForUpdate(skippedVersion: String?, completion: @escaping (String?, String?) -> Void) {
		guard let gitHubURL = gitHubURL else {
			DispatchQueue.main.async {
				completion(nil, nil)
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
							let skippedRelease = GitHubRelease(name: skippedVersion, prerelease: false, draft: false)
							if lastRelease <= skippedRelease {
								debugPrint("Skip the new version")
								DispatchQueue.main.async {
									completion(nil, nil)
								}

								return
							}
						}

						DispatchQueue.main.async {
							completion(self.currentRelease.name, lastRelease.name)
						}
						return
					} else {
						// Already up-to-date
						DispatchQueue.main.async {
							completion(nil, nil)
						}
						return
					}
				}
			} else {
				debugPrint("GitHub returned an empty data")
				DispatchQueue.main.async {
					completion(nil, nil)
					return
				}
			}
		}.resume()
	}
}
