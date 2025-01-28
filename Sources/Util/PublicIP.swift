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
#if os(Linux)
import FoundationNetworking
#endif

func resolvePublicIP(_ config: Configuration) async throws -> (ipv4: String, ipv6: String) {
    func fetchIP(from url: String) async throws -> String? {
        let session = URLSession(configuration: .default)
        let (data, _) = try await session.data(for: URLRequest(url: URL(string: url)!))
        return String(data: data, encoding: .utf8)
    }
    
    async let ipv4Task = withExponentialBackoff(
        maxRetries: config.exponentialBackoff!.maxRetries,
        baseDelay: config.exponentialBackoff!.baseDelay) {
            
        return try await fetchIP(from: config.ipResolver!.ipv4)
    }
       
    async let ipv6Task = withExponentialBackoff(
        maxRetries: config.exponentialBackoff!.maxRetries,
        baseDelay: config.exponentialBackoff!.baseDelay) {
            
        guard
            let ipv6 = config.ipResolver?.ipv6
        else {
            return nil as String?
        }

        return try await fetchIP(from: ipv6)
    }
    
    return try await (ipv4: ipv4Task!, ipv6: ipv6Task ?? "")
}
