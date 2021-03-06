//
//  CoreDataProvider.swift
//  Schedule
//
//  Created by HsinYuLi on 2018/10/4.
//  Copyright © 2018年 laalee. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CoreDataProvider {

    static let shared = CoreDataProvider()

    var category: CategoryMO!

    var task: TaskMO!

    let persistentContainer: NSPersistentContainer!

    init(container: NSPersistentContainer) {

        self.persistentContainer = container

        self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }

    convenience init() {

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {

            fatalError("Can not get shared app delegate")
        }

        self.init(container: appDelegate.persistentContainer)
    }

    lazy var backgroundContext: NSManagedObjectContext = {

        return self.persistentContainer.newBackgroundContext()
    }()

    var fetchResultController: NSFetchedResultsController<CategoryMO>!

    var taskFetchResultController: NSFetchedResultsController<TaskMO>!

    func addCategory(category: Category) {

        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {

            self.category = CategoryMO(context: appDelegate.persistentContainer.viewContext)

            self.category.id = Int64(category.id)

            self.category.title = category.title

            self.category.color = category.color

            appDelegate.saveContext()
        }
    }

    func addTask(task: Task) {

        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {

            self.task = TaskMO(context: appDelegate.persistentContainer.viewContext)

            self.task.title = task.title

            self.task.date = task.date as NSObject

            self.task.time = task.time

            self.task.note = task.note

            self.task.category = task.category

            if let startDate = task.startDate as NSObject? {

                self.task.startDate = startDate
            }

            if let endDate = task.endDate as NSObject? {

                self.task.endDate = endDate
            }

            if let consecutiveStatus = task.consecutiveStatus {

                self.task.consecutiveStatus = Int64(consecutiveStatus)
            }

            if let consecutiveId = task.consecutiveId {

                self.task.consecutiveId = Int64(consecutiveId)
            }

            if let consecutiveDay = task.consecutiveDay {

                self.task.consecutiveDay = Int64(consecutiveDay)
            }

            appDelegate.saveContext()
        }
    }

    func updateCategory(categoryMO: CategoryMO, category: Category) {

        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {

            categoryMO.title = category.title

            categoryMO.color = category.color

            appDelegate.saveContext()
        }
    }

    func deleteCategory(categoryMO: CategoryMO) {

        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {

            let context = appDelegate.persistentContainer.viewContext

            context.delete(categoryMO)

            appDelegate.saveContext()
        }
    }

    func deleteTask(taskMO: TaskMO) {

        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {

            let context = appDelegate.persistentContainer.viewContext

            context.delete(taskMO)

            appDelegate.saveContext()
        }
    }

    func fetchTask(byCategory category: CategoryMO, date: Date) -> [TaskMO]? {

        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)

        let fetchRequest: NSFetchRequest<TaskMO> = TaskMO.fetchRequest()

        fetchRequest.sortDescriptors = [sortDescriptor]

        let categoryKeyPredicate = NSPredicate(format: "category == %@", category)

        let dateKeyPredicate = NSPredicate(format: "date == %@", date as CVarArg)

        let andPredicate = NSCompoundPredicate(type: .and, subpredicates: [categoryKeyPredicate, dateKeyPredicate])

        fetchRequest.predicate = andPredicate

        guard let appDelegate = (UIApplication.shared.delegate as? AppDelegate) else { return nil }

        let context = appDelegate.persistentContainer.viewContext

        taskFetchResultController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil, cacheName: nil)

        taskFetchResultController.delegate = self as? NSFetchedResultsControllerDelegate

        do {
            try taskFetchResultController.performFetch()

            if let fetchedObjects = taskFetchResultController.fetchedObjects {

                return fetchedObjects
            }
        } catch {

            print("FetchTask Fail!!")
            
            return nil
        }

        return nil
    }

    func fetchTask(byDate date: Date?, orCategory category: CategoryMO?) -> [TaskMO]? {

        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)

        let fetchRequest: NSFetchRequest<TaskMO> = TaskMO.fetchRequest()

        fetchRequest.sortDescriptors = [sortDescriptor]

        if let date = date {

            fetchRequest.predicate = NSPredicate(format: "date == %@", date as CVarArg)

        } else if let category = category {

            fetchRequest.predicate = NSPredicate(format: "category == %@", category)
        }

        guard let appDelegate = (UIApplication.shared.delegate as? AppDelegate) else { return nil }

        let context = appDelegate.persistentContainer.viewContext

        taskFetchResultController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil, cacheName: nil)

        taskFetchResultController.delegate = self as? NSFetchedResultsControllerDelegate

        do {
            try taskFetchResultController.performFetch()

            if let fetchedObjects = taskFetchResultController.fetchedObjects {

                return fetchedObjects
            }
        } catch {

            print("FetchTask Fail!!")

            return nil
        }

        return nil
    }

    func deleteTask(byConsecutiveId consecutiveId: Int) {

        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)

        let fetchRequest: NSFetchRequest<TaskMO> = TaskMO.fetchRequest()

        fetchRequest.sortDescriptors = [sortDescriptor]

        fetchRequest.predicate = NSPredicate(format: "consecutiveId == %i", consecutiveId)

        guard let appDelegate = (UIApplication.shared.delegate as? AppDelegate) else { return }

        let context = appDelegate.persistentContainer.viewContext

        taskFetchResultController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil, cacheName: nil)

        taskFetchResultController.delegate = self as? NSFetchedResultsControllerDelegate

        do {
            try taskFetchResultController.performFetch()

            if let fetchedObjects = taskFetchResultController.fetchedObjects {

                for object in fetchedObjects {

                    context.delete(object)
                }

                appDelegate.saveContext()
            }
        } catch {

            print("FetchTask Fail!!")
        }
    }

    func fetchAllCategory() -> [CategoryMO]? {

        let fetchRequest: NSFetchRequest<CategoryMO> = CategoryMO.fetchRequest()

        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)

        fetchRequest.sortDescriptors = [sortDescriptor]

        guard let appDelegate = (UIApplication.shared.delegate as? AppDelegate) else { return nil }

        let context = appDelegate.persistentContainer.viewContext

        fetchResultController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil, cacheName: nil)

        fetchResultController.delegate = self as? NSFetchedResultsControllerDelegate

        do {
            try fetchResultController.performFetch()

            if let fetchedObjects = fetchResultController.fetchedObjects {

                return fetchedObjects
            }
        } catch {

            return nil
        }

        return nil
    }

    func numberOfCategory() -> Int {

        let fetchRequest: NSFetchRequest<CategoryMO> = CategoryMO.fetchRequest()

        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)

        fetchRequest.sortDescriptors = [sortDescriptor]

        guard let appDelegate = (UIApplication.shared.delegate as? AppDelegate) else { return 0 }

        let context = appDelegate.persistentContainer.viewContext

        fetchResultController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil, cacheName: nil)

        fetchResultController.delegate = self as? NSFetchedResultsControllerDelegate

        do {
            try fetchResultController.performFetch()

            if let fetchedObjects = fetchResultController.fetchedObjects {

                return fetchedObjects.count
            }
        } catch {

            return 0
        }

        return 0
    }

}
