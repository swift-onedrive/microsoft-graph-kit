//
//  File.swift
//  
//
//  Created by Finer  Vine on 2021/1/5.
//
// https://docs.microsoft.com/zh-cn/graph/api/resources/baseitem?view=graph-rest-1.0
/*
 {
   "id": "string (identifier)",
   "createdBy": { "@odata.type": "microsoft.graph.identitySet" },
   "createdDateTime": "datetime",
   "description": "string",
   "eTag": "string",
   "lastModifiedBy": { "@odata.type": "microsoft.graph.identitySet" },
   "lastModifiedDateTime": "datetime",
   "name": "string",
   "parentReference": { "@odata.type": "microsoft.graph.itemReference" },
   "webUrl": "url"
 }
 */
import Foundation
import MicrosoftGraphCore

public class BaseItemModel: MicrosoftAzureModel {
    
    public let id: String
    public let createdBy: BaseItemCreatedBy?
    public let createdDateTime: String?
    public let baseItemDescription: String?
    public let eTag: String?
    public let lastModifiedBy: BaseItemCreatedBy?
    public let lastModifiedDateTime, name: String
    public let parentReference: ParentReference
    public let webURL: String

    enum CodingKeys: String, CodingKey {
        case id, createdBy, createdDateTime
        case baseItemDescription = "description"
        case eTag, lastModifiedBy, lastModifiedDateTime, name, parentReference
        case webURL = "webUrl"
    }
    
    public
    struct ParentReference: MicrosoftAzureModel {
        public let id: String?
        public let path: String?
        public let driveType: String?
        public let driveId: String?
    }
    // MARK: - CreatedBy
    public
    struct BaseItemCreatedBy: MicrosoftAzureModel {

        public let odataType: String?
        public let application: Application?
        enum CodingKeys: String, CodingKey {
            case odataType = "@odata.type"
            case application
        }
    }
    
    // MARK: - Application
    public
    struct Application: MicrosoftAzureModel {
        let id, displayName: String
    }
    
    init(id: String, createdBy: BaseItemCreatedBy,
         createdDateTime: String,
         description: String,
         eTag: String,
         lastModifiedBy: BaseItemCreatedBy,
         lastModifiedDateTime: String,
         name: String,
         parentReference: ParentReference,
         webUrl: String) {
        self.id = id
        self.createdBy = createdBy
        self.createdDateTime = createdDateTime
        self.baseItemDescription = description
        self.eTag = eTag
        self.lastModifiedBy = lastModifiedBy
        self.lastModifiedDateTime = lastModifiedDateTime
        self.name = name
        self.parentReference = parentReference
        self.webURL = webUrl
    }
}
