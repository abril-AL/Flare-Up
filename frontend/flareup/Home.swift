//
//  Home.swift
//  flareup
//
//  Created by Richelle Shim on 5/23/25.
//

import SwiftUI

struct FlareUpHomeScreen: View {
    var body: some View {
        VStack(spacing: 16) {
            HeaderComponent()
            StatsComponent()
            LatestDropComponent()
            Spacer()
        }
        .padding()
        .background(Color(UIColor.systemGray6))
    }
}

struct HeaderComponent: View {
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                Text("flareup")
                    .font(.title)
                    .bold()
                    .foregroundColor(.orange)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text("next drop")
                    .font(.subheadline)
                    .foregroundColor(.orange)
                HStack(spacing: 4) {
                    ForEach(["01", "07", "03", "22"], id: \ .self) { segment in
                        Text(segment)
                            .padding(4)
                            .background(Color.orange.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
            }
        }
    }
}

struct StatsComponent: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your Stats")
                .font(.headline)
                .foregroundColor(.orange)
            Text("You currently have ") + Text("3").foregroundColor(.red) + Text(" hours left before you reach your daily screen time limit.")
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.orange.opacity(0.2))
                    .frame(height: 30)
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.orange)
                    .frame(width: 150, height: 30) // Assume partial fill
            }
            Text("You are currently on a ") + Text("42").foregroundColor(.red) + Text(" day streak in reaching your screen time goal!")
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 1)
    }
}

struct LatestDropComponent: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Latest Drop")
                    .font(.headline)
                    .foregroundColor(.orange)
                Spacer()
                Text("May 2")
                    .font(.headline)
                    .foregroundColor(.orange)
            }
            Text("You were on your phone for ") + Text("12 Hours").foregroundColor(.red) + Text(" last week!")
            HStack {
                Text("23%")
                    .foregroundColor(.green)
                    .bold()
                Text(" decrease from the previous drop!")
            }
            HStack {
                Text("1.57x")
                    .foregroundColor(.green)
                    .bold()
                Text(" lower than your friends!")
            }
            HStack {
                Image(systemName: "flame")
                    .padding(8)
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(8)
                Text("flareup ") + Text("was your most used app at ") + Text("3.2 hours!").foregroundColor(.orange)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 1)
    }
}

struct FlareUpHomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        FlareUpHomeScreen()
    }
}


