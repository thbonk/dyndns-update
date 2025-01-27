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


        // MARK: - Arguments, Flags and Options

        @Option(name: [.long, .short],
                help: "Fully qualified path of the configuration file."
        )
        private var config = "/etc/dyndns-update.yaml"
        
        @Flag(
            name: [.long, .short],
            help: "Write extensive logs when verbose is set."
        )
        private var verbose = false


        // MARK: - Methods

        mutating func run() async throws {
            var logger = Logger(label: "dyndns-update")
            logger.logLevel = verbose ? .debug : .info
            logger.info("Starting service.")

            logger.info("Loading configuration from \(self.config).")
            let config = try Configuration.load(from: config)
            
            try await runService(logger, config)
        }
        
        
        private func runService(_ logger: Logger, _ config: Configuration) async throws {
            var addresses: (ipv4: String, ipv6: String)? = nil
            var lastAddressUpdate: Date? = nil
            var lastForcedUpdate: Date? = nil
            
            while true {
                logger.info("Checking public IP address...")
                
                let addr = try await resolvePublicIP(config)
                var doUpdate = false
                let now = Date()
                
                logger.info("IP address: \(addr)")
                
                doUpdate = ((addresses == nil || addresses! != (addr.ipv4, addr.ipv6))
                    && (lastAddressUpdate == nil || (now.timeIntervalSince1970 - lastAddressUpdate!.timeIntervalSince1970) > config.checkAddressChangeInterval))
                    || (lastForcedUpdate == nil || (now.timeIntervalSince1970 - lastForcedUpdate!.timeIntervalSince1970) > config.forceUpdateInterval)
                
                if doUpdate {
                    logger.info("New public IP address: \(addr.ipv4), \(addr.ipv6)")
                    
                    do {
                        try await updateServices(config, addr, logger)
                        addresses = (addr.ipv4, addr.ipv6)
                        lastAddressUpdate = now
                        lastForcedUpdate = now
                    } catch {
                        logger.error("Failed to update services: \(error)")
                    }
                } else {
                    logger.info("No update required.")
                }
                
                logger.info("Waiting for \(config.checkAddressChangeInterval) seconds...")
                try await Task.sleep(nanoseconds: UInt64(config.checkAddressChangeInterval * 1_000_000_000))
            }
        }
    }

}
