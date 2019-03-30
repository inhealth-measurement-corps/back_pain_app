//
//  Requests.swift
//  ElSuperDT
//
//  Created by Sebastian del Campo on 20/10/2015.
//  Copyright © 2015 Sebastian del Campo. All rights reserved.
//

import UIKit
import CoreData

private let _requestsInstance : Requests = { Requests() }();


class Requests:NSObject,NSURLConnectionDelegate{
    
    static let sharedInstance = Requests()
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext;
    let childObjectContext = NSManagedObjectContext.init(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
    var isSyncing = false
    var currentConnectionString:String?;
    
    var checkToken: NSURLConnection?
    var getPhoneCode: NSURLConnection?
    var registerUser: NSURLConnection?
    var getUserByToken: NSURLConnection?
    var getAllRegions: NSURLConnection?
    var getAvailableCourts: NSURLConnection?
    var updateUserInformation: NSURLConnection?
    var updateImageData: NSURLConnection?
    var updateTeamImageData: NSURLConnection?
    var getUserNamesByPhones: NSURLConnection?
    var createTeam: NSURLConnection?
    //var getTeamsByUserID: NSURLConnection?
    var getTeamByID: NSURLConnection?
    var addPlayers: NSURLConnection?
    var leaveTeam: NSURLConnection?
    var placeReservation: NSURLConnection?
    var createMatchSearch: NSURLConnection?
    var updateTeamsData: NSURLConnection?
    var challengeTeam: NSURLConnection?
    var getAllChallenges: NSURLConnection?
    var answerChallenge: NSURLConnection?
    var getTeamImage: NSURLConnection?
    var getTournaments: NSURLConnection?
    var registerForTournament: NSURLConnection?
    var codeConfirmed: NSURLConnection?
    
    let server = GlobalVars.sharedInstance().server
    var data = NSMutableData();
    
    
    private override init(){
        childObjectContext.parentContext = managedObjectContext
    }
    
   
    
    //MARK: requests
    
    func updateImageData(token:String,image:UIImage?,imageName:String, controller: String, teamID: Int = 0){
        var request = NSMutableURLRequest()
        if controller == "Users" {
            request = NSMutableURLRequest(URL: NSURL(string: "\(server)/Users/updateImageData")!)
        } else if controller == "Teams" {
            request = NSMutableURLRequest(URL: NSURL(string: "\(server)/Teams/updateTeamImageData")!)
        }
        let boundary = "UpdateImageDataBoundary";
        let contentType = "multipart/form-data; boundary=\(boundary)"
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        
        let body = NSMutableData()
        let boundaryString = "\r\n--\(boundary)\r\n"
        
        let imageContentString = "Content-Disposition: form-data; name=\"image\"; filename=\"\(imageName)\"\r\n"
        let octetString = "Content-Type: application/octet-stream\r\n\r\n"
        
        let tokenContentString = "Content-Disposition: form-data; name=\"token\"\r\n\r\n \(token)"

        let teamIDString = "Content-Disposition: form-data; name=\"team_id\"\r\n\r\n \(teamID)"

        
        if let _image = image{
            let imageData = UIImageJPEGRepresentation(_image,1)
            body.appendData(boundaryString.dataUsingEncoding(NSUTF8StringEncoding)!)
            body.appendData(imageContentString.dataUsingEncoding(NSUTF8StringEncoding)!)
            body.appendData(octetString.dataUsingEncoding(NSUTF8StringEncoding)!)
            body.appendData(NSData(data: imageData!))
            body.appendData(boundaryString.dataUsingEncoding(NSUTF8StringEncoding)!)
        }
        
        body.appendData(tokenContentString.dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData(boundaryString.dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData(teamIDString.dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData(boundaryString.dataUsingEncoding(NSUTF8StringEncoding)!)
        
        request.HTTPMethod = "POST"
        request.HTTPBody = body
        
        if controller == "Users" {
            updateImageData = NSURLConnection(request: request, delegate: self);
        } else if controller == "Teams" {
            updateTeamImageData = NSURLConnection(request: request, delegate: self)
        }
    }
    
    func sendRequest(jsonDict:NSDictionary, action:String ){
        currentConnectionString = action;
        let request = NSMutableURLRequest(URL: NSURL(string: "\(server)/\(action)")!);
        request.HTTPMethod = "POST"
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(jsonDict, options: [])
        } catch _ as NSError {
            
            request.HTTPBody = nil
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("ElSuperDT_ios", forHTTPHeaderField: "User-Agent")
        request.setValue("", forHTTPHeaderField: "Accept-Encoding")
        switch (action) {
            case "Devices/getPhoneCode":
                getPhoneCode = NSURLConnection(request: request, delegate: self)
            case "Users/registerUser":
                registerUser = NSURLConnection(request: request, delegate: self)
            case "Users/getUserByToken":
                getUserByToken = NSURLConnection(request: request, delegate: self)
            case "Regions/getAll":
                getAllRegions = NSURLConnection(request: request, delegate: self)
            case "Facilities/getAvailableCourts":
                getAvailableCourts = NSURLConnection(request: request, delegate: self)
            case "Users/updateUserInformation":
                updateUserInformation = NSURLConnection(request: request, delegate: self)
            case "Users/updateImageData":
                updateImageData = NSURLConnection(request: request, delegate: self)
            case "Teams/updateTeamImageData":
                updateTeamImageData = NSURLConnection(request: request, delegate: self)
            case "Users/getUserNamesByPhones":
                getUserNamesByPhones = NSURLConnection(request: request, delegate: self)
            case "Teams/createTeam":
                createTeam = NSURLConnection(request: request, delegate: self)
            //case "Teams/getTeamsByUserID":
                //getTeamsByUserID = NSURLConnection(request: request, delegate: self)
            case "Teams/getTeamByID":
                getTeamByID = NSURLConnection(request: request, delegate: self)
            case "Teams/addPlayers":
                addPlayers = NSURLConnection(request: request, delegate: self)
            case "Teams/leaveTeam":
                leaveTeam = NSURLConnection(request: request, delegate: self)
            case "Reservations/placeReservation":
                placeReservation = NSURLConnection(request: request, delegate: self)
            case "Matches/createMatchSearch":
                createMatchSearch = NSURLConnection(request: request, delegate: self)
            case "Teams/updateTeamsData":
                updateTeamsData = NSURLConnection(request: request, delegate: self)
            case "Challenges/challengeTeam":
                challengeTeam = NSURLConnection(request: request, delegate: self)
            case "Challenges/getAllChallenges":
                getAllChallenges = NSURLConnection(request: request, delegate: self)
            case "Challenges/answerChallenge":
                answerChallenge = NSURLConnection(request: request, delegate: self)
            case "Teams/getTeamImage":
                getTeamImage = NSURLConnection(request: request, delegate: self)
            case "Tournaments/getTournaments":
                getTournaments = NSURLConnection(request: request, delegate: self)
            case "Tournaments/registerForTournament":
                registerForTournament = NSURLConnection(request: request, delegate: self)
            case "Devices/codeConfirmed":
                codeConfirmed = NSURLConnection(request: request, delegate: self)
            default:
                break;
        }
    }
    
    func logError(error:String){
        
        let jsonDict = ["error":error,"connection":currentConnectionString!,"token":Tools.getToken()] ;
        //sendRequest(jsonDict, action: "Devices/logError");

        NSLog(error);
        
    }
    
    //MARK: NSURLConnectionDelegate
    
    
    func connection(connection: NSURLConnection!, didReceiveResponse response: NSURLResponse!) {
        data = NSMutableData()
    }
    
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
        self.data.appendData(data);
    }
    
    
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        
        
        do {
            
            let responseDict = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! NSDictionary
            
            let status = responseDict.valueForKey("status") as! String;
            
            if (status == "ok") {
                if connection == getPhoneCode {
                    getPhoneCode(responseDict)
                } else if connection == registerUser {
                    registerUser(responseDict)
                } else if connection == getUserByToken {
                    getUserByToken(responseDict)
                } else if connection == getAllRegions {
                    getAllRegions(responseDict)
                } else if connection == getAvailableCourts {
                    getAvailableCourts(responseDict)
                } else if connection == updateUserInformation {
                    updateUserInformation(responseDict)
                } else if connection == updateImageData {
                    updateImageData(responseDict)
                } else if connection == updateTeamImageData {
                    updateTeamImageData(responseDict)
                } else if connection == getUserNamesByPhones {
                    getUserNamesByPhones(responseDict)
                } else if connection == createTeam {
                    createTeam(responseDict)
                }/* else if connection == getTeamsByUserID {
                    getTeamsByUserID(responseDict)
                }*/ else if connection == getTeamByID {
                    getTeamByID(responseDict)
                } else if connection == addPlayers {
                    addPlayers(responseDict)
                } else if connection == leaveTeam {
                    leaveTeam(responseDict)
                } else if connection == placeReservation {
                    placeReservation(responseDict)
                } else if connection == createMatchSearch {
                    createMatchSearch(responseDict)
                } else if connection ==  updateTeamsData {
                    updateTeamsData(responseDict)
                } else if connection == challengeTeam {
                    challengeTeam(responseDict)
                } else if connection == getAllChallenges {
                    getAllChallenges(responseDict)
                } else if connection == answerChallenge {
                    answerChallenge(responseDict)
                } else if connection == getTeamImage {
                    getTeamImage(responseDict)
                } else if connection == getTournaments {
                    getTournaments(responseDict)
                } else if connection == registerForTournament {
                    registerForTournament(responseDict)
                } else if connection == codeConfirmed {
                    codeConfirmed(responseDict)
                }
            }
                
            else if (status == "error") {
                if connection == checkToken {
                    sendErrorNotification(responseDict, name: "tokenCheckFailed")
                } else if connection == getPhoneCode {
                    sendErrorNotification(responseDict, name: "getPhoneCodeFailed")
                } else if connection == registerUser {
                    sendErrorNotification(responseDict, name: "registerUserFailed")
                } else if connection == getUserByToken {
                    sendErrorNotification(responseDict, name: "getUserByTokenFailed")
                } else if connection == getAllRegions {
                    sendErrorNotification(responseDict, name: "getAllRegionsFailed")
                } else if connection == getAvailableCourts {
                    sendErrorNotification(responseDict, name: "getAvailableCourtsFailed")
                } else if connection == updateUserInformation {
                    sendErrorNotification(responseDict, name: "udpateUserInformationFailed")
                } else if connection == updateImageData {
                    sendErrorNotification(responseDict, name: "updateImageDataFailed")
                } else if connection == updateTeamImageData {
                    sendErrorNotification(responseDict, name: "updateTeamImageDataFailed")
                } else if connection == getUserNamesByPhones {
                    sendErrorNotification(responseDict, name: "getUserNamesByPhonesFailed")
                } else if connection == createTeam {
                    sendErrorNotification(responseDict, name: "createTeamFailed")
                } /*else if connection == getTeamsByUserID {
                    sendErrorNotification(responseDict, name: "getTeamsByUserIDFailed")
                } */else if connection == getTeamByID {
                    sendErrorNotification(responseDict, name: "getTeamByIDFailed")
                } else if connection == addPlayers {
                    sendErrorNotification(responseDict, name: "addPlayersFailed")
                } else if connection == leaveTeam {
                    sendErrorNotification(responseDict, name: "leaveTeamFailed")
                } else if connection == placeReservation {
                    sendErrorNotification(responseDict, name: "placeReservation")
                } else if connection == createMatchSearch {
                    sendErrorNotification(responseDict, name: "createMatchSearch")
                } else if connection == updateTeamsData {
                    sendErrorNotification(responseDict, name: "updateTeamsData")
                } else if connection == challengeTeam {
                    sendErrorNotification(responseDict, name: "challengeTeam")
                } else if connection == getAllChallenges {
                    sendErrorNotification(responseDict, name: "getAllChallenges")
                } else if connection == answerChallenge {
                    sendErrorNotification(responseDict, name: "answerChallenge")
                } else if connection == getTeamImage {
                    sendErrorNotification(responseDict, name: "getTeamImage")
                } else if connection == getTournaments {
                    sendErrorNotification(responseDict, name: "getTournaments")
                } else if connection == registerForTournament {
                    sendErrorNotification(responseDict, name: "registerForTournament")
                } else if connection == codeConfirmed {
                    sendErrorNotification(responseDict, name: "codeConfirmed")
                }

            }
            
        } catch {
            
            print("\(error)");
            let jsonString = NSString(data: data, encoding: NSUTF8StringEncoding)!;
            print(jsonString)
           // logError(jsonString! as String);
        }
    }
    
    
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        let errorDict: Dictionary<String,String>! = [
            "errorMessage": "No nos pudimos conectar al servidor.",
        ]
        if connection == checkToken {
            sendErrorNotification(errorDict, name: "tokenCheckFailed");
        }
        
    }
    
    func convertStringToDictionary(text: String) -> NSArray? {
        if let data = text.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSArray
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
    
    //MARK: Connection Ok Actions
    
    
    func getPhoneCode(responseDict: NSDictionary) {
        if let data = responseDict["data"] as? NSDictionary {
            if let code = data["code"] as? String {
                GlobalVars.sharedInstance().phoneCode = code
                Tools.sendNotification("getPhoneCodeFinished", object: self)
            }
        }
    }
            
    func registerUser(responseDict: NSDictionary) {
        if let data = responseDict["data"] as? NSDictionary {
            if let token = data["token"] as? String {
                let globalVars = GlobalVars.sharedInstance()
                globalVars.token = token
                Tools.setToken(token)
                Tools.sendNotification("registerUserFinished", object: self)
            }
        }
    }
    
    func getUserByToken(responseDict: NSDictionary) {
        if let data = responseDict["data"] as? NSDictionary {
            if let user = data["user"] as? NSDictionary {
                let globalVars = GlobalVars.sharedInstance()
                if let id = user["id"] as? String {
                    globalVars.userId = Int(id)!
                    if let phone = user["phone"] as? String {
                        globalVars.userPhoneNumber = phone
                        if let name = user["name"] as? String {
                            GlobalVars.sharedInstance().userName = name
                        }
                        Tools.sendNotification("getUserByTokenFinished", object: self)
                    }
                }
            }
        }
    }
    
    func getAllRegions(responseDict: NSDictionary) {
        if let data = responseDict["data"] as? NSDictionary {
            if let regions = data["regions"] as? NSArray {
                for region in regions {
                    if let regionAsDict = region as? NSDictionary {
                        let newRegion:Region;
                        let modelId = Int(regionAsDict["id"] as! String)!
                        let regionArr = DatabaseManager.getFromDatabase("Region", predicateString: "modelId ==\(modelId)") as! [Region];
                        if (regionArr.count == 0) {
                            newRegion = DatabaseManager.insertObject("Region") as! Region;
                            newRegion.modelId=modelId;
                        } else {
                            newRegion = regionArr[0];
                        }
                        newRegion.name = (regionAsDict["name"] as! String).uppercaseString
                        newRegion.modelDeleted = Int(regionAsDict["deleted"] as! String)!
                        
                        if let longitude = Double(regionAsDict["longitude"] as! String) {
                            if let latitude = Double(regionAsDict["latitude"] as! String) {
                                newRegion.longitude = longitude
                                newRegion.latitude = latitude
                            } else {
                                //else set uruguay coordinates
                                newRegion.latitude = -32.5228
                                newRegion.longitude = -55.7658
                            }
                        } else {
                            newRegion.latitude = -32.5228
                            newRegion.longitude = -55.7658
                        }
                        
                        
                        
                        if let cities = region["cities"] as? NSArray {
                            for city in cities {
                                if let cityDict = city as? NSDictionary {
                                    downloadCity(cityDict, regionId: Int(newRegion.modelId!))
                                }
                            }
                        }
                    }
                }
                GlobalVars.sharedInstance().regionsLastUpdate = Tools.dateTimeFromCurrentDate()
                Tools.setValueForKey(Tools.dateTimeFromCurrentDate(), key: "regionsLastUpdate")
                try! managedObjectContext.save();
                Tools.sendNotification("getAllRegionsFinished", object: self)
            }
        }
    }
    
    func downloadCity(cityDict: NSDictionary, regionId: Int) {
        let newCity: City
        let modelId = Int(cityDict["id"] as! String)!
        let cityArr = DatabaseManager.getFromDatabase("City", predicateString: "modelId ==\(modelId)") as! [City];
        if (cityArr.count == 0) {
            newCity = DatabaseManager.insertObject("City") as! City;
            newCity.modelId=modelId;
        } else {
            newCity = cityArr[0];
        }
        newCity.regionId = regionId
        newCity.name = (cityDict["name"] as! String).uppercaseString
        newCity.modelDeleted = Int(cityDict["deleted"] as! String)!
        
        if let longitude = Double(cityDict["longitude"] as! String) {
            if let latitude = Double(cityDict["latitude"] as! String) {
                newCity.longitude = longitude
                newCity.latitude = latitude
            } else {
                //else set uruguay coordinates
                newCity.latitude = -32.5228
                newCity.longitude = -55.7658
            }
        } else {
            newCity.latitude = -32.5228
            newCity.longitude = -55.7658
        }

        
        if let neighbourhoods = cityDict["neighbourhoods"] as? NSArray {
            for neighbourhood in neighbourhoods {
                if let neighbourhoodDict = neighbourhood as? NSDictionary {
                    downloadNeighbourhood(neighbourhoodDict, cityId: Int(newCity.modelId!))
                }
            }
        }
    }
    
    func downloadNeighbourhood(neighbourhoodDict: NSDictionary, cityId: Int) {
        let newNeighbourhood: Neighbourhood
        let modelId = Int(neighbourhoodDict["id"] as! String)!
        let neighbourhoodArr = DatabaseManager.getFromDatabase("Neighbourhood", predicateString: "modelId ==\(modelId)") as! [Neighbourhood];
        if (neighbourhoodArr.count == 0) {
            newNeighbourhood = DatabaseManager.insertObject("Neighbourhood") as! Neighbourhood;
            newNeighbourhood.modelId = modelId;
        } else {
            newNeighbourhood = neighbourhoodArr[0];
        }
        newNeighbourhood.cityId = cityId
        newNeighbourhood.name = (neighbourhoodDict["name"] as! String).uppercaseString
        newNeighbourhood.modelDeleted = Int(neighbourhoodDict["deleted"] as! String)!
        
        if let longitude = Double(neighbourhoodDict["longitude"] as! String) {
            if let latitude = Double(neighbourhoodDict["latitude"] as! String) {
                newNeighbourhood.longitude = longitude
                newNeighbourhood.latitude = latitude
            } else {
                //else set uruguay coordinates
                newNeighbourhood.latitude = -32.5228
                newNeighbourhood.longitude = -55.7658
            }
        } else {
            newNeighbourhood.latitude = -32.5228
            newNeighbourhood.longitude = -55.7658
        }
        
        if let facilities = neighbourhoodDict["facilities"] as? NSArray {
            for facility in facilities {
                if let facilityDict = facility as? NSDictionary {
                    downloadFacility(facilityDict, neighbourhoodId: Int(newNeighbourhood.modelId!))
                }
            }
        }
    }
    
    func downloadFacility(facilityDict: NSDictionary, neighbourhoodId: Int) {
        let newFacility: Facility
        let modelId = Int(facilityDict["id"] as! String)!
        let facilityArr = DatabaseManager.getFromDatabase("Facility", predicateString: "modelId ==\(modelId)") as! [Facility];
        if (facilityArr.count == 0) {
            newFacility = DatabaseManager.insertObject("Facility") as! Facility;
            newFacility.modelId = modelId;
        } else {
            newFacility = facilityArr[0];
        }
        newFacility.neighbourhoodId = neighbourhoodId
        newFacility.name = (facilityDict["name"] as! String).uppercaseString
        newFacility.modelDeleted = Int(facilityDict["deleted"] as! String)!
        newFacility.timesSelected = 0
        newFacility.shortName = (facilityDict["short_name"] as! String).uppercaseString
        
        if let longitude = Double(facilityDict["longitude"] as! String) {
            if let latitude = Double(facilityDict["latitude"] as! String) {
                newFacility.longitude = longitude
                newFacility.latitude = latitude
            } else {
                //else set uruguay coordinates
                newFacility.latitude = -32.5228
                newFacility.longitude = -55.7658
            }
        } else {
            newFacility.latitude = -32.5228
            newFacility.longitude = -55.7658
        }
        
        if let fields = facilityDict["fields"] as? NSArray {
            for field in fields {
                if let fieldDict = field as? NSDictionary {
                    downloadField(fieldDict, facilityId: Int(newFacility.modelId!))
                }
            }
        }
    }
    
    func downloadField(fieldDict: NSDictionary, facilityId: Int) {
        let newField: Field
        let modelId = Int(fieldDict["id"] as! String)!
        let fieldArr = DatabaseManager.getFromDatabase("Field", predicateString: "modelId ==\(modelId)") as! [Field];
        if (fieldArr.count == 0) {
            newField = DatabaseManager.insertObject("Field") as! Field
            newField.modelId = modelId
        } else {
            newField = fieldArr[0];
        }
        newField.facilityId = facilityId
        newField.fieldNumber = Int(fieldDict["id"] as! String)
        newField.modelDeleted = Int(fieldDict["deleted"] as! String)!
        newField.hasRoof = Bool(Int(fieldDict["covered"] as! String)!)
    }
    
    func getAvailableCourts(responseDict: NSDictionary) {
        if let data = responseDict["fieldIDs"] as? NSArray {
            if let datesData = responseDict["fieldDates"] as? NSArray {
            var fields = [Int]()
            var dates = [String]()
            for i in 0...(data.count - 1) {
                if let elementAsString = data[i] as? String {
                    fields.append(Int(elementAsString)!)
                    dates.append(datesData[i] as! String)
                }
            }
            GlobalVars.sharedInstance().availableFieldIds = fields
            GlobalVars.sharedInstance().availableFieldDates = dates
            Tools.sendNotification("getAvailableCourtsFinished", object: self)
            } else {
                print("No courts found")
            }
        }
    }
    
    func updateUserInformation(responseDict: NSDictionary) {
        Tools.sendNotification("updateUserInformationFinished", object: self)
    }
    
    func updateImageData(responseDict: NSDictionary) {
        Tools.sendNotification("updateImageDataFinished", object: self)
    }
    
    func updateTeamImageData(responseDict: NSDictionary) {
        GlobalVars.sharedInstance().teamsLastUpdate = Tools.dateTimeFromCurrentDate()
        Tools.setValueForKey(Tools.dateTimeFromCurrentDate(), key: "teamsLastUpdate")
        Tools.sendNotification("updateTeamImageDataFinished", object: self)
    }
    
    func getUserNamesByPhones(responseDict: NSDictionary) {
        if let users = responseDict["users"] as? NSArray {
            var savedUserNames = [(userName: String, id: Int)]()
            for user in users {
                if let userDict = user as? NSDictionary {
                    savedUserNames.append((userDict["username"] as! String, Int(userDict["userId"] as! String)!))
                    if let receivedString = (DatabaseManager.getItem("Player", predicateString: "modelId == \(userDict["userId"] as! String)") as? String) {
                        if receivedString == "no object found" {
                            let newPlayer = DatabaseManager.insertObject("Player") as! Player
                            newPlayer.name = userDict["name"] as! String
                            newPlayer.modelId = Int(userDict["userId"] as! String)!
                            newPlayer.modelDeleted = false
                        }
                    }
                }
            }
            //GlobalVars.sharedInstance().userNamesById = savedUserNames
        }
        try! managedObjectContext.save();
        Tools.sendNotification("getUserNamesByPhonesFinished", object: self)
    }
    
    func createTeam(responseDict: NSDictionary) {
        if let teamID = Int(responseDict["teamID"] as! String) {
            GlobalVars.sharedInstance().receivedTeamID = teamID
            let team = DatabaseManager.insertObject("Team") as! Team
            team.modelDeleted = false
            team.modelId = teamID
            team.name = responseDict["name"] as! String
            if let image = GlobalVars.sharedInstance().selectedImage {
                team.setTeamImage(image)
            }
            if let playerIDs = GlobalVars.sharedInstance().chosenPlayers {
                for playerID in playerIDs {
                    let teamPlayer = DatabaseManager.insertObject("TeamPlayers") as! TeamPlayers
                    teamPlayer.modelDeleted = false
                    teamPlayer.playerId = playerID
                    teamPlayer.teamId = teamID
                }
            }
            try! managedObjectContext.save();
            Tools.sendNotification("createTeamFinished", object: self)
        }
    }
    
    /*func getTeamsByUserID(responseDict: NSDictionary) {
        /*if let teams = responseDict["teams"] as? NSArray {
            //GlobalVars.sharedInstance().receivedTeams = teams
            
            for teamObject in teams {
                let team = teamObject as! NSDictionary
                if (DatabaseManager.getFromDatabase("Team", predicateString: "modelId == \(team["id"] as! String)") as NSArray).count == 0 {
                    let newTeam = DatabaseManager.insertObject("Team") as! Team
                    newTeam.modelId = Int((team as! NSDictionary)["id"] as! String)
                    newTeam.name = (team as! NSDictionary)["name"] as! String
                    newTeam.modelDeleted = 0
                }
            }
            try! managedObjectContext.save();
            Tools.sendNotification("loadPlayerTeamsFinished", object: self)
        }*/
        
    }*/
    
    func getTeamByID(responseDict: NSDictionary) {
        GlobalVars.sharedInstance().receivedTeam = (responseDict["team"] as! NSDictionary)
        Tools.sendNotification("getTeamByIDFinished", object: self)
    }
    
    func addPlayers(responseDict: NSDictionary) {
        Tools.sendNotification("addPlayersFinished", object: self)
    }
    
    func leaveTeam(responseDict: NSDictionary) {
        let id = Int(responseDict["team_id"] as! NSNumber)
        let teamArray = DatabaseManager.getFromDatabase("Team", predicateString: "modelId == \(id)") as! NSArray
        let team = teamArray[0] as! Team
        team.modelDeleted = true
        try! managedObjectContext.save();
        Tools.sendNotification("leaveTeamFinished", object: self)
    }
    
    func placeReservation(responseDict: NSDictionary) {
        Tools.sendNotification("placeReservationFinished", object: self)
    }
    
    func createMatchSearch(responseDict: NSDictionary) {
        if let response = responseDict["result"] as? String {
            //not found
        } else {
            if let results = responseDict["result"] as? NSArray {
                if results.count > 0 {
                    GlobalVars.sharedInstance().foundMatchSearches = results
                }
            }
            Tools.sendNotification("createMatchSearchFinished", object: self)
        }
    }
    
    func updateTeamsData(responseDict: NSDictionary) {
        
        if let teamsArray = responseDict["teams"] as? NSArray {
            for team in teamsArray {
                let teamDict = team as! NSDictionary
                if let teamModel = DatabaseManager.getItem("Team", predicateString: "modelId == \(teamDict["id"] as! String)") as? Team {
                    teamModel.modelDeleted = Int(teamDict["deleted"] as! String)!
                }
            }
            GlobalVars.sharedInstance().teamsLastUpdate = Tools.dateTimeFromCurrentDate()
            Tools.setValueForKey(responseDict["date"] as! String, key: "teamsLastUpdate")
            try! managedObjectContext.save();
        }
        Tools.sendNotification("updateTeamsDataFinished", object: self)
    }
    
    func challengeTeam(responseDict: NSDictionary) {
        Tools.sendNotification("challengeTeamFinished", object: self)
    }
    
    func getAllChallenges(responseDict: NSDictionary) {
        if let _ = responseDict["challenges"] {
            let challenges = responseDict["challenges"] as! NSDictionary
            GlobalVars.sharedInstance().receivedPendingChallenges = challenges["pending"] as! [NSDictionary]
            GlobalVars.sharedInstance().receivedCurrentChallenges = challenges["current"] as! [NSDictionary]
            
        }
        Tools.sendNotification("getAllChallengesFinished", object: self)
    }
    
    func answerChallenge(responseDict: NSDictionary) {
        Tools.sendNotification("answerChallengeFinished", object: self)
    }
    
    func getTeamImage(responseDict: NSDictionary) {
        GlobalVars.sharedInstance().receivedImage = nil
        if let imageData = responseDict["image"] as? String {
            let decodedData = NSData(base64EncodedString: imageData, options: .IgnoreUnknownCharacters)
            let image = UIImage(data: decodedData!)
            GlobalVars.sharedInstance().receivedImage = image
        }
        Tools.sendNotification("getTeamImageFinished", object: self)
    }
    
    func getTournaments(responseDict: NSDictionary) {
        GlobalVars.sharedInstance().receivedTournaments = responseDict
        Tools.sendNotification("getTournamentsFinished", object: self)
    }
    
    func registerForTournament(responseDict: NSDictionary) {
        Tools.sendNotification("registerForTournamentFinished", object: self)
    }
    
    func codeConfirmed(responseDict: NSDictionary) {
        Tools.sendNotification("codeConfirmedFinished", object: self)
    }
    
    //MARK: Connection Error Actions
    
    func sendErrorNotification(responseDict:NSDictionary, name:String){
        let errorMessage = responseDict.valueForKey("errorMessage") as! String;
        let errorDict: Dictionary<String,String>! = [
            "error": errorMessage,
        ]
        NSNotificationCenter.defaultCenter().postNotificationName(name, object: self, userInfo: errorDict)
    }
}
