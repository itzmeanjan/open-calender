> **Warning**

**I'm stopping maintenance of this project !**

# open-calender
Open, transparent, immutable meeting scheduling platform, made with :heart:

## motivation

As we all know, blokchain can be used for building new generation open, transparent, censorship resistant application(s) where security & immutability is important, which is why I thought of making a dApp on top of ethereum platform _( or anyother platform where smart contracts, targetting EVM, can be deployed )_, which can help people schedule meetings. 

Lets take an example. Assume **A** wants to schedule a meeting with **B**, where all available meeting slots of **B** can be seen by anyone. Now **A**, simply requests **B** for scheduling a meeting one of those available time slots. **B** gets a notification from dApp and confirms the meeting. If later any part want to cancel, reschedule meeting, both of them needs to given nod to that change. If one certain meeting slot is booked, another user **C** needs to find one meeting slot from remaining ones. Yeah, that's it. Pretty simple huh ? :nerd_face:

That's what `open-calender` aims to attain.

## work progress

- Currently I'm writing smart contracts.

## usage

- Any person or any company can use this platform, for scheduling meetings with another peer, from available time slots, offered by peer.
- Being built on top of blockchain, it'll be immutable i.e. all records to be immutably, which can be used in later time,if someone tries to non-repudiate.
- I'll creating a simple webUI which can be used by anyone having a standard web browser _( and having metamask installed )_.
- No explicit account creation required, user's ethreum account address to be used as unique identifier.
