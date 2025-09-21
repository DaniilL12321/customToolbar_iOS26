//
//  ContentView.swift
//  testApp
//
//  Created by Daniil on 9/19/25.
//

import SwiftUI

struct ContentView: View {
    @State private var path: NavigationPath = .init()
    @State private var searchText: String = ""
    @FocusState private var isKeyboardActive: Bool
    var body: some View {
        NavigationStack(path: $path) {
            List {
                ForEach(1...50, id: \.self) { index in
                    NavigationLink(value: "link") {
                        Text("link \(index)")
                    }
                }
            }
            .navigationTitle("title")
            .navigationSubtitle("subtitle")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("options", systemImage: "ellipsis") {
                        
                    }
                }
            }
            .safeAreaPadding(.bottom, 50)
            .navigationDestination(for: String.self) { value in
                Text("full view")
                    .navigationTitle(value)
            }
        }
        .safeAreaBar(edge: .bottom, spacing: 0) {
            CustomBottomBar(path: $path, searchText: $searchText, isKeyboardActive:
                $isKeyboardActive) { isExpanded in

                Group {
                    ZStack {
                        Image(systemName: "line.3.horizontal.decrease")
                            .BlurFade(!isExpanded)
                        Image(systemName: "trash")
                            .BlurFade(isExpanded)
                    }
                    
                    Group {
                        Image(systemName: "folder")
                        
                        Image(systemName: "arrowshape.turn.up.forward.fill")
                    }
                    .BlurFade(isExpanded)
                }
                .font(.title2)
            } mainAction: {
                Image(systemName: isKeyboardActive ? "xmark" : "square.and.pencil")
                    .font(.title2)
                    .contentTransition(.symbolEffect)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(.circle)
                    .onTapGesture {
                        if isKeyboardActive {
                            isKeyboardActive = false
                        } else {
                            print("write")
                        }
                }
            }
        }
    }
}

struct CustomBottomBar<LeadingContent: View, MainAction: View>: View {
    @Binding var path: NavigationPath
    @Binding var searchText: String
    var isKeyboardActive: FocusState<Bool>.Binding
    @ViewBuilder var leadingContent: (_ isExpanded: Bool) -> LeadingContent
    @ViewBuilder var mainAction: MainAction
    @State private var bounce: CGFloat = 0
    var body: some View {
        HStack(spacing: 10) {
            if !isKeyboardActive.wrappedValue {
                Circle()
                    .foregroundStyle(.clear)
                    .frame(width: 50, height: 50)
                    .overlay(alignment: .leading) {
                        let layout = isExpanded ? AnyLayout(HStackLayout(spacing: 10)) :
                        AnyLayout(ZStackLayout())
                        
                        layout {
                            ForEach(subviews: leadingContent(isExpanded)) { subview in
                                subview
                                    .frame(width: 50, height: 50)
                            }
                        }
                        .modifier(ScaleModifier(bounce: bounce))
                    }
                    .zIndex(1000)
                    .transition(.blurReplace)
            }
            
            GeometryReader {
                let size = $0.size
                let scale = 50 / size.width
                
                HStack(spacing: 8) {
                    Image(systemName: "magnifyinglass")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    TextField("search", text: $searchText)
                        .submitLabel(.search)
                        .focused(isKeyboardActive)
                    Image(systemName: "mic.fill")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 15)
                .frame(width: size.width, height: size.height)
                .glassEffect(.regular.interactive(), in: .capsule)
                .BlurFade(!isExpanded)
                .scaleEffect(isExpanded ? scale : 1, anchor: .leading)
                .offset(x: isExpanded ? -50 : 0)
            }
            .frame(height: 50)
            .padding(.leading, isKeyboardActive.wrappedValue ? -60 : 0)
            .disabled(isExpanded)
            
            mainAction
                .frame(width: 50, height: 50)
                .glassEffect(.regular.interactive(), in: .circle)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, isKeyboardActive.wrappedValue ? 15 : 0)
        .animation(.smooth(duration: 0.3, extraBounce: 0), value: isKeyboardActive.wrappedValue)
        .animation(.bouncy, value: isExpanded)
        .onChange(of: isExpanded) { oldValue, newValue in
            withAnimation(.bouncy) {
                bounce += 1
            }
        }
    }
    
    var isExpanded: Bool {
        !path.isEmpty
    }
}

extension View {
    @ViewBuilder
    func BlurFade(_ status: Bool) -> some View {
        self.blur(radius: status ? 0 : 5)
            .opacity(status ? 1 : 0)
    }
}

struct ScaleModifier: ViewModifier, Animatable {
    var bounce: CGFloat
    var animatableData: CGFloat {
        get { bounce }
        set {bounce = newValue}
    }
    
    func body(content: Content) -> some View {
        content
            .compositingGroup()
            .blur(radius: loopProgress * 5)
            .glassEffect(.regular.interactive(), in: .capsule)
            .scaleEffect(1 + (loopProgress * 0.38), anchor: .center)
    }
    
    var loopProgress: CGFloat {
        let moddedBounce = bounce.truncatingRemainder(dividingBy: 1)
        let value = moddedBounce > 0.5 ? 1 - moddedBounce : moddedBounce
        return value * 2
    }
}

#Preview {
    ContentView()
}
