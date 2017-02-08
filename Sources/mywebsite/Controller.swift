import Foundation
import Kitura
import KituraNet
import SwiftyJSON
import LoggerAPI
import Configuration

import CloudFoundryConfig

import SwiftMetrics
import SwiftMetricsDash
import SwiftMetricsBluemix

import CouchDB

public class Controller {

    public let router = Router()

    public let manager: ConfigurationManager

    // Set up cloudant
    internal let database: Database


    public var port: Int {
        return manager.applicationPort
    }

    public init() throws {

        manager = ConfigurationManager()
        try manager.load(.environmentVariables)

        // Configuring cloudant
        let cloudantService = try manager.getCloudantService(name: "mywebsiteCloudantService")
        let dbClient = CouchDBClient(service: cloudantService)
        self.database = dbClient.database("databaseName")

      let sm = try SwiftMetrics()
      let _ = try SwiftMetricsDash(swiftMetricsInstance : sm, endpoint: router)
      let _ = AutoScalar(swiftMetricsInstance: sm)

        router.all("/", middleware: StaticFileServer())
        router.all("/*", middleware: BodyParser())
    }
}
