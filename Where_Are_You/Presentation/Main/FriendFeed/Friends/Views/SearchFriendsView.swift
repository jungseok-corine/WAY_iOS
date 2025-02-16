//
//  FriendsView.swift
//  Where_Are_You
//
//  Created by juhee on 20.08.24.
//

import SwiftUI
import Kingfisher

struct SearchFriendsView: View {
    @StateObject private var viewModel: SearchFriendsViewModel = {
        let friendRepository = FriendRepository(friendService: FriendService())
        let getFriendUseCase = GetFriendUseCaseImpl(friendRepository: friendRepository)
        
        let memberRepository = MemberRepository(memberService: MemberService())
        let memberDetailsUseCase = MemberDetailsUseCaseImpl(memberRepository: memberRepository)
        
        let friendsViewModel = FriendsViewModel(getFriendUseCase: getFriendUseCase, memberDetailsUseCase: memberDetailsUseCase)
        
        return SearchFriendsViewModel(
            friendsViewModel: friendsViewModel,
            getFriendUseCase: getFriendUseCase)
    }()
    
    @Binding var selectedFriends: [Friend]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(viewModel.selectedList) { friend in
                        SelectedFriendsView(friend: friend, isOn: Binding(
                            get: { viewModel.isSelected(friend: friend) },
                            set: { _ in viewModel.removeFromSelection(friend: friend) }
                        ))
                    }
                }
            }
            .padding(.horizontal)
            
            SearchBarView(searchText: $viewModel.searchText, onClear: viewModel.clearSearch)
            
            FriendListView(
                viewModel: viewModel.friendsViewModel,
                showToggle: true,
                isSelected: { friend in
                    viewModel.isSelected(friend: friend)
                },
                onToggle: { friend in
                    viewModel.toggleSelection(for: friend)
                }
            )
            .padding(.horizontal, LayoutAdapter.shared.scale(value: 16))
            
            Button(action: {
                selectedFriends = viewModel.confirmSelection()
                dismiss()
            }, label: {
                Text("확인")
                    .frame(maxWidth: .infinity)
            })
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(Color(.brandColor))
            .padding(.horizontal)
            .environment(\.font, .pretendard(NotoSans: .regular, fontSize: 16))
            .onAppear {
                viewModel.friendsViewModel.getFriendsList()
            }
        }
    }
}

struct SelectedFriendsView: View {
    let friend: Friend
    @Binding var isOn: Bool
    
    var body: some View {
        ZStack {
            VStack {
//                Image(friend.profileImage)
                KFImage(URL(string: friend.profileImage))
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width * 0.12, height: UIScreen.main.bounds.width * 0.12)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                Text(friend.name)
                    .font(.caption)
                    .lineLimit(1)
            }
            Button(action: {
                isOn = false
            }, label: {
                ZStack {
                    Image(systemName: "circle.fill")
                        .foregroundColor(.white)
                        .opacity(0.8)
                        .shadow(radius: 10)
                    Image(systemName: "multiply")
                        .foregroundColor(.gray)
                }
            })
            .offset(x: 20, y: -28)
        }
        .padding(.top, 4)
    }
}

struct FriendCellWithToggle: View {
    let friend: Friend
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            KFImage(URL(string: friend.profileImage))
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width * 0.14, height: UIScreen.main.bounds.width * 0.14)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
            Text(friend.name)
                .font(Font(UIFont.pretendard(NotoSans: .regular, fontSize: 17)))
                .foregroundColor(Color(.black22))
                .padding(8)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(CheckboxToggleStyle())
        }
        .padding(.vertical, 6)
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    @Environment(\.isEnabled) var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }, label: {
            HStack {
                if configuration.isOn {
                    Image(systemName: "checkmark.circle.fill")
                        .imageScale(.large)
                        .foregroundStyle(Color(.brandColor))
                } else {
                    Image(systemName: "circle")
                        .imageScale(.large)
                        .foregroundStyle(.gray)
                }
                
                configuration.label
            }
        })
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var selectedFriends: [Friend] = []
        
        var body: some View {
            SearchFriendsView(selectedFriends: $selectedFriends)
        }
    }
    
    return PreviewWrapper()
}
