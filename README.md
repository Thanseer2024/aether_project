# project_aether

A new Flutter project.

## Firebase Scaling Strategy
1. **Message pagination with listener limits:** Instead of listening to an entire chat collection, use Firestore listeners on a limited window (e.g., last 50 messages) with pagination, and only load older messages on-demand when users scroll up—this prevents each player from triggering thousands of reads as new messages arrive.
2. **Client-side caching and batch reads strategically:** Cache recently loaded messages in memory/localStorage on the client, and batch user presence/typing status into a single document-per-channel rather than individual Firestore queries for each player's status.
3. **Implement message sharding by room/shard key and use collection groups with indexed queries:** Distribute chat data across sub-collections (e.g., chatRooms/{roomId}/messages/{shardId}) and query only the active shard for real-time updates, while using Firestore's composite indexes to keep queries efficient and predictable in cost, even with 10,000 concurrent players firing listeners simultaneously.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelabs)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
