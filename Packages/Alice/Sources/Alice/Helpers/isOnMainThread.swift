//
//  File.swift
//  
//
//  Created by Alex Modroño Vara on 14/7/21.
//

import Foundation

/**
Allows us to determine whether the function is running on the main thread or on a background thread, and log a brief description of the code on the console.

- Parameter codeDescription: A brief description of what the code does so that it is easy to log the app.
*/
public func isOnMainThread(named codeDescription:String) -> Bool {
    if Thread.isMainThread {
        print("\(codeDescription) ON MAIN THREAD")
        return true
    } else {
        print("\(codeDescription) ON BACKGROUND THREAD")
        return false
    }
}
