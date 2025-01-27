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
import Logging

fileprivate actor Counter {
    private var value: Int = 0
    
    init(value: Int) {
        self.value = value
    }
    
    @discardableResult
    func increment() -> Int {
        value += 1
        return value
    }
    
    @discardableResult
    func decrement() -> Int {
        value -= 1
        return value
    }
    
    func getValue() -> Int {
        value
    }
}

func updateServices(_ config: Configuration, _ addresses: (ipv4: String, ipv6: String), _ logger: Logger) async throws {
    let maxRetries = config.exponentialBackoff.maxRetries
    let baseDelay = config.exponentialBackoff.baseDelay
    let counter = Counter(value: config.services.count)
    
    for service: Service in config.services {
        Task {
            var url = service.url
            let username = service.username
            let passwd = service.passwd
            let domain = service.domain
            
            url = url
                .replacingOccurrences(of: "{username}", with: username)
                .replacingOccurrences(of: "{passwd}", with: passwd)
                .replacingOccurrences(of: "{domain}", with: domain)
                .replacingOccurrences(of: "{ipaddr}", with: addresses.ipv4)
                .replacingOccurrences(of: "{ip6addr}", with: addresses.ipv6)
            
            do {
                try await withExponentialBackoff(maxRetries: maxRetries, baseDelay: baseDelay) {
                    let (data, resp) = try await URLSession.shared.data(from: URL(string: url)!)
                    let response = resp as! HTTPURLResponse
                    
                    logger.debug("Service \(service.name) returned status code \(response.statusCode) and response: \(String(data: data, encoding: .utf8)!)")
                    
                    if response.statusCode != 200 {
                        throw NSError(domain: "dyndns-update", code: response.statusCode, userInfo: ["response": String(data: data, encoding: .utf8)!])
                    }
                }
            } catch {
                logger.error("Failed to update service \(service.name): \(error)")
            }
            
            await counter.decrement()
        }
    }
    
    while await counter.getValue() > 0 {}
}
