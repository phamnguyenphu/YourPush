//
//  ViewController.swift
//  YourPush
//
//  Created by Pham Nguyen Phu on 02/02/2023.
//

import Intents
import UIKit
import UserNotifications

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        checkForPermission()
        // Do any additional setup after loading the view.
    }

    @IBAction func buttonClicked(_ sender: Any) {
        dispatchNotification()
    }

    func checkForPermission() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings {
            settings in switch settings.authorizationStatus {
            case .authorized:
                self.dispatchNotification()
            case .denied:
                return
            case .notDetermined:
                notificationCenter.requestAuthorization(options: [.alert, .sound]) {
                    didAllow, _ in
                    if didAllow {
                        self.dispatchNotification()
                    }
                }
            default: return
            }
        }
    }
    
    func dispatchNotification() {
        let identifier = "mason"
        var content = UNMutableNotificationContent()
        
        content.title = "Title"
        content.subtitle = "Subtitle"
        content.body = "Text"
        content.sound = nil
        content.categoryIdentifier = "Event"
        
        var personNameComponents = PersonNameComponents()
        personNameComponents.nickname = "Sender Name"
        
        let avatar = INImage(imageData: UIImage(named: "Avatar")!.pngData()!)
        
        let senderPerson = INPerson(
            personHandle: INPersonHandle(value: "1233211234", type: .unknown),
            nameComponents: personNameComponents,
            displayName: "Phu Pham Nguyen",
            image: avatar,
            contactIdentifier: nil,
            customIdentifier: nil,
            isMe: false,
            suggestionType: .none
        )
        
        let mePerson = INPerson(
            personHandle: INPersonHandle(value: "1233211234", type: .unknown),
            nameComponents: nil,
            displayName: nil,
            image: nil,
            contactIdentifier: nil,
            customIdentifier: nil,
            isMe: true,
            suggestionType: .none
        )
        
        let intent = INSendMessageIntent(
            recipients: [mePerson],
            outgoingMessageType: .outgoingMessageText,
            content: "Text",
            speakableGroupName: INSpeakableString(spokenPhrase: "Sender Name"),
            conversationIdentifier: "sampleConversationIdentifier",
            serviceName: nil,
            sender: senderPerson,
            attachments: nil
        )
        
        intent.setImage(avatar, forParameterNamed: \.sender)
        
        let interaction = INInteraction(intent: intent, response: nil)
        interaction.direction = .incoming
        
        interaction.donate(completion: nil)
        
        do {
            content = try content.updating(from: intent) as! UNMutableNotificationContent
        } catch {
            // Handle errors
        }
        
        // Show 5 seconds from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        // Request from identifier
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // actions
        let close = UNNotificationAction(identifier: "close", title: "Close", options: .destructive)
        let reply = UNNotificationAction(identifier: "reply", title: "Reply", options: .foreground)
        let category = UNNotificationCategory(identifier: "Event", actions: [close, reply], intentIdentifiers: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        // Add notification request
        UNUserNotificationCenter.current().add(request)
    }
}
