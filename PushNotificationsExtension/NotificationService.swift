//
//  NotificationService.swift
//  PushNotificationsExtension
//
//  Created by Denis Denisov on 08/07/2026.
//

import UserNotifications

final class NotificationService: UNNotificationServiceExtension {
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        if let userInfo = bestAttemptContent?.userInfo,
           let logUrl = userInfo["log_url"] as? String {
            sendPushStatus(url: logUrl, status: "delivered")
        }
        guard let bestAttemptContent = bestAttemptContent,
              let bannerUrlString = request.content.userInfo["banner-url"] as? String,
              let bannerUrl = URL(string: bannerUrlString) else {
            contentHandler(request.content)
            return
        }
        downloadImage(from: bannerUrl) { attachment in
            if let attachment = attachment {
                bestAttemptContent.attachments = [attachment]
                bestAttemptContent.categoryIdentifier = "banner_notification"
            }
            contentHandler(bestAttemptContent)
        }
    }
    
    private func sendPushStatus(url: String, status: String){
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.httpBody = ("status=\(status)").data(using: .utf8)
        URLSession.shared.dataTask(with: request).resume()
    }
    
    private func downloadImage(from url: URL, completion: @escaping (UNNotificationAttachment?) -> Void) {
        let task = URLSession.shared.downloadTask(with: url) { location, _, error in
            guard let location = location, error == nil else {
                completion(nil)
                return
            }
            let fileManager = FileManager.default
            let cachePath = URL(fileURLWithPath: NSTemporaryDirectory())
            let filename = url.lastPathComponent
            let destination = cachePath.appendingPathComponent(filename)
            try? fileManager.moveItem(at: location, to: destination)
            do {
                let attachment = try UNNotificationAttachment(
                    identifier: "banner_image",
                    url: destination,
                    options: nil
                )
                completion(attachment)
            } catch {
                print("Failed to create attachment: \(error)")
                completion(nil)
            }
        }
        task.resume()
    }
}

