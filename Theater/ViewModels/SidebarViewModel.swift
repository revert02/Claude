import Foundation
import Observation

@Observable
class SidebarViewModel {
    var enabledPlatforms: Set<StreamingPlatform> = Set(StreamingPlatform.allCases)
    var selectedRegion = "US"

    static let shared = SidebarViewModel()

    let availableRegions = [
        ("US", "United States"),
        ("GB", "United Kingdom"),
        ("CA", "Canada"),
        ("AU", "Australia"),
        ("DE", "Germany"),
        ("FR", "France"),
        ("JP", "Japan"),
        ("IN", "India"),
    ]

    func togglePlatform(_ platform: StreamingPlatform) {
        if enabledPlatforms.contains(platform) {
            enabledPlatforms.remove(platform)
        } else {
            enabledPlatforms.insert(platform)
        }
    }

    func isPlatformEnabled(_ platform: StreamingPlatform) -> Bool {
        enabledPlatforms.contains(platform)
    }
}
