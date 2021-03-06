//
//  Repository.swift
//  GitHub
//
//  Created by Mathias Quintero on 9/2/17.
//

import Sweeft

struct Indirect<T: Codable> {
    
    private final class Wrapper {
        let value: T
        init(_ value: T) {
            self.value = value
        }
    }
    
    private let wrapper: Wrapper
    
    init(_ value: T) {
        wrapper = Wrapper(value)
    }
    
    var value: T {
        return wrapper.value
    }
}

extension Indirect: Codable {
    
    init(from decoder: Decoder) throws {
        self.init(try .init(from: decoder))
    }
    
    func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
    
}

public struct Repository: APIObjectWithDetail {
    
    public struct Basic: APIBasic {
        public let id: Int
        public let name: String
        public let fullName: String
        public let description: String?
        
        public let owner: Owner
        
        public let isPrivate: Bool
        public let isFork: Bool
        
        public enum CodingKeys: String, CodingKey {
            case id
            case name
            case fullName = "full_name"
            case description
            case owner
            case isPrivate = "private"
            case isFork = "fork"
        }
    }
    
    public struct Detail: Codable {
        public let homepage: String?
        public let language: String?
        
        public let defaultBranch: String?
        
        private let parent: Indirect<Repository>?
        
        public var forkedFrom: Repository? {
            return parent?.value
        }
        
        public let size: Int?
        public let forksCount: Int
        public let starsCount: Int
        public let watchersCount: Int
        public let openIssuesCount: Int
        
        public let hasIssues: Bool
        public let hasWiki: Bool
        public let hasPages: Bool
        public let hasDownloads: Bool
        
        public let created: Date
        public let updated: Date
        public let pushed: Date
        
        public enum CodingKeys: String, CodingKey {
            case homepage
            case language
            
            case defaultBranch = "default_branch"
            
            case parent
            
            case size
            case forksCount = "forks_count"
            case starsCount = "stargazers_count"
            case watchersCount = "watchers_count"
            case openIssuesCount = "open_issues_count"
            
            case hasIssues = "has_issues"
            case hasWiki = "has_wiki"
            case hasPages = "has_pages"
            case hasDownloads = "has_downloads"
            
            
            case created = "created_at"
            case updated = "updated_at"
            case pushed = "pushed_at"
        }
    }
    
    public let basic: Basic
    public let detail: Detail?
    
    public init(basic: Basic, detail: Detail?) {
        self.basic = basic
        self.detail = detail
    }
    
}

extension Repository {
    
    public struct Clone: Codable {
        let http: URL
        let ssh: URL
    }
    
    public enum Permission: String, Codable {
        
        static var all: [Permission] = [.admin, .push, .pull]
        
        case admin
        case push
        case pull
    }
    
}

extension Repository: GitHubObject {
    
    public enum Endpoint: String, APIEndpoint {
        case collaborators
        case branches
        case commits
        case languages
        case labels
        case issues
        case milestones
        case comments = "issues/comments"
        case commentsOnIssue = "issues/{id}/comments"
    }
    
    public typealias API = GitHub
    public typealias Identifier = Int
    
    public static var endpoint: GitHub.Endpoint {
        return .repos
    }
    
}

extension APIObject where Value == Repository {
    
    public func collaborators() -> Response<[APIObject<User>]> {
        return doRequest(to: .collaborators)
    }
    
    public func branches() -> Response<[Branch]> {
        return doDecodableRequest(to: .branches)
    }
    
    public func languages() -> Response<[String : Int]> {
        return doDecodableRequest(to: .languages)
    }
    
    public func issues() -> Response<[Issue]> {
        return doDecodableRequest(to: .issues)
    }
    
    public func comments() -> Response<[Issue.Comment]> {
        return doDecodableRequest(to: .comments)
    }
    
    public func comments(on issue: Issue) -> Response<[Issue.Comment]> {
        return doDecodableRequest(to: .commentsOnIssue, arguments: ["id" : issue.number])
    }
    
    public func labels() -> Response<[Issue.Label]> {
        return doDecodableRequest(to: .labels)
    }
    
    public func milestones() -> Response<[Issue.Milestone]> {
        return doDecodableRequest(to: .milestones)
    }
    
}
