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

import ArgumentParser
import Foundation
import Logging

@available(macOS 10.15, *)
extension dyndns_update {

    struct Service: AsyncParsableCommand {

        // MARK: - Static Properties

        static let configuration: CommandConfiguration = {
            CommandConfiguration(
                abstract: "Start as a service and frequently update dynamic DNS records."
            )
        }()
        
        
        @OptionGroup
        private var parent: dyndns_update


        // MARK: - Methods

        mutating func run() async throws {
            try await runService()
        }
        
        
        private func runService() async throws {
            var addresses: (ipv4: String, ipv6: String)? = nil
            var lastAddressUpdate: Date? = nil
            var lastForcedUpdate: Date? = nil
            let checkAddressChangeInterval = await dyndns_update.globals.configuration.checkAddressChangeInterval!
            let forceUpdateInterval = await dyndns_update.globals.configuration.forceUpdateInterval!
            
            while true {
                await dyndns_update.globals.logger.info("Checking public IP address...")
                
                let addr = try await resolvePublicIP(dyndns_update.globals.configuration)
                var doUpdate = false
                let now = Date()
                
                await dyndns_update.globals.logger.info("IP address: \(addr)")
                
                doUpdate = ((addresses == nil || addresses! != (addr.ipv4, addr.ipv6))
                    && (lastAddressUpdate == nil || (now.timeIntervalSince1970 - lastAddressUpdate!.timeIntervalSince1970) > checkAddressChangeInterval))
                    || (lastForcedUpdate == nil || (now.timeIntervalSince1970 - lastForcedUpdate!.timeIntervalSince1970) > forceUpdateInterval)
                
                if doUpdate {
                    await dyndns_update.globals.logger.info("New public IP address: \(addr.ipv4), \(addr.ipv6)")
                    
                    do {
                        try await updateServices(dyndns_update.globals.configuration, addr, dyndns_update.globals.logger)
                        addresses = (addr.ipv4, addr.ipv6)
                        lastAddressUpdate = now
                        lastForcedUpdate = now
                    } catch {
                        await dyndns_update.globals.logger.error("Failed to update services: \(error)")
                    }
                } else {
                    await dyndns_update.globals.logger.info("No update required.")
                }
                
                await dyndns_update.globals.logger.info("Waiting for \(checkAddressChangeInterval) seconds...")
                try await Task.sleep(nanoseconds: UInt64(dyndns_update.globals.configuration.checkAddressChangeInterval! * 1_000_000_000))
            }
        }
    }

}
