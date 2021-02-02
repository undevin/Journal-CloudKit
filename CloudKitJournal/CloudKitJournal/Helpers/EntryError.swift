//
//  EntryError.swift
//  CloudKitJournal
//
//  Created by Devin Flora on 2/1/21.
//  Copyright © 2021 Zebadiah Watson. All rights reserved.
//

import Foundation

enum EntryError: LocalizedError {
    case ckError(Error)
    case unableToUnwrap
}//End of Enum
