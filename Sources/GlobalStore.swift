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

actor GlobalStore {
    
    // MARK: - Public Properties
    
    public private(set) var configuration: Configuration!
    public private(set) var verbose: Bool!
    public private(set) var logger: Logger!
    
    
    // MARK: - Initialization
    
    public init() {
        // Empty by design
    }
    
    public func initialize(configFile: String, verbose: Bool) throws {
        self.verbose = verbose
        self.logger = Logger(label: "dyndns-update")
        self.logger.logLevel = self.verbose ? .debug : .info

        logger.info("Loading configuration from \(configFile).")
        self.configuration = try Configuration.load(from: configFile)
    }
}
