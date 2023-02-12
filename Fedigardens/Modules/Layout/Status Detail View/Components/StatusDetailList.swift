//
//  StatusDetailList.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 2/11/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import SwiftUI
import Alice
import Bunker

struct StatusDetailList: View {
    var status: Status
    @StateObject var viewModel: StatusDetailViewModel
    @Binding var displayUndisclosedContent: Bool

    var body: some View {
        ScrollViewReader { scrollProxy in
            switch viewModel.state {
            case .initial:
                List {
                    StatusView(status: MockData.status!)
                        .profileImageSize(48)
                        .reblogNoticePlacement(.aboveOriginalAuthor)
                        .showsDisclosedContent($displayUndisclosedContent)
                        .verifiedNoticePlacement(.underAuthorLabel)
                        .listRowInsets(.init(top: 12, leading: 16, bottom: 12, trailing: 16))
                    ProgressView()
                }
                .listStyle(.plain)
                .redacted(reason: .placeholder)
            case .loading:
                ProgressView()
                    .font(.largeTitle)
            case .loaded:
                List {
                    if let quote = viewModel.quote, let source = viewModel.quoteSource {
                        VStack(alignment: .leading) {
                            StatusDetailQuote(
                                displayUndisclosedContent: $displayUndisclosedContent,
                                status: status,
                                quote: quote,
                                source: source
                            )
                        }
                        .listRowBackground(Color.accentColor.opacity(0.1))
                    }
                    if let context = viewModel.context, context.ancestors.isNotEmpty == true {
                        if viewModel.expandAncestors {
                            StatusContextProvider(
                                viewModel: viewModel,
                                context: context,
                                displayMode: .ancestors
                            )
                        } else {
                            Button {
                                withAnimation {
                                    viewModel.expandAncestors.toggle()
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    withAnimation {
                                        scrollProxy.scrollTo(viewModel.status?.uuid, anchor: .top)
                                    }
                                }
                            } label: {
                                Label("status.prevcontext", systemImage: "ellipsis")
                            }
                        }
                    }
                    StatusView(status: status)
                        .profileImageSize(48)
                        .reblogNoticePlacement(.aboveOriginalAuthor)
                        .showsDisclosedContent($displayUndisclosedContent)
                        .verifiedNoticePlacement(.underAuthorLabel)
                        .listRowInsets(.init(top: 12, leading: 16, bottom: 12, trailing: 16))
                        .id(viewModel.status?.uuid)
                    if let context = viewModel.context {
                        StatusContextProvider(viewModel: viewModel, context: context)
                    }
                }
                .listStyle(.plain)
            case .errored(let reason):
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(.largeTitle, design: .rounded))
                        .foregroundColor(.secondary)
                    Text(reason)
                        .font(.title3)
                }
            }
        }
    }
}
