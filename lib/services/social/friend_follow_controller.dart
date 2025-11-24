// lib/services/social/friend_follow_controller.dart
import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter_learning_app/services/social/social_api.dart';
import 'package:flutter_learning_app/services/services.dart'
    show FriendPrefs, ProfileCache;

class FriendFollowController extends ChangeNotifier {
  FriendFollowController({required this.api});

  final SocialApi api;

  final Set<String> _friends = <String>{};

  UnmodifiableSetView<String> get friends => UnmodifiableSetView(_friends);

  bool contains(String id) => _friends.contains(id);

  /// 啟動：先取後端；若後端為空→用本地回填；最後把有效名單寫回本地，並通知 UI
  Future<void> bootstrap() async {
    try {
      final server = await api.fetchMyFriends(); // 可能為空
      if (server.isEmpty) {
        // 本地 fallback
        var local = await ProfileCache.loadFriends();
        if (local.isEmpty) local = await FriendPrefs.load();
        _apply(local);
        if (_friends.isNotEmpty) {
          // 背景回填後端
          unawaited(api.updateProfile(followingUserIds: _friends.toList()));
        }
      } else {
        _apply(server.toSet());
      }
      await _persistLocal();
    } catch (_) {
      // 後端失敗也能用本地啟動
      var local = await ProfileCache.loadFriends();
      if (local.isEmpty) local = await FriendPrefs.load();
      _apply(local);
    }
    notifyListeners();
  }

  /// ✅ 改這裡：如果後端回傳空，且本地不空，就「相信本地」，不要蓋掉
  Future<void> refresh() async {
    try {
      final latest = (await api.fetchMyFriends()).toSet();

      // 後端還沒實作好 /me/friends 時，避免把本地清掉
      if (latest.isEmpty && _friends.isNotEmpty) {
        if (kDebugMode) {
          print(
            '[FriendFollowController] refresh: server empty, keep local '
            '(${_friends.length})',
          );
        }
        return;
      }

      _apply(latest);
      await _persistLocal();
      notifyListeners();
    } catch (_) {
      // 保持現況
    }
  }

  Future<void> add(String id) async {
    if (_friends.contains(id)) return;
    await api.followUser(id); // 後端 follow，一旦不 2xx 就會丟錯
    _friends.add(id);
    await _persistLocal();
    notifyListeners();

    // 🔥 先暫時關掉這行，避免「後端空」蓋掉本地
    // unawaited(refresh());
  }

  Future<void> remove(String id) async {
    if (!_friends.contains(id)) return;
    await api.unfollowUser(id);
    _friends.remove(id);
    await _persistLocal();
    notifyListeners();

    // 同上，先關掉
    // unawaited(refresh());
  }

  Future<void> toggle(String id) =>
      _friends.contains(id) ? remove(id) : add(id);

  // —— helpers —— //
  void _apply(Set<String> ids) {
    _friends
      ..clear()
      ..addAll(ids);
  }

  Future<void> _persistLocal() async {
    await ProfileCache.saveFriends(_friends);
    await FriendPrefs.saveAll(_friends);
  }
}
