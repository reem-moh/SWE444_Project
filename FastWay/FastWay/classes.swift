//
//  classes.swift
//  FastWay
//
//  Created by taif.m on 2/4/21.
//

import Foundation
import Firebase
import FirebaseFirestore
import Combine
import MapKit


let db = Firestore.firestore()

class Member: ObservableObject {
    
    var id: String
    var name: String
    var email: String
    var phoneNo: String
    
    @Published var member = M(id: "", name: "", email: "", phoneNo: "")
    //initialize from DB
    init(id : String = UserDefaults.standard.getUderId()) {
        self.id = ""
        self.name = ""
        self.email = ""
        self.phoneNo = ""
        self.getMember(id: id)
    }
    
    init(id: String, name: String, email: String, phN: String) {
        self.id = id
        self.name = name
        self.email = email
        self.phoneNo = phN
    }
    
    func addMember(member: Member) -> Bool {
        let doc = db.collection("Member").document(id)
        var flag = true
        doc.setData(["ID":self.id, "Name":self.name, "PhoneNo": self.phoneNo, "Email": self.email]) { (error) in
            
            if error != nil {
                flag = false
            }
        }
        
        return flag
    }
    
    //retrieve from database
    func getMember(id: String){
        
        
        db.collection("Member").document(id).addSnapshotListener { (querySnapshot, error) in
            guard let doc = querySnapshot else{
                print("no member document")
                return
            }
            guard let data = doc.data() else {
                print("no member data")
                return
            }
            //assign values from db to variables
            self.member.id = id
            self.member.name = data["Name"] as? String ?? ""
            self.member.email = data["Email"] as? String ?? ""
            self.member.phoneNo = data["PhoneNo"] as? String ?? ""
            
            print("----------")
            print("inside class Member")
            print("got member data  \(self.member.name)")
            print("got member data  \(self.member.email)")
            print("got member data  \(self.member.phoneNo)")
            print("----------")
            
        } //listener
        
    } //function
    
}

class Courier: ObservableObject {
    var id: String
    var name: String
    var email: String
    var phoneNo: String
    @Published var courier = C(id: "", name: "", email: "", phoneNo: "")
    //initialize from DB
    init(id: String = UserDefaults.standard.getUderId()) {
        self.id = ""
        self.name = ""
        self.email = ""
        self.phoneNo = ""
        self.getCourier(id: id)
    }
    
    
    init(id: String,name: String, email: String, phN: String) {
        self.id = id
        self.name = name
        self.email = email
        self.phoneNo = phN
    }
    
    func addCourier(courier: Courier) -> Bool {
        let doc = db.collection("Courier").document(id)
        var flag = true
        doc.setData(["ID":self.id, "Name":self.name, "PhoneNo": self.phoneNo, "Email": self.email]) { (error) in
            
            if error != nil {
                flag = false
            }
        }
        
        return flag
    }
    
    //retrieve from database
    func getCourier(id: String){
        
        db.collection("Courier").document(id).addSnapshotListener { (querySnapshot, error) in
            guard let doc = querySnapshot else{
                print("no courier document")
                return
            }
            guard let data = doc.data() else {
                print("no courier data")
                return
            }
            //assign values from db to variables
            self.courier.id = id
            self.courier.name = data["Name"] as? String ?? ""
            self.courier.email = data["Email"] as? String ?? ""
            self.courier.phoneNo = data["PhoneNo"] as? String ?? ""
            
            print("----------")
            print("inside class Courier")
            print("got Courier data  \(self.courier.name)")
            print("got Courier data  \(self.courier.email)")
            print("got Courier data  \(self.courier.phoneNo)")
            print("----------")
            
        } //listener
    } //function
    
    
}

//member info
struct M: Identifiable {
    var id: String
    var name: String
    var email: String
    var phoneNo: String
}
//Courier info
struct C: Identifiable {
    var id: String
    var name: String
    var email: String
    var phoneNo: String
}
//order info
struct OrderDetails: Identifiable {
    var id: String
    var pickUP: CLLocationCoordinate2D!
    var pickUpBulding: Int
    var pickUpFloor: Int
    var pickUpRoom: String
    var dropOff: CLLocationCoordinate2D!
    var dropOffBulding: Int
    var dropOffFloor: Int
    var dropOffRoom: String
    var orderDetails: String
    var memberId : String
    var courierId : String = ""
    var deliveryPrice = 0
    var totalPrice = 0.0
    //to identify whether it is added to cart...
    var isAdded: Bool
    var createdAt : Date = Date()
    var status : String
}
//offer info
struct Offer : Identifiable {
    var id: String
    var OrderId: String
    var memberId: String = ""
    var courierId: String = ""
    var courier : Courier
    var price: Int
    var courierLocation : CLLocationCoordinate2D
}



class Order: ObservableObject{
    
    @Published var orders: [OrderDetails] = [] //for delivery requests have an offer
    @Published var WaitingOrders: [OrderDetails] = [] //for delivery requests waiting
    @Published var ordersCanceled: [OrderDetails] = [] //for cancel order by default
    @Published var memberOrder: [OrderDetails] = [] //for current order
    @Published var CourierOrderOffered: [OrderDetails] = [] // for current order
    @Published var offers: [Offer] = [] // retrieve offer for specific order
    @Published var collectAllOffersForCourier: [Offer] = [] //get data from offer collection
    @Published var orderID: [String] = [] //calculate all order who have state have an offer
    
    var pickUP: CLLocationCoordinate2D!
    var pickUpBulding: Int
    var pickUpFloor: Int
    var pickUpRoom: String
    var dropOff: CLLocationCoordinate2D!
    var dropOffBulding: Int
    var dropOffFloor: Int
    var dropOffRoom: String
    var orderDetails: String
    var memberId: String
    var memberName: String
    var setPick: Bool
    var setDrop: Bool
    var setDetails: Bool
    var status: [String] = ["waiting for offer", "cancled","have an offer","assigned", "completed"]
    
    init(){
        self.pickUP =  CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        self.pickUpBulding = 0
        self.pickUpFloor = -1
        self.pickUpRoom = ""
        self.dropOff =  CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        self.dropOffBulding = 0
        self.dropOffFloor = -1
        self.dropOffRoom = ""
        self.orderDetails =  ""
        self.memberId = ""
        self.memberName = ""
        self.setPick = false
        self.setDrop = false
        self.setDetails = false
    }

    //****************************
          //For Courier user
    //****************************
    //T
    //Retrieve all orders and check if it exceeds 15 minutes to cancel the order
    func getOrderForCancel() {
        print("\n*******GetOrder*********")
        db.collection("Order").whereField("Assigned", isEqualTo: "false").order(by: "CreatedAt", descending: false).addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No order documents")
                return
            }
            self.ordersCanceled = documents.map({ (queryDocumentSnapshot) -> OrderDetails in
                let data = queryDocumentSnapshot.data()
                let OrderId = queryDocumentSnapshot.documentID
                let state = data["Status"] as? String ?? ""
                //pickUp location
                let PickUpLatitude = data["PickUpLatitude"] as? Double ?? 0.0
                let PickUpLongitude = data["PickUpLongitude"] as? Double ?? 0.0
                let pickup = CLLocationCoordinate2D(latitude: PickUpLatitude, longitude: PickUpLongitude)
                let pickupBuilding = data["pickUpBulding"] as? Int ?? 0
                let pickupFloor = data["pickUpFloor"] as? Int ?? 0
                let pickupRoom = data["pickUpRoom"] as? String ?? ""
                //DropOff Location
                let DropOffLatitude = data["DropOffLatitude"] as? Double ?? 0.0
                let DropOffLongitude = data["DropOffLongitude"] as? Double ?? 0.0
                let dropoff = CLLocationCoordinate2D(latitude: DropOffLatitude, longitude: DropOffLongitude)
                let dropoffBuilding = data["dropOffBulding"] as? Int ?? 0
                let dropoffFloor = data["dropOffFloor"] as? Int ?? 0
                let dropoffRoom = data["dropOffRoom"] as? String ?? ""
                let orderDetails = data["orderDetails"] as? String ?? ""
                let assigned = (data["Assigned"] as? String ?? "" == "true" ? true : false)
                let MemberID = data["MemberID"] as? String ?? ""
                        
                let createdAt = data["CreatedAt"] as? Timestamp ?? Timestamp(date: Date())
               // print("order :\(OrderId) + \(pickup) + \(dropoff) + assigned: \(assigned)")
               // print("get order and date finc is \(createdAt.dateValue().calenderTimeSinceNow())")

                return OrderDetails(id: OrderId, pickUP: pickup, pickUpBulding: pickupBuilding, pickUpFloor: pickupFloor, pickUpRoom: pickupRoom, dropOff: dropoff, dropOffBulding: dropoffBuilding, dropOffFloor: dropoffFloor, dropOffRoom: dropoffRoom, orderDetails: orderDetails, memberId: MemberID, isAdded: assigned, createdAt: createdAt.dateValue(), status: state)
            })
            
            
        }
    }
    //T
    //Delivery request for courier [state = waiting for offer]
    func getOrderWaitingForOffer(){
            print("\n*******getOrderWaitingForOffer*********")
            db.collection("Order").whereField("Status", isEqualTo: status[0]).addSnapshotListener { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("No order documents")
                    return
                }
                self.WaitingOrders = documents.map({ (queryDocumentSnapshot) -> OrderDetails in
                    let data = queryDocumentSnapshot.data()
                    let OrderId = queryDocumentSnapshot.documentID
                    let state = data["Status"] as? String ?? ""
                    //pickUp location
                    let PickUpLatitude = data["PickUpLatitude"] as? Double ?? 0.0
                    let PickUpLongitude = data["PickUpLongitude"] as? Double ?? 0.0
                    let pickup = CLLocationCoordinate2D(latitude: PickUpLatitude, longitude: PickUpLongitude)
                    let pickupBuilding = data["pickUpBulding"] as? Int ?? 0
                    let pickupFloor = data["pickUpFloor"] as? Int ?? 0
                    let pickupRoom = data["pickUpRoom"] as? String ?? ""
                    //DropOff Location
                    let DropOffLatitude = data["DropOffLatitude"] as? Double ?? 0.0
                    let DropOffLongitude = data["DropOffLongitude"] as? Double ?? 0.0
                    let dropoff = CLLocationCoordinate2D(latitude: DropOffLatitude, longitude: DropOffLongitude)
                    let dropoffBuilding = data["dropOffBulding"] as? Int ?? 0
                    let dropoffFloor = data["dropOffFloor"] as? Int ?? 0
                    let dropoffRoom = data["dropOffRoom"] as? String ?? ""
                    let orderDetails = data["orderDetails"] as? String ?? ""
                    let assigned = (data["Assigned"] as? String ?? "" == "true" ? true : false)
                    let MemberID = data["MemberID"] as? String ?? ""
                    let createdAt = data["CreatedAt"] as? Timestamp ?? Timestamp(date: Date())
                    print("order :\(OrderId) + \(pickup) + \(dropoff) + assigned: \(assigned)")
                    print("get order and date finc is \(createdAt.dateValue().calenderTimeSinceNow())")
                    return OrderDetails(id: OrderId, pickUP: pickup, pickUpBulding: pickupBuilding, pickUpFloor: pickupFloor, pickUpRoom: pickupRoom, dropOff: dropoff, dropOffBulding: dropoffBuilding, dropOffFloor: dropoffFloor, dropOffRoom: dropoffRoom, orderDetails: orderDetails, memberId: MemberID, isAdded: assigned, createdAt: createdAt.dateValue(), status: state)
                })
                
                
     }
    }
    //T
    //Delivery request for courier [state = have an offer] from offer collection
    func getAllOffersFromCourier(completion: @escaping (_ success: Bool) -> Void) {
        self.orderID.removeAll()
        let id = UserDefaults.standard.getUderId()
        print("inside getAllOffersFromCourier")
        //retrieve all offers from the courier
            db.collection("Offers").whereField("CourierID", isEqualTo: id)//have an offer
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents getAllOffersFromCourier: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            let data = document.data()
                            let orderID = data["OrderID"] as? String ?? ""
                            print("getAllOffersFromCourier Offer =>\(document.documentID) \(document.data())")
                            self.orderID.append(orderID)
                        }
                        print("End loop inside getAllOffersFromCourier")
                        
                    }
                    let success = true
                    DispatchQueue.main.async {
                        print("inside getAllOffersFromCourier in dispatch")
                        completion(success)
                    }
                }
    }
    //T
    //Delivery request for courier [state = have an offer] from order collection
    func getOrder() {
            print("inside getOrder") //status[2] = have an offer
            db.collection("Order").whereField("Status", isEqualTo: status[2]).order(by: "CreatedAt", descending: false).addSnapshotListener { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("No order documents")
                    return
                }
                self.orders = documents.map({ (queryDocumentSnapshot) -> OrderDetails in
                    let data = queryDocumentSnapshot.data()
                    let OrderId = queryDocumentSnapshot.documentID
                    let state = data["Status"] as? String ?? ""
                    //pickUp location
                    let PickUpLatitude = data["PickUpLatitude"] as? Double ?? 0.0
                    let PickUpLongitude = data["PickUpLongitude"] as? Double ?? 0.0
                    let pickup = CLLocationCoordinate2D(latitude: PickUpLatitude, longitude: PickUpLongitude)
                    let pickupBuilding = data["pickUpBulding"] as? Int ?? 0
                    let pickupFloor = data["pickUpFloor"] as? Int ?? 0
                    let pickupRoom = data["pickUpRoom"] as? String ?? ""
                    //DropOff Location
                    let DropOffLatitude = data["DropOffLatitude"] as? Double ?? 0.0
                    let DropOffLongitude = data["DropOffLongitude"] as? Double ?? 0.0
                    let dropoff = CLLocationCoordinate2D(latitude: DropOffLatitude, longitude: DropOffLongitude)
                    let dropoffBuilding = data["dropOffBulding"] as? Int ?? 0
                    let dropoffFloor = data["dropOffFloor"] as? Int ?? 0
                    let dropoffRoom = data["dropOffRoom"] as? String ?? ""
                    let orderDetails = data["orderDetails"] as? String ?? ""
                    let assigned = (data["Assigned"] as? String ?? "" == "true" ? true : false)
                    let MemberID = data["MemberID"] as? String ?? ""
                    let createdAt = data["CreatedAt"] as? Timestamp ?? Timestamp(date: Date())
                    
                    print("order inside getOrder:\(OrderId) + \(pickup) + \(dropoff) + assigned: \(assigned)")
                    return OrderDetails(id: OrderId, pickUP: pickup, pickUpBulding: pickupBuilding, pickUpFloor: pickupFloor, pickUpRoom: pickupRoom, dropOff: dropoff, dropOffBulding: dropoffBuilding, dropOffFloor: dropoffFloor, dropOffRoom: dropoffRoom, orderDetails: orderDetails, memberId: MemberID, isAdded: assigned, createdAt: createdAt.dateValue(), status: state)
                        
                    
                })
            }
    }
    //T
    //add offer for specific order in Delivery request
    func addOffer(OrderId: String,memberID: String,price: Int,locationLatiude :Double,locationLongitude :Double){
        print("\n*******addOffer*********")
        let CourierId = UserDefaults.standard.getUderId()
        //change the state of order to have an offer
         db.collection("Order").document(OrderId).setData([ "Status": status[2]], merge: true)
        //create document inside offer collection
        var doc: DocumentReference? = nil
        doc = db.collection("Offers").addDocument(data:
            ["OrderID": OrderId,"MemberID": memberID,"CourierID" : CourierId ,"Price": price,"CourierLatitude": locationLatiude,"CourierLongitude":locationLongitude]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(doc!.documentID)")
            }
        }
    }
    //F
    //current order for courier [state = assign]
    func getCourierOrderAssign(Id: String){
        db.collection("Order").whereField("CourierID", isEqualTo: Id).order(by: "CreatedAt", descending: false).addSnapshotListener { (querySnapshot, error) in
        guard let documents = querySnapshot?.documents else {
            print("No order CCCC documents")
            return
        }
        self.CourierOrderOffered = documents.map({ (queryDocumentSnapshot) -> OrderDetails in
            
            let data = queryDocumentSnapshot.data()
            let orderId = queryDocumentSnapshot.documentID
            //pickUp location
            let PickUpLatitude = data["PickUpLatitude"] as? Double ?? 0.0
            let PickUpLongitude = data["PickUpLongitude"] as? Double ?? 0.0
            let pickup = CLLocationCoordinate2D(latitude: PickUpLatitude, longitude: PickUpLongitude)
            let pickupBuilding = data["pickUpBulding"] as? Int ?? 0
            let pickupFloor = data["pickUpFloor"] as? Int ?? 0
            let pickupRoom = data["pickUpRoom"] as? String ?? ""
            //DropOff Location
            let DropOffLatitude = data["DropOffLatitude"] as? Double ?? 0.0
            let DropOffLongitude = data["DropOffLongitude"] as? Double ?? 0.0
            let dropoff = CLLocationCoordinate2D(latitude: DropOffLatitude, longitude: DropOffLongitude)
            let dropoffBuilding = data["dropOffBulding"] as? Int ?? 0
            let dropoffFloor = data["dropOffFloor"] as? Int ?? 0
            let dropoffRoom = data["dropOffRoom"] as? String ?? ""
            let orderDetails = data["orderDetails"] as? String ?? ""
            let assigned = (data["Assigned"] as? String ?? "" == "true" ? true : false)
            let MemberID = data["MemberID"] as? String ?? ""
            let state = data["Status"] as? String ?? ""
            let createdAt = data["CreatedAt"] as? Timestamp ?? Timestamp(date: Date())
            let price = data["DeliveryPrice"] as? Int ?? 0
            print("order :\(orderId) + \(pickup) + \(dropoff) + assigned: \(assigned)")
            print("in get order COURIER OFFER and date finc is \(createdAt.dateValue().calenderTimeSinceNow())")
            return OrderDetails(id: orderId, pickUP: pickup, pickUpBulding: pickupBuilding, pickUpFloor: pickupFloor, pickUpRoom: pickupRoom, dropOff: dropoff, dropOffBulding: dropoffBuilding, dropOffFloor: dropoffFloor, dropOffRoom: dropoffRoom, orderDetails: orderDetails, memberId: MemberID, courierId:Id ,deliveryPrice:price, isAdded: assigned, createdAt: createdAt.dateValue(), status: state)
            })
            
        }
    }
    //T
    func getAllOffersFromCourierInCurrentOrder(completion: @escaping (_ success: Bool) -> Void) {
        self.orderID.removeAll()
        let id = UserDefaults.standard.getUderId()
        print("inside getAllOffersFromCourier")
        //retrieve all offers from the courier
            db.collection("Offers").whereField("CourierID", isEqualTo: id)//have an offer
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents getAllOffersFromCourier: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            let data = document.data()
                            let orderID = data["OrderID"] as? String ?? ""
                            print("getAllOffersFromCourier Offer =>\(document.documentID) \(document.data())")
                            self.orderID.append(orderID)
                        }
                        print("End loop inside getAllOffersFromCourier")
                        
                    }
                    print("inside getAllOffersFromCourier before getOrder")
                    //add these orders
                    self.getOrderForCurrentOrder(){ success in
                        print("inside getAllOffersFromCourier after getOrder")
                        guard success else { return }
                        let success = true
                        DispatchQueue.main.async {
                            print("inside getAllOffersFromCourier in dispatch")
                            completion(success)
                        }
                    }
                }
    }
    //T
    func getOrderForCurrentOrder(completion: @escaping (_ success: Bool) -> Void) {
            print("inside getOrder")
            db.collection("Order").whereField("Status", isEqualTo: status[2]).order(by: "CreatedAt", descending: false).addSnapshotListener { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("No order documents")
                    return
                }
                self.CourierOrderOffered = documents.map({ (queryDocumentSnapshot) -> OrderDetails in
                    let data = queryDocumentSnapshot.data()
                    let OrderId = queryDocumentSnapshot.documentID
                    let state = data["Status"] as? String ?? ""
                    //pickUp location
                    let PickUpLatitude = data["PickUpLatitude"] as? Double ?? 0.0
                    let PickUpLongitude = data["PickUpLongitude"] as? Double ?? 0.0
                    let pickup = CLLocationCoordinate2D(latitude: PickUpLatitude, longitude: PickUpLongitude)
                    let pickupBuilding = data["pickUpBulding"] as? Int ?? 0
                    let pickupFloor = data["pickUpFloor"] as? Int ?? 0
                    let pickupRoom = data["pickUpRoom"] as? String ?? ""
                    //DropOff Location
                    let DropOffLatitude = data["DropOffLatitude"] as? Double ?? 0.0
                    let DropOffLongitude = data["DropOffLongitude"] as? Double ?? 0.0
                    let dropoff = CLLocationCoordinate2D(latitude: DropOffLatitude, longitude: DropOffLongitude)
                    let dropoffBuilding = data["dropOffBulding"] as? Int ?? 0
                    let dropoffFloor = data["dropOffFloor"] as? Int ?? 0
                    let dropoffRoom = data["dropOffRoom"] as? String ?? ""
                    let orderDetails = data["orderDetails"] as? String ?? ""
                    let assigned = (data["Assigned"] as? String ?? "" == "true" ? true : false)
                    let MemberID = data["MemberID"] as? String ?? ""
                    let createdAt = data["CreatedAt"] as? Timestamp ?? Timestamp(date: Date())
                    
                    print("order inside getOrder:\(OrderId) + \(pickup) + \(dropoff) + assigned: \(assigned)")
                    return OrderDetails(id: OrderId, pickUP: pickup, pickUpBulding: pickupBuilding, pickUpFloor: pickupFloor, pickUpRoom: pickupRoom, dropOff: dropoff, dropOffBulding: dropoffBuilding, dropOffFloor: dropoffFloor, dropOffRoom: dropoffRoom, orderDetails: orderDetails, memberId: MemberID, isAdded: assigned, createdAt: createdAt.dateValue(), status: state)
                        
                    
                })
                let success = true
                DispatchQueue.main.async {
                    completion(success)
                }
                
            }
    }
    //**************************************
          //For Courier and Member user
    //**************************************
    
    //T@@@@@@@@@@@@@@@@@@@@@@
    //get all offers made to a specific order
    func getOffers(OrderId: String){
        print("\n*******GetOffersMember*********")
        db.collection("Offers").whereField("OrderID", isEqualTo: OrderId).order(by: "Price", descending: false).addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No offer documents")
                
                return
            }
            if(documents.isEmpty){
                print("no offer documents")
            }
            self.offers = documents.map({ (queryDocumentSnapshot) -> Offer in
                print(queryDocumentSnapshot.data())
                let data = queryDocumentSnapshot.data()
                let offerId = queryDocumentSnapshot.documentID
                let orderId = data["OrderID"] as? String ?? ""
                let memberID = data["MemberID"] as? String ?? ""
                let courierID = data["CourierID"] as? String ?? ""
                let courierLatitude = data["CourierLatitude"] as? Double ?? 0.0
                let courierLongitude = data["CourierLongitude"] as? Double ?? 0.0
                let Price = data["Price"] as? Int ?? 0
                let courierLocation = CLLocationCoordinate2D(latitude: courierLatitude, longitude: courierLongitude)
                print("order :\(offerId) + \(memberID) ")
                return Offer( id: offerId, OrderId: orderId , memberId: memberID ,courierId: courierID, courier: Courier(id: courierID), price: Price, courierLocation: courierLocation)
            })
        }
    }
    
    //T@@@@@@@@@@@@@@@@@@@@@@
    //cancels an offer and changes the order status to waiting for offers if needed
    func cancelOffer(CourierID: String, OrderId: String, MemberID: String, Price: Int) {
        
        print("\n*******cancelOffer*********")

        getOffers(OrderId: OrderId)
        
        if self.offers.count == 1{
            print("change the state of order to waiting for offer")
            db.collection("Order").document(OrderId).setData([ "Status": status[0] ], merge: true)
        }
        
        print("delete offer from database")
        
            let indexOffer = self.checkOfferForCancle(CourierID: CourierID, OrderId: OrderId, MemberID: MemberID, Price: Price)
                
                if indexOffer != -1{
                    print("delete offer from database")

                    db.collection("Offers").document(offers[indexOffer].id).delete(){ err in
                    if let err = err {
                        print("Error removing offer inside cancelOffer: \(err)")
                    } else {
                        print("offer successfully delete inside cancelOffer!")
                    }
                }
                
        }
    
        
    }
    
    //T@@@@@@@@@@@@@@@@@@@@@
    //return the index of the offer to be canceled in array offers
    func checkOfferForCancle(CourierID: String, OrderId: String, MemberID: String, Price: Int) -> Int {
       // var flag = true
        var i = -1
        var j = -1
        for offer in  offers {
            j = j+1
            if (offer.courierId == CourierID && offer.OrderId == OrderId && offer.memberId == MemberID && offer.price == Price) {
               // flag = true
                i = j
            }
        }
        return i
    }
    
    
    //****************************
          //For Member user
    //****************************
    
    //Add new Order
    func setpickUPAndpickUpDetails(pickUP: CLLocationCoordinate2D ,pickUpBulding: Int, pickUpFloor: Int, pickUpRoom: String)-> Bool{
        self.pickUP = pickUP
        self.pickUpBulding = pickUpBulding
        self.pickUpFloor = pickUpFloor
        self.pickUpRoom = pickUpRoom
        var flag = false
        if (pickUP.latitude != 0.0 && pickUP.longitude != 0.0 && pickUpBulding != 0 &&  pickUpFloor != -1 &&  pickUpRoom != "")
        {
            flag = true
            self.setPick = true
        }
        else {
            
            flag = false
        }
        
        return flag
    }
    
    //Add new Order
    func setDropOffAndDropOffDetails(dropOff: CLLocationCoordinate2D, dropOffBulding: Int, dropOffFloor: Int, dropOffRoom: String   )-> Bool{
        self.dropOff = dropOff
        self.dropOffBulding = dropOffBulding
        self.dropOffFloor = dropOffFloor
        self.dropOffRoom = dropOffRoom
        var flag = false
        if (dropOff.latitude != 0.0 && dropOff.longitude != 0.0 && dropOffBulding != 0 &&  dropOffFloor != -1 &&  dropOffRoom != "")
        {
            flag = true
            self.setDrop = true
        }
        else {
            
            flag = false
        }
        return flag
    }
    
    //Add new Order
    func setOrderDetails(orderDetails: String)-> Bool{
        self.orderDetails=orderDetails
        var flag = false
        if orderDetails != ""
        {
            flag = true
            self.setDetails = true
        }else
        
        {
            flag = false
            
        }
        
        return flag
    }
    
    //Add new Order
    func addOrder() -> Bool {
        var flag = true
        let id = UserDefaults.standard.getUderId()
        let doc = db.collection("Order").document()
        if (self.setPick && self.setDrop && self.setDetails){
            doc.setData(["MemberID": id,"PickUpLatitude":self.pickUP.latitude,"PickUpLongitude":self.pickUP.longitude, "pickUpBulding":self.pickUpBulding, "pickUpFloor": self.pickUpFloor, "pickUpRoom": self.pickUpRoom, "DropOffLatitude":self.dropOff.latitude,"DropOffLongitude":self.dropOff.longitude, "dropOffBulding": self.dropOffBulding, "dropOffFloor": self.dropOffFloor, "dropOffRoom": self.dropOffRoom,"orderDetails": self.orderDetails, "Assigned": "false", "CreatedAt": FieldValue.serverTimestamp(), "Status": self.status[0]]) { (error) in
                
                if error != nil {
                    flag = false
                }
            }
        }
        return flag
    }
    
    //get all member orders where member id equals the id sent
    func getMemberOrder(Id: String){
        print("\n*******GetMemberOrder*********")
        db.collection("Order").whereField("MemberID", isEqualTo: Id).order(by: "CreatedAt", descending: false).addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No order documents")
                return
            }
            self.memberOrder = documents.map({ (queryDocumentSnapshot) -> OrderDetails in
                print(queryDocumentSnapshot.data())
                let data = queryDocumentSnapshot.data()
                let uid = queryDocumentSnapshot.documentID
                //pickUp location
                let PickUpLatitude = data["PickUpLatitude"] as? Double ?? 0.0
                let PickUpLongitude = data["PickUpLongitude"] as? Double ?? 0.0
                let pickup = CLLocationCoordinate2D(latitude: PickUpLatitude, longitude: PickUpLongitude)
                let pickupBuilding = data["pickUpBulding"] as? Int ?? 0
                let pickupFloor = data["pickUpFloor"] as? Int ?? 0
                let pickupRoom = data["pickUpRoom"] as? String ?? ""
                //DropOff Location
                let DropOffLatitude = data["DropOffLatitude"] as? Double ?? 0.0
                let DropOffLongitude = data["DropOffLongitude"] as? Double ?? 0.0
                let dropoff = CLLocationCoordinate2D(latitude: DropOffLatitude, longitude: DropOffLongitude)
                let dropoffBuilding = data["dropOffBulding"] as? Int ?? 0
                let dropoffFloor = data["dropOffFloor"] as? Int ?? 0
                let dropoffRoom = data["dropOffRoom"] as? String ?? ""
                let orderDetails = data["orderDetails"] as? String ?? ""
                //when converting to Bool we need to do this
                let assigned = (data["Assigned"] as? String ?? "" == "true" ? true : false)
                let MemberID = data["MemberID"] as? String ?? ""
                let state = data["Status"] as? String ?? ""
                let createdAt = data["CreatedAt"] as? Timestamp ?? Timestamp(date: Date())
                var deliveryPrice = 0
                var courierId = ""
                
                if assigned{ // if the order is assigned and both value are created in db
                    deliveryPrice = data["DeliveryPrice"] as? Int ?? 0
                    courierId = data["CourierID"] as? String ?? ""
                    print("\n\n !!!!!!!!!!!!!!!!!!!!!! pric \(deliveryPrice) \n\n")
                }
                
                
                print("order :\(uid) + \(pickup) + \(dropoff) + assigned: \(assigned)")
                print("in get order member current and date finc is \(createdAt.dateValue().calenderTimeSinceNow())")
                
                return OrderDetails(id: uid, pickUP: pickup, pickUpBulding: pickupBuilding, pickUpFloor: pickupFloor, pickUpRoom: pickupRoom, dropOff: dropoff, dropOffBulding: dropoffBuilding, dropOffFloor: dropoffFloor, dropOffRoom: dropoffRoom, orderDetails: orderDetails, memberId: MemberID,courierId: courierId, deliveryPrice: deliveryPrice, isAdded: assigned, createdAt: createdAt.dateValue(), status: state)
            })
        }
    }
    
    //T@@@@@@@@@@@@@@@@@@@@@@@ delete from collection offer
    //cancels an order based on order id and deletes all offers if any
    func cancelOrder(OrderId: String){
        print("\n*******CancelOrder*********")
        db.collection("Order").document(OrderId).setData([ "Status": status[1] ], merge: true)
            
        db.collection("Offers").whereField("OrderID", isEqualTo: OrderId).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents inside cancle order: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("inside cancelOrder: offerId:\(document.documentID) =>Data \(document.data())")
                    db.collection("Offers").document(document.documentID).delete() { err in
                        if let err = err {
                            print("Error removing offer inside cancelOrder: \(err)")
                        } else {
                            print("offer successfully delete inside cancelOrder!")
                        }
                    }//delete offer
                }//loop
            }
        }//get documents
     
    }
    
    //T@@@@@@@@@@@@@@@@@@@@@@@
    //function accept offer adds courier id and delivery price to order and deletes offer subcollection
    func acceptOffer(orderID: String, courierID: String, deliveryPrice: Double){
        db.collection("Order").document(orderID).setData([ "Status": status[3], "Assigned": "true", "CourierID": courierID, "DeliveryPrice": deliveryPrice], merge: true)
        db.collection("Offers").whereField("OrderID", isEqualTo: orderID).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents inside cancle order: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("inside cancelOrder: offerId:\(document.documentID) =>Data \(document.data())")
                    db.collection("Offers").document(document.documentID).delete() { err in
                        if let err = err {
                            print("Error removing offer inside cancelOrder: \(err)")
                        } else {
                            print("offer successfully delete inside cancelOrder!")
                        }
                    }//delete offer
                }//loop
            }
        }//get documents
        
    }
    
}



//Date extension to calculate time intervals
extension Date {
    
    func calenderTimeSinceNow() -> String
    {
        let calendar = Calendar.current
        
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self, to: Date())
        
        let years = components.year!
        let months = components.month!
        let days = components.day!
        let hours = components.hour!
        let minutes = components.minute!
        let seconds = components.second!
        
        if years > 0 {
            return years == 1 ? "1 year ago" : "\(years) years ago"
        } else if months > 0 {
            return months == 1 ? "1 month ago" : "\(months) months ago"
        } else if days >= 7 {
            let weeks = days / 7
            return weeks == 1 ? "1 week ago" : "\(weeks) weeks ago"
        } else if days > 0 {
            return days == 1 ? "1 day ago" : "\(days) days ago"
        } else if hours > 0 {
            return hours == 1 ? "1 hour ago" : "\(hours) hours ago"
        } else if minutes > 0 {
            return minutes == 1 ? "1 minute ago" : "\(minutes) minutes ago"
        } else {
            return seconds == 1 ? "1 second ago" : "\(seconds) seconds ago"
        }
    }
    
}


//For textfield chcaracter limit
class TextfieldManager: ObservableObject{
    @Published var text = ""{
        didSet{
            if text.count > charLimit && oldValue.count <= charLimit{
                text = oldValue
            }
        }
    }
    let charLimit: Int
    init(limit: Int = 5) {
        charLimit = limit
    }
}


//to calculate the dynamic hieght and width divide the UIScreen measurements on the result of the division of the hieght, width of 11pro on the postion sent -> num

//to get an image's width and height values if its not known use this
//width(num: UIImage(named: "")!.size.width )
//hieght(num: UIImage(named: "FastWayName")!.size.height)


func hieght(num: CGFloat) -> CGFloat {
    return UIScreen.main.bounds.height/(812/num)
}
func width(num: CGFloat) -> CGFloat {
    return UIScreen.main.bounds.width/(375/num)
}

//calculate dynamic font size according to 11 pro size
func fontSize(num: CGFloat) -> CGFloat{
    return UIScreen.main.bounds.height*(num/812)
}
