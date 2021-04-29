//
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import CoreData

public final class CoreDataFeedStore: FeedStore {
	private static let modelName = "FeedStore"
	private static let model = NSManagedObjectModel(name: modelName, in: Bundle(for: CoreDataFeedStore.self))

	private let container: NSPersistentContainer
	private let context: NSManagedObjectContext

	struct ModelNotFound: Error {
		let modelName: String
	}

	public init(storeURL: URL) throws {
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

	public func retrieve(completion: @escaping RetrievalCompletion) {
		let context = self.context
		context.perform {
			do {
				let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
				request.returnsObjectsAsFaults = false
				guard let cache = try context.fetch(request).first else {
					completion(.empty)
					return
				}
				let feed = cache.feed.compactMap { feed -> LocalFeedImage? in
					guard let managed = feed as? ManagedFeedImage else {
						return nil
					}
					return LocalFeedImage(id: managed.id,
					                      description: managed.imageDescription,
					                      location: managed.location,
					                      url: managed.url)
				}
				completion(.found(feed: feed, timestamp: cache.timestamp))
			} catch {}
		}
	}

	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		let context = self.context
		context.perform {
			let newCache = ManagedCache(context: context)
			newCache.feed = NSOrderedSet(array: feed.map { feed in
				let managed = ManagedFeedImage(context: context)
				managed.id = feed.id
				managed.imageDescription = feed.description
				managed.location = feed.location
				managed.url = feed.url
				return managed
			})
			newCache.timestamp = timestamp

			do {
				try context.save()
				completion(nil)
			} catch {
				completion(error)
			}
		}
	}

	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		fatalError("Must be implemented")
	}
}
