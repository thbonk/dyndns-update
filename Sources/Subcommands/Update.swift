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


        // MARK: - Arguments, Flags and Options

        @Option(
            name: [.long, .short],
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
            logger.info("Starting update.")

            logger.info("Loading configuration from \(self.config).")
            let config = try Configuration.load(from: config)
            let addresses = try await resolvePublicIP(config)
            
            logger.info("Resolved IP addresses: \(addresses)")
            
            try await updateServices(config, addresses, logger)
        }
    }

}
