//
//  WallpaperView.swift
//  PaperFlow
//
//  Created by Bexon Pak on 2024-06-25.
//

import SwiftUI

protocol WallpaperDelegate {
  func updateIllustFollow()
}

struct WallpaperView: View {
  @StateObject var viewModel: WallpaperViewModel
  @EnvironmentObject var globleVIewModel:  GlobalSettingsViewModel
  let menuBarHeight = NSApplication.shared.mainMenu?.menuBarHeight ?? 0
  let screenWidth = NSScreen.main?.frame.width ?? 800
  @State var columns : Int = 8
  @Namespace var animation
  
  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      StaggeredGrid(columns:columns, list: viewModel.images) { post in
        PostCard(post: post)
          .matchedGeometryEffect(id: post, in: animation)
      }
      .animation(.easeInOut, value: columns)
    }
    .padding(.top, menuBarHeight)
    .onAppear {
      columns = Int(screenWidth / 150)
      viewModel.addNotification()
      viewModel.globleVIewModel = globleVIewModel
      viewModel.getIllustFollow()
    }
  }
}

struct PostCard : View {
  var post : Post
  var body: some View{
    Image(nsImage: post.image)
      .resizable()
      .aspectRatio(contentMode: .fit)
      .frame(width: 150)
  }
}

struct StaggeredGrid<Content: View, T : Identifiable>: View where T: Hashable {
  // 它将从集合中返回每个对象来构建视图…
  var content: (T) -> Content
  var list : [T]
  // 列……
  var columns : Int
  // 属性
  var showsIndicators : Bool
  var spacing : CGFloat
  
  // 提供构造函数的闭包
  init(columns: Int, showsIndicators: Bool = false,spacing : CGFloat = 4, list:[T], @ViewBuilder content: @escaping(T)->Content){
    
    self.content = content
    self.list = list
    self.spacing = spacing
    self.showsIndicators = showsIndicators
    self.columns = columns
  }
  
  // 交错网格功能…
  func setUpList()->[[T]]{
    // 创建列的空子数组计数…
    var gridArray : [[T]] = Array(repeating: [], count: columns)
    // 用于Vstack导向视图的拆分数组…
    var currentIndex : Int = 0
    for object in list{
      gridArray[currentIndex].append(object)
      // increasing index count
      // and resetting fi overbounds the columns count...
      //增加索引计数
      //和重置fi越界列计数…
      if currentIndex == (columns - 1){
        currentIndex = 0
      }
      else{
        currentIndex += 1
      }
    }
    return gridArray
  }
  
  var body: some View {
    ScrollView(.vertical,showsIndicators: showsIndicators) {
      HStack(alignment:.top, spacing: 0){
        ForEach(setUpList(),id:\.self){ columnsData in
          // 优化使用LazyStack…
          LazyVStack(spacing:spacing){
            ForEach(columnsData){ object in
              content(object)
            }
          }
        }
      }
      .padding(0)
    }
    .padding(0)
  }
}
