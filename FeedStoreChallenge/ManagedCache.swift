//
//  ManagedCache.swift
//  FeedStoreChallenge
//
//  Created by Shinzan Takata on 2021/04/29.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import CoreData

@objc(ManagedCache)
class ManagedCache: NSManagedObject {
	@NSManaged var timestamp: Date
	@NSManaged var feed: NSOrderedSet
}
