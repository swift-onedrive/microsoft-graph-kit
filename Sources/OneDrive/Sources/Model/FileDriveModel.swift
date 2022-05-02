//
//  File.swift
//  
//
//  Created by Finer  Vine on 2021/1/4.
//
// https://docs.microsoft.com/zh-cn/graph/api/resources/drive?view=graph-rest-1.0
/*
 "createdBy": { "@odata.type": "microsoft.graph.identitySet" },
 "createdDateTime": "string (timestamp)",
 "description": "string",
 "driveType": "personal | business | documentLibrary",
 "following": [{"@odata.type": "microsoft.graph.driveItem"}],
 "items": [ { "@odata.type": "microsoft.graph.driveItem" } ],
 "lastModifiedBy": { "@odata.type": "microsoft.graph.identitySet" },
 "lastModifiedDateTime": "string (timestamp)",
 "name": "string",
 "owner": { "@odata.type": "microsoft.graph.identitySet" },
 "quota": { "@odata.type": "microsoft.graph.quota" },
 "root": { "@odata.type": "microsoft.graph.driveItem" },
 "sharepointIds": { "@odata.type": "microsoft.graph.sharepointIds" },
 "special": [ { "@odata.type": "microsoft.graph.driveItem" }],
 "system": { "@odata.type": "microsoft.graph.systemFacet" },
 "webUrl": "url"
 */
import Foundation
import MicrosoftGraphCore

// MARK: - FileDriveModel
public final class FileDriveModel: BaseItemModel {
    
    public let driveType: String?
//    public let following: [CreatedBy]
//    public let items: [CreatedBy]
//    public let owner, quota, root, sharepointIDS: CreatedBy
//    public let special: [CreatedBy]
//    public let system: CreatedBy

    enum CodingKeys: String, CodingKey {
//        case id, createdBy, createdDateTime
        case driveType
//             ,following
//             ,
//             items,
//             lastModifiedBy, lastModifiedDateTime, name, owner, quota, root
//        case sharepointIDS = "sharepointIds"
//        case special, system
//        case webURL = "webUrl"
    }
    
    // MARK: - CreatedBy
//    public
//    struct CreatedBy: Codable {
//        let odataType: String
//
//        enum CodingKeys: String, CodingKey {
//            case odataType = "@odata.type"
//        }
//    }

    required init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)
        driveType = try container.decodeIfPresent(String.self, forKey: .driveType)
        try super.init(from: decoder)
    }
}
