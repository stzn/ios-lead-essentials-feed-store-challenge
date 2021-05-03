//
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import CoreData

final class CoreDataFeedStore: FeedStore {
	private static let modelName = "FeedStore"
	private static let model = NSManagedObjectModel(name: modelName, in: Bundle(for: CoreDataFeedStore.self))

	private let container: NSPersistentContainer
	private let context: NSManagedObjectContext

	struct ModelNotFound: Error {
		let modelName: String
	}

	init(storeURL: URL) throws {
		guard let model = CoreDataFeedStore.model else {
			throw ModelNotFound(modelName: CoreDataFeedStore.modelName)
		}

		container = try NSPersistentContainer.load(
			name: CoreDataFeedStore.modelName,
			model: model,
			url: storeURL
		)
		context = container.newBackgroundContext()
	}

	func retrieve(completion: @escaping RetrievalCompletion) {
		let context = self.context
		context.perform {
			do {
				guard let cache = try ManagedCache.find(in: context) else {
					completion(.empty)
					return
				}
				let feed = cache.feed.compactMap { ($0 as? ManagedFeedImage)?.local }
				completion(.found(feed: feed, timestamp: cache.timestamp))
			} catch {
				completion(.failure(error))
			}
		}
	}

	func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		let context = self.context
		context.perform {
			do {
				let newCache = try ManagedCache.newUniqueInstance(in: context)
				newCache.feed = ManagedFeedImage.images(from: feed, in: context)
				newCache.timestamp = timestamp

				try context.save()
				completion(nil)
			} catch {
				context.rollback()
				completion(error)
			}
		}
	}

	func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		let context = self.context
		context.perform {
			do {
				if let cache = try ManagedCache.find(in: context) {
					context.delete(cache)
					try context.save()
				}
				completion(nil)
			} catch {
				context.rollback()
				completion(error)
			}
		}
	}
}
