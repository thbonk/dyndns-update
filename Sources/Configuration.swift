/*
   Copyright 2025 Thomas Bonk <thomas@meandmymac.de>

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License
 */

import Foundation
import Yams

struct Configuration: Codable {
    
    // MARK: - Properties
    let ipResolver: IpResolver
    var exponentialBackoff = ExponentialBackoff(maxRetries: 5, baseDelay: 1.0)
    var checkAddressChangeInterval: TimeInterval = 5 * 60.0 // 5 minutes
    var forceUpdateInterval: TimeInterval        = 24 * 60 * 60.0 // 24 hours
    let services: [Service]
    
    
    // MARK: - Methods

    static func load(from file: String) throws -> Configuration {
        let data = try Data(contentsOf: URL(fileURLWithPath: file))
        let decoder = YAMLDecoder(encoding: .utf8)
        let config = try decoder.decode(Configuration.self, from: data)

        return config
    }
}

struct IpResolver: Codable {
    let ipv4: String
    let ipv6: String?
}

struct ExponentialBackoff: Codable {
    var maxRetries: Int = 5
    var baseDelay: TimeInterval = 1.0
}

struct Service: Codable {
    let name: String
    let url: String
    let username: String
    let passwd: String
    let domain: String
}
