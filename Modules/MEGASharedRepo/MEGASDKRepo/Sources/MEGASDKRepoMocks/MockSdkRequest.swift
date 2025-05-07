// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGASdk

/// Use this class to simulate request responses from the SDK in repository unit tests
public class MockSdkRequest: MEGARequest {
    private let _handle: MEGAHandle
    private let _set: MEGASet?
    private let _text: String?
    private let _parentHandle: UInt64
    private let _elementsInSet: [MEGASetElement]
    private let _number: Int64
    private let _link: String?
    private let _flag: Bool
    private let _publicNode: MEGANode?
    private let _backupInfoList: [MEGABackupInfo]
    private let _stringDict: [String: String]
    private let _file: String?
    private let _accountDetails: MEGAAccountDetails?
    private let _numDetails: Int
    private let _notifications: MEGANotificationList?
    private let _recentActionsBuckets: [MEGARecentActionBucket]?
    private let _name: String?
    private let _megaStringList: [String]
    private let _megaVpnRegion: [MEGAVPNRegion]
    private let _megaNetworkConnectivityTestResults: MEGANetworkConnectivityTestResults?
    private let _pricing: MEGAPricing?

    public init(
        handle: MEGAHandle = MEGAHandle(),
        set: MEGASet? = nil,
        text: String? = nil,
        parentHandle: MEGAHandle = ~UInt64.zero,
        elementInSet: [MEGASetElement] = [],
        number: Int64 = 0,
        link: String? = nil,
        flag: Bool = false,
        publicNode: MEGANode? = nil,
        backupInfoList: [MEGABackupInfo] = [],
        stringDict: [String: String] = [:],
        file: String? = nil,
        accountDetails: MEGAAccountDetails? = nil,
        numDetails: Int = 0,
        notifications: MEGANotificationList? = nil,
        recentActionsBuckets: [MEGARecentActionBucket] = [],
        name: String? = nil,
        megaStringList: [String] = [],
        megaVpnRegion: [MEGAVPNRegion] = [],
        megaNetworkConnectivityTestResults: MEGANetworkConnectivityTestResults? = nil,
        pricing: MEGAPricing? = nil
    ) {
        _handle = handle
        _set = set
        _text = text
        _parentHandle = parentHandle
        _elementsInSet = elementInSet
        _number = number
        _link = link
        _flag = flag
        _publicNode = publicNode
        _backupInfoList = backupInfoList
        _stringDict = stringDict
        _file = file
        _accountDetails = accountDetails
        _numDetails = numDetails
        _notifications = notifications
        _recentActionsBuckets = recentActionsBuckets
        _name = name
        _megaStringList = megaStringList
        _megaVpnRegion = megaVpnRegion
        _megaNetworkConnectivityTestResults = megaNetworkConnectivityTestResults
        _pricing = pricing
        super.init()
    }

    public override var nodeHandle: MEGAHandle {
        _handle
    }

    public override var set: MEGASet? {
        _set
    }

    public override var text: String? {
        _text
    }

    public override var parentHandle: UInt64 {
        _parentHandle
    }

    public override var elementsInSet: [MEGASetElement] {
        _elementsInSet
    }

    public override var number: Int64 {
        _number
    }

    public override var link: String? {
        _link
    }

    public override var flag: Bool {
        _flag
    }

    public override var publicNode: MEGANode? {
        _publicNode
    }

    public override var backupInfoList: [MEGABackupInfo] {
        _backupInfoList
    }

    public override var megaStringDictionary: [String: String] {
        _stringDict
    }

    public override var file: String? {
        _file
    }

    public override var megaAccountDetails: MEGAAccountDetails? {
        _accountDetails
    }

    public override var numDetails: Int {
        _numDetails
    }

    public override var megaNotifications: MEGANotificationList? {
        _notifications
    }

    public override var recentActionsBuckets: [MEGARecentActionBucket]? { _recentActionsBuckets
    }

    public override var name: String? {
        _name
    }

    public override var megaStringList: MEGAStringList? {
        MockStringList(list: _megaStringList)
    }

    public override var megaVpnRegions: [MEGAVPNRegion] {
        _megaVpnRegion
    }

    public override var megaNetworkConnectivityTestResults: MEGANetworkConnectivityTestResults? {
        _megaNetworkConnectivityTestResults
    }

    public override var pricing: MEGAPricing? {
        _pricing
    }
}
