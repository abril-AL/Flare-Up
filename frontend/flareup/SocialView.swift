import SwiftUI


struct SocialView: View {
    @StateObject private var viewModel = CountdownViewModel()
    @EnvironmentObject var session: SessionViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                FlareupHeader {}
                
                // Countdown lives just under the header
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
                .padding(.top, -90) // pull upward to nest against the header
                .background(Color(hex: "FFF2E2")) // match header color
                .padding(.bottom, 8) // spacing before scrollView
                
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // Friends Section
                        HStack {
                            Text("friends")
                                .font(.custom("Poppins-Bold", size: 30))
                                .foregroundColor(Color(hex: "F7941D"))
                            Spacer()
                            NavigationLink(destination: AllFriendsView()) {
                                HStack(spacing: 4) {
                                    Text("see all")
                                    Image(systemName: "chevron.right")
                                }
                                .font(.custom("Poppins-Regular", size: 20))
                                .foregroundColor(Color(hex: "F7941D"))
                            }
                        }
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 30) {
                                ForEach(session.friends, id: \.id) { friend in
                                    VStack(spacing: 8) {
                                        Image(friend.imageName)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 90, height: 90)
                                            .clipShape(Circle())
                                            .overlay(
                                                Circle()
                                                    .stroke(Color(hex: "F7941D"), lineWidth: 2)
                                            )

                                        Text(friend.name.capitalized.lowercased())
                                            .font(.custom("Poppins-Regular", size: 14))
                                            .foregroundColor(Color(hex: "F7941D"))
                                    }
                                    .frame(width: 70)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Groups Section
                        HStack {
                            Text("groups")
                                .font(.custom("Poppins-Bold", size: 30))
                                .foregroundColor(Color(hex: "F7941D"))
                            
                            Spacer()
                        
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 16) {
                            ForEach(groupSampleData, id: \.id) { group in
                                NavigationLink(destination: GroupDetailView(group: group)) {
                                    HStack(spacing: 10) {
                                        HStack(spacing: -25) {
                                            ForEach(group.members.prefix(3), id: \.self) { member in
                                                Image(member)
                                                    .resizable()
                                                    .frame(width: 60, height: 60)
                                                    .clipShape(Circle())
                                                    .overlay(Circle().stroke(Color(hex: "F7941D"), lineWidth: 2))
                                            }
                                        }

                                        VStack(alignment: .leading) {
                                            Text(group.name)
                                                .font(.custom("Poppins-Bold", size: 22))
                                                .foregroundColor(Color(hex: "F7941D"))
                                            Text("\(group.members.count) Members")
                                                .font(.custom("Poppins-Regular", size: 17))
                                                .foregroundColor(.gray)
                                        }

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .frame(minHeight: 100)
                                    .background(Color(hex: "FFF5E9"))
                                    .cornerRadius(50)
                                    .padding(.horizontal)
                                }
                                .buttonStyle(PlainButtonStyle()) // optional: removes default blue highlight
                            
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
    }
}

struct GroupModel: Identifiable {
    let id = UUID()
    let name: String
    let members: [String] // image names
}

let groupSampleData = [
    GroupModel(name: "The Chuzz", members: ["abrilpic", "daltonPic", "richellePic"]),
    GroupModel(name: "HCI 4 Lyfe", members: ["emjunpic", "abrilpic", "profilePic"]),
    GroupModel(name: "CS188TAS", members: ["emjunpic", "olliePic", "hangerPic"])
]

#Preview {
    SocialView()
        .environmentObject(SessionViewModel.mock)
}

extension SessionViewModel {
    static var mock: SessionViewModel {
        let vm = SessionViewModel()
        vm.friends = [
            Friend(id: UUID(), rank: 2, name: "abril", username: "abrillchuzz", hours: 1, imageName: "abrilpic"),
            Friend(id: UUID(), rank: 3, name: "dalton", username: "uwu420", hours: 1, imageName: "daltonPic"),
            Friend(id: UUID(), rank: 4, name: "richelle", username: "greedyXOXO", hours: 1, imageName: "richellePic"),
            Friend(id: UUID(), rank: 5, name: "hanger", username: "coat_hanger", hours: 1, imageName: "hangerPic"),
            Friend(id: UUID(), rank: 6, name: "ollie", username: "opai", hours: 1, imageName: "olliePic"),
            Friend(id: UUID(), rank: 7, name: "emjun", username: "nice_XD", hours: 1, imageName: "emjunpic")
        ]
        return vm
    }
}
