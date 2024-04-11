//
//  GitHubRelease.swift
//  VPNStatus
//
//  Created by Alexandre Colucci on 09.04.2024.
//  Copyright © 2024 Timac. All rights reserved.
//

import Foundation

public struct GitHubRelease: Decodable, Comparable {
	let tag_name: String // "1.0", "1.0.1", "1.2", "2.0"
	let prerelease: Bool
	let draft: Bool
	let body: String?

	public static func < (lhs: GitHubRelease, rhs: GitHubRelease) -> Bool {
		let components1 = lhs.components()
		let components2 = rhs.components()

		if components1.major != components2.major {
			return components1.major < components2.major
		} else {
			if components1.minor != components2.minor {
				return components1.minor < components2.minor
			} else {
				if components1.patch != components2.patch {
					return components1.patch < components2.patch
				} else {
					return false
				}
			}
		}
	}

	public static func == (lhs: GitHubRelease, rhs: GitHubRelease) -> Bool {
		let components1 = lhs.components()
		let components2 = rhs.components()

		return (components1.major == components2.major) &&
		(components1.minor == components2.minor) &&
		(components1.patch == components2.patch)
	}

	public func components() -> (major: Int, minor: Int, patch: Int) {
		var components = self.tag_name.split(separator: ".").compactMap { Int($0) }
		while components.count != 3 {
			components.append(0)
		}

		return (components[0], components[1], components[2])
	}

	public static func sortReleases(_ releases: [GitHubRelease]) -> [GitHubRelease] {
		return releases.sorted()
	}
}
