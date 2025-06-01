//
//  SplashView.swift
//  flareup
//
//  Created by Richelle Shim on 5/16/25.
//


import SwiftUI

struct SplashView: View {
  private let displayTime: TimeInterval = 1.5

  @Binding var isActive: Bool

  var body: some View {
    ZStack {
      Color("BrandOrange")
        .ignoresSafeArea()

      VStack(spacing: 24) {
          
        Image("flareUpName")
              .resizable()
              .scaledToFit()
              .frame(width: 206, height: 62)
        Image("flareUpLogo")
          .resizable()
          .scaledToFit()
          .frame(width: 224, height: 200)
      }
    }
    .onAppear {
      DispatchQueue.main.asyncAfter(deadline: .now() + displayTime) {
        withAnimation(.easeOut(duration: 0.4)) {
          isActive = true
        }
      }
    }
  }
}


#Preview {
  SplashView(isActive: .constant(false))
}