// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGADesignToken
import SwiftUI

public typealias MEGAListPreview = MEGAList<
    MEGAListTextContentView,
    EmptyView,
    EmptyView,
    EmptyView,
    EmptyView
>

public extension MEGAListPreview {
    init() {
        self.init(
            title: "List",
            subtitle: String.loremIpsum(20)
        )
    }
}

public extension String {
    static func loremIpsum(_ numberOfWords: Int) -> String {
        let loremIpsum = """
        Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do
        eiusmod tempor incididunt ut labore et dolore magna aliqua.
        Tortor at auctor urna nunc. Ornare quam viverra orci sagittis eu.
        Eget dolor morbi non arcu risus quis. Mauris pharetra et ultrices
        neque ornare aenean euismod elementum nisi. Varius vel pharetra vel
        turpis. Urna et pharetra pharetra massa massa. Nullam non nisi est sit.
        Aliquam sem et tortor consequat id porta. Interdum posuere lorem ipsum
        dolor. Consequat interdum varius sit amet mattis vulputate. Pulvinar
        etiam non quam lacus suspendisse faucibus. Sed tempus urna et pharetra
        pharetra massa massa. Pulvinar pellentesque habitant morbi tristique
        senectus et netus et. Sem nulla pharetra diam sit amet nisl.

        Ultricies lacus sed turpis tincidunt id aliquet risus feugiat. Interdum
        velit euismod in pellentesque massa placerat. Ut venenatis tellus in
        metus. Sollicitudin tempor id eu nisl nunc. Vitae proin sagittis nisl
        rhoncus mattis rhoncus urna neque. Vitae nunc sed velit dignissim sodales
        ut eu sem. Suspendisse interdum consectetur libero id faucibus nisl.
        Malesuada bibendum arcu vitae elementum curabitur. Auctor urna nunc id
        cursus metus aliquam. Dolor magna eget est lorem. Quis auctor elit sed
        vulputate mi sit. Sapien pellentesque habitant morbi tristique senectus
        et netus et. Facilisis gravida neque convallis a cras semper.

        Sit amet purus gravida quis blandit turpis. In pellentesque massa placerat
        duis ultricies lacus. Netus et malesuada fames ac turpis egestas maecenas
        pharetra. In est ante in nibh. Amet luctus venenatis lectus magna fringilla
        urna. Risus pretium quam vulputate dignissim suspendisse in est ante in.
        Massa tincidunt nunc pulvinar sapien. Quis vel eros donec ac odio tempor
        orci dapibus. Egestas pretium aenean pharetra magna ac placerat vestibulum
        lectus mauris. Interdum velit laoreet id donec ultrices tincidunt arcu non
        sodales. Non sodales neque sodales ut etiam sit amet. Venenatis urna cursus
        eget nunc scelerisque viverra mauris in aliquam.
        """

        return loremIpsum
            .components(separatedBy: .whitespacesAndNewlines)
            .prefix(numberOfWords)
            .joined(separator: " ")
    }
}

#Preview {
    List {
        Group {
            MEGAListPreview()
            MEGAListPreview()
            MEGAListPreview()
            MEGAListPreview()
        }
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
    .listStyle(GroupedListStyle())
}
