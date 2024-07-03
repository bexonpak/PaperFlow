//
//  PerferencesView.swift
//  PaperFlow
//
//  Created by Bexon Pak on 2024-06-25.
//

import SwiftUI
import pixivswift

struct PerferencesView: View {
  @Environment(\.dismiss) var dismiss
  @EnvironmentObject var globalSettingsViewModel: GlobalSettingsViewModel
  @ObservedObject var viewModel: ContentViewModel
  @ObservedObject var wallpaperViewModel: WallpaperViewModel
  @State private var isActive = false
  
  var body: some View {
    HStack {
      VStack {
        if globalSettingsViewModel.token == nil {
          HStack {
            Text("User: ")
            Button {
              isActive = true
            } label: {
              Text("Login")
            }
          }
        } else {
          VStack(alignment: .leading) {
            Text("User: \(String(globalSettingsViewModel.token?.userID ?? 0))")
            Text("Access Token: \(globalSettingsViewModel.token?.accessToken ?? "")")
            Text("Refresh Token: \(globalSettingsViewModel.token?.refreshToken ?? "")")
            Button {
              globalSettingsViewModel.logout()
            } label: {
              Text("Log out")
            }
            
            HStack {
              Picker(selection: $viewModel.restrictSelection, label: Text("Illust follow restrict:")) {
                ForEach(viewModel.restrict.indices , id: \.self){ i in
                  Text(viewModel.restrict[i].rawValue)
                }
              }
            }
            Toggle(isOn: $viewModel.showR18) {
              Text("Show R18 & R18+ content")
            }
            .toggleStyle(.checkbox)
            
            Spacer()
            
            Button {
              viewModel.save {
                dismiss()
              }
            } label: {
              Text("Save")
            }
            .buttonStyle(.borderedProminent)
          }
        }
        Spacer()
      }
      Spacer()
    }
    .padding()
    .onAppear {
      viewModel.updateRestrictSelection(globalSettingsViewModel.getIllustFollowRestrict())
      viewModel.updateShowR18(globalSettingsViewModel.getShowR18())
      
    }
    .sheet(isPresented: $isActive) {
      VStack {
        LogginViewSwiftUI() { refreshToken in
          globalSettingsViewModel.setupRefreshToken(refreshToken)
        }.frame(width: 400, height: 600)
      }
    }
  }
}
