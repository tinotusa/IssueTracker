//
//  Project+Extensions.swift
//  IssueTracker
//
//  Created by Tino on 29/12/2022.
//

import CoreData

extension Project {
    convenience init(name: String, startDate: Date, context: NSManagedObjectContext) {
        self.init(context: context)
        self.name = name.filterWhitespace()
        self.startDate = startDate
    }
    
    public override func awakeFromInsert() {
        self.id = UUID()
        self.dateCreated = .now
    }
    
    /// The latest issue added to the project.
    var latestIssue: Issue? {
        let issues = self.issues?.allObjects as? [Issue] ?? []
        let sortedIssues = issues.sorted { $0.wrappedDateCreated > $1.wrappedDateCreated }
        return sortedIssues.last
    }
    
    /// Creates an example Project.
    ///
    /// Creates an example Project used in previews.
    ///
    /// - Parameter context: The context for the project
    /// - Returns: A new project in the given context.
    static func example(context: NSManagedObjectContext) -> Project {
        let project = Project(name: "Example project", startDate: .now, context: context)
        let tags: [Tag] = ["Todo", "UI", "WIP", "Bug", "Fix", "Test", "Feat", "Upgrade", "Update"].map { todoText in
            Tag.init(name: todoText, context: context)
        }
        
        /// Returns a random selection of tags.
        /// - Returns: A set of Tags
        func randomTags() -> Set<Tag> {
            // how many tags to pick
            let amount = Int.random(in: 0 ..< tags.count)
            // randomise the tags indices
            let indices = tags.enumerated().map { $0.offset }.shuffled()
            var selectedTags = Set<Tag>()
            // pick the first n(amount) tags
            for index in indices where index < amount {
                selectedTags.insert(tags[index])
            }
            return selectedTags
        }
        
        project.issues = NSSet(set: Set<Issue>([
            .init(name: "Lorem ipsum dolor", issueDescription: "this is a random description of the issue.", priority: .low, tags: randomTags(), context: context),
            .init(name: "Sit amet, consectetur", issueDescription: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam ac magna ex. Etiam nec dolor id ex imperdiet ornare.", priority: .low, tags: randomTags(), context: context),
            .init(name: "Vestibulum at tellus commodo", issueDescription: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.", priority: .low, tags: randomTags(), context: context),
            .init(name: "Imperdiet ornare", issueDescription: "Etiam nec dolor id ex imperdiet ornare. Proin consectetur est eget suscipit sodales. Cras tempor pharetra pulvinar.", priority: .low, tags: randomTags(), context: context),
            .init(name: "Adipiscing elit", issueDescription: "Dolor id ex imperdiet ornare. Proin consectetur est eget suscipit sodales. Cras tempor pharetra pulvinar.", priority: .low, tags: randomTags(), context: context),
        ]))
        
        do {
            try context.save()
        } catch {
            print("failed to save example project. \(error)")
        }
        return project
    }
    
    
    /// Filters the given name by removing non alphanumerics and non spaces.
    /// - Parameter name: The name to filter.
    /// - Returns: The filtered name or the name unchanged.
    static func filterName(_ name: String) -> String {
        var invalidCharacters = CharacterSet.alphanumerics
        invalidCharacters.formUnion(.whitespaces)
        invalidCharacters.invert()
        let filteredValue = name.components(separatedBy: invalidCharacters).joined(separator: "")
        return filteredValue
    }
}

// MARK: - Property wrappers
extension Project {
    var wrappedName: String {
        get {
            self.name ?? "N/A"
        }
        set {
            self.name = newValue
        }
    }
    
    public var wrappedId: UUID {
        get {
            self.id ?? UUID()
        }
        set {
            self.id = newValue
        }
    }
    
    var wrappedDateCreated: Date {
        get {
            self.dateCreated ?? .now
        }
        set {
            self.dateCreated = newValue
        }
    }
    
    var wrappedStartDate: Date {
        get {
            self.startDate ?? .now
        }
        set {
            self.startDate = newValue
        }
    }
}
