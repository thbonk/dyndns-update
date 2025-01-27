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

func withExponentialBackoff<T>(maxRetries: Int = 5, baseDelay: TimeInterval = 1.0, operation: () async throws -> T) async throws -> T {
    var attempts = 0

    while true {
        do {
            return try await operation()
        } catch {
            attempts += 1

            guard
                attempts < maxRetries
            else {
               throw error
            }

            let delay = baseDelay * pow(2.0, Double(attempts - 1))
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
    }
}
