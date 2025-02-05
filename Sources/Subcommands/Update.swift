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

    struct Update: AsyncParsableCommand {

        // MARK: - Static Properties

        static let configuration: CommandConfiguration = {
            CommandConfiguration(
                abstract: "Update dynamic DNS records once."
            )
        }()


        // MARK: - Methods

        mutating func run() async throws {
            await dyndns_update.globals.logger.info("Starting update.")
            
            let config = await dyndns_update.globals.configuration!

            await dyndns_update.globals.logger.info("Loading configuration from \(config).")
            let addresses = try await resolvePublicIP(config)
            
            await dyndns_update.globals.logger.info("Resolved IP addresses: \(addresses)")
            
            try await updateServices(config, addresses, dyndns_update.globals.logger)
        }
    }

}
