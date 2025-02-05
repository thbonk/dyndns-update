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
import Logging

@available(macOS 10.15, *)
@main
struct dyndns_update: AsyncParsableCommand {

    // MARK: - Static Properties

    public static let configuration: CommandConfiguration = {
        CommandConfiguration(
            commandName: "dyndns-update",
            abstract: "Update dynamic DNS records.",
            subcommands: [Service.self, Update.self]
        )
    }()
    
    public static let globals = GlobalStore()
    
    
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
    
    mutating func validate() throws {
        let cfg = self.config
        let verb = self.verbose
        
        Task {
            try await Self.globals.initialize(configFile: cfg, verbose: verb)
        }
    }
}
