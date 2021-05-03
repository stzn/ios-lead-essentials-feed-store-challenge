//
//  ManagedFeedImage.swift
//  FeedStoreChallenge
//
//  Created by Shinzan Takata on 2021/04/29.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import CoreData

@objc(ManagedFeedImage)
final class ManagedFeedImage: NSManagedObject {
	@NSManaged var id: UUID
	@NSManaged var imageDescription: String?
	@NSManaged var location: String?
	@NSManaged var url: URL
	@NSManaged var cache: ManagedCache
}

extension ManagedFeedImage {
	var local: LocalFeedImage {
		LocalFeedImage(id: id, description: imageDescription, location: location, url: url)
	}

	static func images(from feed: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
		return NSOrderedSet(array: feed.map { feed in
			let managed = ManagedFeedImage(context: context)
			managed.id = feed.id
			managed.imageDescription = feed.description
			managed.location = feed.location
			managed.url = feed.url
			return managed
		})
	}
}
