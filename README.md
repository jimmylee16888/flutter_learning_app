# flutter_learning_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Modele 關聯圖

        ┌───────────┐
        │  CardItem │  人物主檔
        └─────┬─────┘
              │ title  (字串)
              │
   by_owner / idol
              │
       ┌──────▼──────┐
       │ MiniCardData│  小卡一張一張
       └─────────────┘


        CardItem.albumIds (List<String>)   SimpleAlbum.id (String)
                 ┌──────────────┐        ┌───────────────┐
                 │              ├────────►               │
                 │              │        │ SimpleAlbum   │  專輯
                 └──────────────┘        └───────┬───────┘
                                                 │ has many
                                                 │ tracks
                                                 │
                                           ┌─────▼─────┐
                                           │AlbumTrack │  歌曲
                                           └───────────┘


      ┌────────────┐        writes         ┌─────────────┐
      │ SocialUser │──────────────────────►│ SocialPost  │
      └────────────┘                       └──────┬──────┘
              ▲                                   │ has many
              │ writes                            │ comments
      ┌───────┴───────┐                           │
      │ SocialComment │◄──────────────────────────┘
      └───────────────┘


SocialPost.tags / text (字串)
         ↓                  ↓
      (對應 CardItem.title / stageName / group / SimpleAlbum.title etc.)


