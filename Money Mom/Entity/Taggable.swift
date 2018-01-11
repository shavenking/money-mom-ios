import Foundation
import CoreData

protocol Taggable {
    var tags: Set<Tag> { get set }
}
