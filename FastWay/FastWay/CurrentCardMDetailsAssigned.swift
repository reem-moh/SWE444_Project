//
//  CurrentCardMDetailsAssigned.swift
//  FastWay
//
//  Created by Reem on 19/03/2021.
//

import SwiftUI
import MapKit
import CoreLocation
//////member
//Current card M details assigned

struct CurrentCardMDetailsAssigned: View {
    @EnvironmentObject var model : CurrentCarouselMViewModel
    @StateObject var viewRouter: ViewRouter
    var animation: Namespace.ID
    @State var map = MKMapView()
    @State var manager = CLLocationManager()
    @State var alert = false
    @State var distance = ""
    @State var time = ""
    @State var courierLocationtracking  = ""
   // var courierLocation = riyadhCoordinatetracking
    @State var courierLocation : CLLocationCoordinate2D! = riyadhCoordinatetracking
    @State private var CancelOrder = false
    @State var CancelButtonShow = true
    @State var stat = ""
    //For chat
    @State var show = false
    @State var chat = false
    @State var oneDouble = 0.0
    @State var tDouble = 0.0
   // var courierLocation = riyadhCoordinatetracking
    //for status
    @State var showAssign = false
    @State var showPickUp = false
    @State var showOnTheWay = false
    @State var showDropOff = false
    @State var showComplete = false

    var body: some View{

        ZStack{
           
            

          //  courierLocation
            //map
            MapViewTracking(map: self.$map, manager: self.$manager, alert: self.$alert, source: self.$model.selectedCard.orderD.pickUP, destination: self.$model.selectedCard.orderD.dropOff, courierLocation:  self.$courierLocation , distance: self.$distance, time: self.$time , orderid: self.$model.order , orderID : self.$model.selectedCard.orderD.id )
                .cornerRadius(35)
                .frame(width: width(num:390), height: hieght(num:300))
                .padding(.bottom, hieght(num:0))
                .clipped()
                .position(x: width(num:188),y: hieght(num:100))
                .offset(y: hieght(num:50))
                .onAppear(){
                    self.manager.requestAlwaysAuthorization()
                    model.order.getCourierLocation(orderId: model.selectedCard.orderD.id)

                }
                .onChange(of: model.order.traking.courierLocation.longitude) { value in
                   // courierLocation = Float(courierLocation.longitude)
                     oneDouble = Double(model.order.traking.courierLocation.longitude)
                    self.oneDouble = value
                    tDouble = Double(model.order.traking.courierLocation.latitude)
                   self.tDouble = value
                    //self.model.getCourierLocation
                    model.order.getCourierLocation(orderId: model.selectedCard.orderD.id)
                }
                /*.onAppear {
                    
                   self.manager.requestAlwaysAuthorization()
                }
                .onChange(of: model.selectedCard.orderD.courierLocation, perform: { value in
             if value {
                 if notificationT == .CancelOffer  {
                     animateAndDelayWithSeconds(0.05) {
                         self.imgName = "cancelTick"
                         self.show = true }
                     animateAndDelayWithSeconds(4) {
                         self.show = false
                         model.notificationMSG = false
                         notificationT = .None
                     }
                 }
             }
         }
           */
            
            ZStack {
                //back button
                Group{
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: width(num:45), height:hieght(num: 35))
                        .foregroundColor(Color(.white))
                    Button(action: {
                        withAnimation(.spring()){
                            model.showCard.toggle()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation(.easeIn){
                                    model.showContent = false
                                    
                                }
                            }
                            
                        }
                    }) {
                        Image("arrow_back")
                            .resizable()
                            .colorInvert()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: width(num:30), height: hieght(num:30))
                            .clipped()
                            .background(Color(.white))
                    }.padding(1.0)
                }.position(x: width(num:50), y: hieght(num:50))
                //white background
                Image(uiImage: #imageLiteral(resourceName: "Rectangle 48"))
                    .resizable() //add resizable
                    .frame(width: width(num: 375)) //addframe
                    .edgesIgnoringSafeArea(.bottom)
                    .offset(y:hieght(num:  240))
                    .onAppear(){
                        self.stat = model.selectedCard.orderD.status
                    }
                    .onChange(of: model.selectedCard.orderD.status) { value in
                        self.stat = value
                    }
                //Details
                VStack{
                    
                    ScrollView{
                        //Time
                        HStack{
                            Image(systemName: "clock")
                                .foregroundColor(Color.black.opacity(0.5))
                                .offset(x: width(num:10), y: hieght(num:10))
                                .padding(.leading)
                            Text("\(model.selectedCard.orderD.createdAt.calenderTimeSinceNow())")
                                .font(.body)
                                .fontWeight(.regular)
                                .foregroundColor(Color.black.opacity(0.5))
                                .animation(.easeIn)
                                .offset(x: width(num:10), y: hieght(num:10))
                            Spacer(minLength: 0)
                        }
                        //Status
                        ZStack{
                            //white background
                            RoundedRectangle(cornerRadius: 15)
                                .padding()
                                .frame(width: width(num:350), height: hieght(num:320))
                                .foregroundColor(.white)
                                .shadow(radius: 1)
                            //status of the order
                            VStack{
                                Spacer()
                                Group{
                                    HStack{
                                        showAssign || showPickUp || showOnTheWay || showDropOff||showComplete ? Image(uiImage: #imageLiteral(resourceName: "IMG_0528 1")) : Image(uiImage: #imageLiteral(resourceName: "dollar"))
                                        Text("Order assigned to a courier").multilineTextAlignment(.leading).frame(minWidth: 0, maxWidth: width(num:230), alignment: .leading)
                                    }
                                    Spacer()
                                    HStack{
                                        showPickUp || showOnTheWay||showDropOff||showComplete ? Image(uiImage: #imageLiteral(resourceName: "IMG_0528 1")): Image(uiImage: #imageLiteral(resourceName: "dollar"))
                                        Text("Arrived at pick up location").multilineTextAlignment(.leading).frame(minWidth: 0, maxWidth: width(num:230), alignment: .leading)
                                    }
                                    Spacer()
                                    HStack{
                                        showOnTheWay || showDropOff||showComplete ? Image(uiImage: #imageLiteral(resourceName: "IMG_0528 1")): Image(uiImage: #imageLiteral(resourceName: "dollar"))
                                        Text("Order picked up and on the way").multilineTextAlignment(.leading).frame(minWidth: 0, maxWidth: width(num:230), alignment: .leading)
                                    }
                                    Spacer()
                                }
                                
                                Group{
                                    HStack{
                                        showDropOff||showComplete ? Image(uiImage: #imageLiteral(resourceName: "IMG_0528 1")): Image(uiImage: #imageLiteral(resourceName: "dollar"))
                                        Text("arrived at drop of location").multilineTextAlignment(.leading).frame(minWidth: 0, maxWidth: width(num:230), alignment: .leading)
                                    }
                                    Spacer()
                                    HStack{
                                        showComplete ? Image(uiImage: #imageLiteral(resourceName: "IMG_0528 1")): Image(uiImage: #imageLiteral(resourceName: "dollar"))
                                        Text("Order delivered").multilineTextAlignment(.leading).frame(minWidth: 0, maxWidth: width(num:230), alignment: .leading)
                                    }
                                    Spacer()
                                }
                            }
                        }.onAppear(){
                            switch model.selectedCard.orderD.status {
                                case "assigned" : showAssign.toggle()
                                case "pick Up" : showPickUp.toggle()
                                case "on The Way" : showOnTheWay.toggle()
                                case "drop off": showDropOff.toggle()
                                case "completed": showComplete.toggle()
                                default: print("inside switch statement")
                            }
                        }
                        
                        //pick up
                        ZStack{
                            RoundedRectangle(cornerRadius: 15)
                                .padding()
                                .frame(width: width(num:350), height: hieght(num:160))
                                .foregroundColor(.white)
                                .shadow(radius: 1)
                            Image(uiImage: #imageLiteral(resourceName: "IMG_0528 1"))
                                .offset(x: width(num:-125))
                            HStack {
                                
                                Text("Building \(self.getBuilding(id: model.selectedCard.orderD.pickUpBulding)), \nfloor \(model.selectedCard.orderD.pickUpFloor),  \(model.selectedCard.orderD.pickUpRoom)").multilineTextAlignment(.leading).frame(minWidth: 0, maxWidth: width(num:200), alignment: .leading)
                            }
                            
                        }
                        //drop off
                        ZStack{
                            RoundedRectangle(cornerRadius: 15)
                                .padding()
                                .frame(width: width(num:350), height: hieght(num:160))
                                .foregroundColor(.white)
                                .shadow(radius: 1)
                            Image(uiImage: #imageLiteral(resourceName: "IMG_0528 copy 3"))
                                .offset(x: width(num:-125))
                            HStack{
                                
                                Text("Building \(self.getBuilding(id: model.selectedCard.orderD.dropOffBulding)), \nfloor \(model.selectedCard.orderD.dropOffFloor),  \(model.selectedCard.orderD.dropOffRoom)").multilineTextAlignment(.leading).frame(minWidth: 0, maxWidth: width(num:200), alignment: .leading)
                            }
                            
                        }
                        //order items
                        ZStack(alignment: .top){
            
                            Image(uiImage: #imageLiteral(resourceName: "IMG_0528 copy 2 1")).offset(x: width(num:-130))
                            
                            HStack() {
                                Text("\(model.selectedCard.orderD.orderDetails)").multilineTextAlignment(.leading).frame(minWidth: 0, maxWidth: width(num:220), alignment: .leading)
                                    .padding(.vertical, 4)
                            }
                            
                        }.contentShape(RoundedRectangle(cornerRadius: 15))
                        .frame(width: width(num:325))
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(radius: 1)
                        //.padding(.bottom, CancelButtonShow ? hieght(num:4) : hieght(num:450))
                        //order price:
                        ZStack(alignment: .top){
                            if model.selectedCard.orderD.status == order.status[3]{
                                Image(uiImage: #imageLiteral(resourceName: "dollar")).offset(x: width(num:-130), y: hieght(num: 4))
                                //here Price
                                HStack() {
                                    Text("\(model.selectedCard.orderD.deliveryPrice)").multilineTextAlignment(.leading).frame(minWidth: 0, maxWidth: width(num:220), alignment: .leading)
                                        .padding(.vertical, 6)
                                }
                            }
                            
                        }
                        .contentShape(RoundedRectangle(cornerRadius: 15))
                        .frame(width: width(num:325))
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(radius: 1)
                        .padding(.top, hieght(num: 10))
                        .padding(.bottom, CancelButtonShow ? hieght(num:4) : hieght(num:450))
                        //CancelButton
                        HStack {
                            if CancelButtonShow {
                                Spacer(minLength: 0)
                            //Cancel button
                             Button(action: {
                                CancelOrder.toggle()
                            }) {
                                Text("Cancel Order")
                                    .font(.custom("Roboto Bold", size: fontSize(num:22)))
                                    .foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                                    .multilineTextAlignment(.center)
                                    .padding(1.0)
                                    .frame(width: UIScreen.main.bounds.width - 50)
                                    .textCase(.none)
                            }
                             .background(
                                Image(uiImage: #imageLiteral(resourceName: "LogInFeild"))
                                    .resizable()
                                    .frame(width: UIScreen.main.bounds.width - 84, height: hieght(num: 50)))
                            .padding(.top,hieght(num:25))
                            .offset(x: width(num:0))
                            .padding(.bottom,hieght(num:450))
                            /*.onTapGesture {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    withAnimation(.easeIn){
                                        
                                    }//end with animation
                                }
                            }*/
                        }
                        }
                    }
                }.position(x: width(num:188),y: hieght(num:700))
                //Chat
                Group{
                    //RoundedRectangle(cornerRadius: 15)
                    // .frame(width: width(num:45), height:hieght(num: 45))
                    //.foregroundColor(Color(.lightGray))
                    
                    Button(action: {
                        model.showChat.toggle()
                        
                   }) {
                        ZStack{
                            Circle()
                            .frame(width: width(num:60), height:hieght(num: 60))
                                .foregroundColor(Color(.white))
                                .shadow(radius: 1)
                            Image(systemName: "message.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: width(num:50), height: hieght(num:50))
                                .foregroundColor(Color("ButtonColor"))
                                //.clipped()
                        }
                       
                           //.background(Color(.white))
                   }.padding(1.0)
               }.position(x: width(num:35), y: hieght(num:650))


                
            }
            
            
        }.edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
        .alert(isPresented: $CancelOrder) {
            Alert(
                title: Text("Order confirmed"),
                message: Text("Are you sure you want cancel this order"),
                primaryButton: .default((Text("Yes")), action: {
                    model.cancelOrder(Id: model.selectedCard.orderD.id)
                    notificationT = .CancelOrder
                    model.notificationMSG = true
                    //viewRouter.currentPage = .CurrentOrder
                    model.showCard = false
                    model.showContent = false
                }) ,
                secondaryButton: .cancel((Text("No")))
            )}//end alert
        .onAppear(){
            //assigned
            if model.selectedCard.orderD.status == order.status[3]{
            CancelButtonShow = true
             let timeInterval = Int( -1 * model.selectedCard.orderD.createdAt.timeIntervalSinceNow)
                //60 * (60+30)
                print("timeInterval: \(timeInterval)")
                if timeInterval >= 5400 {
                    self.CancelButtonShow.toggle()
                    CancelButtonShow = true
                }else {
                    CancelButtonShow = false
                }
            }

        }
        
        
    }// end body
    
    //name of building
    func getBuilding(id: Int) -> String {
        var building = ""
        switch id {
        case 5:
            building = "no.5 College Of Sciences"
        case 6:
            building = "no.6 College Of Computer and Information Sciences"
        case 8:
            building = "no.8 College Of Pharmacy"
        case 9:
            building = "no.9 College Of Medicine"
        case 10:
            building = "no.10 College Of Dentistry"
        case 11:
            building = "no.11 College Of Applied Medical Science"
        case 2:
            building = "no.12 College Of Education"
        case 13:
            building = "no.13 College Of Arts"
        case 4:
            building = "no.14 College Of Languages And Translation"
        case 3:
            building = "no.15 College Of Business Administration"
        case 16:
            building = "no.16 College of Sports Sciences and Physical Activity"
        case 7:
            building = "no.17 College of Law and Political Sciences"
        default:
            building = ""
        }
        return building
    }
}
