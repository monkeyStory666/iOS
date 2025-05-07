// Copyright © 2024 MEGA Limited. All rights reserved.

import SwiftUI

#Preview {
    struct MEGABottomSheetExample: View {
        @State var isPresented: Bool = false
        
        var body: some View {
            Button("Show Bottom Sheet") {
                isPresented.toggle()
            }
            .bottomSheet(
                isPresented: $isPresented,
                detents: [.fixed(300), .medium],
                showDragIndicator: true,
                cornerRadius: 16
            ) {
                listExample
            }
        }
        
        var listExample: some View {
            List {
                Section("Preview") {
                    Text("Preview 1")
                    Text("Preview 2")
                    Text("Preview 3")
                }
                
                Section("Configuration") {
                    Text("Configuration 1")
                    Text("Configuration 2")
                    Text("Configuration 3")
                    Text("Configuration 4")
                    Text("Configuration 5")
                }
            }
            .listStyle(GroupedListStyle())
        }
    }
    
    return MEGABottomSheetExample()
}
