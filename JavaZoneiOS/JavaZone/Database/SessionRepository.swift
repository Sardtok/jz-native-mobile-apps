import Foundation
import RealmSwift

class SessionRepository {
    var speakerRepository: SpeakerRepository?
    
    init(speakerRepository: SpeakerRepository?) {
        self.speakerRepository = speakerRepository
    }

    func add(item: Session) {
        let realm = try! Realm()
        try! realm.write {
            realm.create(Session.self, value: item)
        }
    }
    
    func addAsync(items: [Session]) {
        DispatchQueue.global().async {
            // Get new realm and table since we are in a new thread
            let realm = try! Realm()
            realm.beginWrite()
            for item in items {
                self.speakerRepository!.addSpeakerAsync(speakers: item.speakers, session: item)
                realm.create(Session.self, value: item)
            }
            try! realm.commitWrite()
        }
    }
    
    func delete(item: Session) {
        let realm = try! Realm()
        realm.beginWrite()
        realm.delete(item)
        try! realm.commitWrite()
    }
    
    func deleteAll() {
        DispatchQueue.global().async {
            autoreleasepool {
                let otherRealm = try! Realm()
                let allSessionObjects = otherRealm.objects(Session.self)
                try! otherRealm.write {

                    otherRealm.delete(allSessionObjects)
                }
                
            }
        }
    }
    
    func getAll() -> [Session]? {
        let realm = try! Realm()
        let result = realm.objects(Session.self).sorted( by: [SortDescriptor(keyPath: "startTime", ascending: true), SortDescriptor(keyPath: "endTime", ascending: true)])
        let returnResult = Array(result)
        
        for session in returnResult {
            session.speakers = speakerRepository!.getSpeakersForSession(session: session)
        }
        
        return returnResult
    }
    
    func getAllSessionsAsync() -> [Session]? {
        _ = try! Realm()
        let results: [Session]? = nil
        DispatchQueue.global().async {
            let otherRealm = try! Realm()
            let results = otherRealm.objects(Session.self)
            print("Number of result \(results.count)")
        }
        
        return Array(results!)
    }
}
