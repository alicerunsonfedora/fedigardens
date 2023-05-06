//
//  PollVotingView.swift
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

import Alice
import SwiftUI

struct PollVotingView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = PollVotingViewModel()
    var poll: Poll

    var body: some View {
        NavigationStack {
            Form {
                Picker("", selection: $viewModel.currentVote) {
                    ForEach(0 ..< poll.options.count, id: \.self) { index in
                        Text(poll.options[index].title).tag(index)
                    }
                }
                .pickerStyle(.inline)

                if viewModel.expirationIsNear(difference: 300), let expiry = viewModel.pollExpirationDate() {
                    Label {
                        VStack(alignment: .leading) {
                            Text("status.poll.expirytitle")
                                .font(.headline)
                            Text(
                                String(
                                    format: "status.poll.expirydetail".localized(),
                                    expiry
                                )
                            )
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        }
                    } icon: {
                        Image(systemName: "clock")
                            .font(.headline)
                    }
                }
            }
            .navigationTitle("status.poll.votetitle")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.poll = poll
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            await viewModel.submit { _ in
                                dismiss()
                            }
                        }
                    } label: {
                        Text("status.poll.voteaction")
                    }
                    .keyboardShortcut(.defaultAction)
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel, action: dismiss.callAsFunction) {
                        Text("general.cancel")
                    }
                    .keyboardShortcut(.cancelAction)
                }
            }
        }
    }
}

struct PollVotingView_Previews: PreviewProvider {
    static var previews: some View {
        PollVotingView(poll: MockData.poll!)
    }
}
