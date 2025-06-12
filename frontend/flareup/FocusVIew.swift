import SwiftUI

struct FocusView: View {
    @StateObject private var viewModel = CountdownViewModel()
    @State private var path = NavigationPath()
    
    enum FocusDestination: Hashable {
        case friends
        case groups
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 5) {
                FlareupHeader {}
                
                // Countdown bar under header
                HStack {
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("next drop")
                            .font(.custom("Poppins-Regular", size: 18))
                            .foregroundColor(Color(hex: "F25D29"))
                        
                        HStack(spacing: 6) {
                            TimeBlockView(value: viewModel.days)
                            TimeBlockView(value: viewModel.hours)
                            TimeBlockView(value: viewModel.minutes)
                            TimeBlockView(value: viewModel.seconds)
                        }
                    }
                    .padding(.trailing)
                }
                .padding(.top, -90)
                .background(Color(hex: "FFF2E2"))
                .padding(.bottom, 8)
                
                Text("flares")
                    .font(.custom("Poppins-Bold", size: 40))
                    .foregroundColor(Color(hex: "F7941D"))
                    .padding(.top, -5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                ScrollView {
                    VStack(spacing: 30) {                        
                        // New Flares UI
                        VStack(spacing: 16) {
                            // Incoming flares card
                            NavigationLink(destination: IncomingFlaresView()) {
                                // full HStack UI here (as you've just done)
                                
                                HStack {
                                    Image("flare-orange")
                                        .resizable()
                                        .frame(width: 48, height: 48)
                                        .clipShape(Circle())
                                    
                                    VStack(alignment: .leading) {
                                        Text("incoming flares")
                                            .font(.custom("Poppins-Bold", size: 25))
                                            .foregroundColor(Color(hex: "F25D29"))
                                        
                                        Text("Abril + 1 others")
                                            .font(.custom("Poppins-Regular", size: 16))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.orange)
                                }
                                .padding()
                                .background(Color(hex: "FFF2E2"))
                                .cornerRadius(24)
                            }
                            
                            // View outgoing flares
                            NavigationLink(destination: OutgoingFlaresView()) {
                                HStack {
                                    Text("view outgoing flares")
                                        .font(.custom("Poppins-Bold", size: 25))
                                        .foregroundColor(Color(hex: "F25D29"))
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(Color(hex: "F25D29"))
                                }
                                .padding()
                                .background(Color(hex: "FFF2E2"))
                                .cornerRadius(24)
                            }
                            
                            // Send a flare
                            NavigationLink(destination: SendFlareView()) {
                                HStack {
                                    Image("flare-white")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                        .padding(.leading, 4)

                                    Text("send a flare")
                                        .font(.custom("Poppins-Bold", size: 25))
                                }
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(hex: "F25D29"))
                                .cornerRadius(24)
                            }
                        }
                        .padding(.horizontal)
                    }
                    VStack(spacing: 20){
                        VStack(spacing: 20) {
                            // Flares Summary Card
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("flares summary")
                                        .font(.custom("Poppins-Bold", size: 26))
                                        .foregroundColor(Color(hex: "F7941D"))
                                    Spacer()
                                    Text("May 2")
                                        .font(.custom("Poppins-Bold", size: 22))
                                        .foregroundColor(Color(hex: "F7941D"))
                                }
                                
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack(spacing: 6) {
                                        Text(" 53")
                                            .font(.custom("Poppins-Bold", size: 22))
                                            .foregroundColor(Color(hex: "F25D29"))
                                        Text(" flares sent out this week")
                                            .font(.custom("Poppins-Regular", size: 20))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    HStack(spacing: 6) {
                                        Text(" 78")
                                            .font(.custom("Poppins-Bold", size: 22))
                                            .foregroundColor(Color(hex: "F25D29"))
                                        Text(" flares received this week")
                                            .font(.custom("Poppins-Regular", size: 20))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    HStack(spacing: 10) {
                                        Image("daltonPic")
                                            .resizable()
                                            .frame(width: 36, height: 36)
                                            .clipShape(Circle())
                                        Text("Top sender: ")
                                            .font(.custom("Poppins-Regular", size: 18))
                                            .foregroundColor(Color(hex: "FF9411"))
                                        + Text("Dalton").font(.custom("Poppins-Bold", size: 18))
                                            .foregroundColor(Color(hex: "F67653"))
                                        Spacer()
                                        Text("x16").foregroundColor(.gray)
                                    }
                                    
                                    HStack(spacing: 10) {
                                        Image("abrilPic")
                                            .resizable()
                                            .frame(width: 36, height: 36)
                                            .clipShape(Circle())
                                        Text("Top recipient: ")
                                            .font(.custom("Poppins-Regular", size: 18))
                                            .foregroundColor(Color(hex: "FF9411"))
                                        + Text("Abril").font(.custom("Poppins-Bold", size: 18))
                                            .foregroundColor(Color(hex: "F67653"))
                                        Spacer()
                                        Text("x32").foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(radius: 2)
                            .padding(.horizontal)
                            
                        }
                    }
                }
            }
        }
        .navigationDestination(for: FocusDestination.self) { destination in
            switch destination {
            case .friends:
                AllFriendsView()
            case .groups:
                SocialView()
            }
        }
    }
}
    @ViewBuilder
func flareOption(title: String, icon: String) -> some View {
    HStack {
        Text(title)
            .font(.custom("Poppins-Regular", size: 16))
            .foregroundColor(.gray)
        Spacer()
        Image(systemName: icon)
            .foregroundColor(Color(hex: "F25D29"))
    }
}

@ViewBuilder
func navRow(title: String, action: @escaping () -> Void) -> some View {
    Button(action: action) {
        HStack {
            Text(title)
                .foregroundColor(Color(hex: "F7941D"))
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(hex: "FFF2E2"))
        .cornerRadius(12)
    }
}


#Preview {
    FocusView()
}
