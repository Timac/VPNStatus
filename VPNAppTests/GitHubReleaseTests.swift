import XCTest

final class GitHubReleaseTests: XCTestCase {

    func testGitHubReleaseComparison() throws {
		let release_1_0 = GitHubRelease(tag_name: "1.0", prerelease: false, draft: false, body: nil)
		let release_1_1 = GitHubRelease(tag_name: "1.1", prerelease: false, draft: false, body: nil)
		let release_1_2 = GitHubRelease(tag_name: "1.2", prerelease: false, draft: false, body: nil)
		let release_1_10 = GitHubRelease(tag_name: "1.10", prerelease: false, draft: false, body: nil)
		let release_1_0_0 = GitHubRelease(tag_name: "1.0.0", prerelease: false, draft: false, body: nil)
		let release_1_0_1 = GitHubRelease(tag_name: "1.0.1", prerelease: false, draft: false, body: nil)
		let release_1_1_1 = GitHubRelease(tag_name: "1.1.1", prerelease: false, draft: false, body: nil)
		let release_1_10_1 = GitHubRelease(tag_name: "1.10.1", prerelease: false, draft: false, body: nil)
		let release_2_0 = GitHubRelease(tag_name: "2.0", prerelease: false, draft: false, body: nil)
		let release_3_0 = GitHubRelease(tag_name: "3.0", prerelease: false, draft: false, body: nil)


		XCTAssertTrue(release_1_0 < release_1_1)
		XCTAssertTrue(release_1_1 < release_1_2)
		XCTAssertTrue(release_1_2 < release_1_10)
		XCTAssertTrue(release_1_1 < release_1_10)
		XCTAssertTrue(release_1_0 < release_1_10)

		XCTAssertTrue(release_1_0_0 == release_1_0)
		XCTAssertTrue(release_1_0_0 == release_1_0_0)
		XCTAssertTrue(release_1_0_0 < release_1_1)
		XCTAssertTrue(release_1_0_0 < release_1_2)
		XCTAssertTrue(release_1_0_0 < release_1_0_1)
		XCTAssertTrue(release_1_0_0 < release_1_1_1)
		XCTAssertTrue(release_1_0_0 < release_1_10_1)
		XCTAssertTrue(release_1_0_0 < release_2_0)
		XCTAssertTrue(release_1_0_0 < release_3_0)

		XCTAssertTrue(release_1_0_1 < release_1_1)
		XCTAssertTrue(release_1_0_1 < release_1_2)
		XCTAssertTrue(release_1_0_1 == release_1_0_1)
		XCTAssertTrue(release_1_0_1 < release_1_1_1)
		XCTAssertTrue(release_1_0_1 < release_1_10_1)
		XCTAssertTrue(release_1_0_1 < release_2_0)
		XCTAssertTrue(release_1_0_1 < release_3_0)

		XCTAssertTrue(release_1_10_1 > release_1_1)
		XCTAssertTrue(release_1_10_1 > release_1_2)
		XCTAssertTrue(release_1_10_1 == release_1_10_1)
		XCTAssertTrue(release_1_10_1 > release_1_1_1)
		XCTAssertTrue(release_1_10_1 == release_1_10_1)
		XCTAssertTrue(release_1_10_1 < release_2_0)
		XCTAssertTrue(release_1_10_1 < release_3_0)

		XCTAssertTrue(release_2_0 > release_1_0)
		XCTAssertTrue(release_2_0 > release_1_1)
		XCTAssertTrue(release_2_0 > release_1_2)
		XCTAssertTrue(release_2_0 > release_1_10)
		XCTAssertTrue(release_2_0 > release_1_0_0)
		XCTAssertTrue(release_2_0 > release_1_0_1)
		XCTAssertTrue(release_2_0 > release_1_1_1)
		XCTAssertTrue(release_2_0 > release_1_10_1)
		XCTAssertTrue(release_2_0 == release_2_0)
		XCTAssertTrue(release_2_0 < release_3_0)
	}

	func testGitHubReleasePrereleaseDraft() throws {
		let release_1_0 = GitHubRelease(tag_name: "1.0", prerelease: false, draft: false, body: nil)
		let release_1_1 = GitHubRelease(tag_name: "1.1", prerelease: true, draft: false, body: nil)
		let release_1_2 = GitHubRelease(tag_name: "1.2", prerelease: true, draft: false, body: nil)

		XCTAssertTrue(release_1_0 < release_1_1)
		XCTAssertTrue(release_1_1 < release_1_2)
	}
}
