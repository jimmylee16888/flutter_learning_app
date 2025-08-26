// // 沒東西要更新 StatelessWidget => 這樣寫可以降低系統消耗(不用一直想著要修改)
// // 有東西要更新 StatefullWidget
// class HomePage extends StatelessWidget {
//   // build 被呼叫 UI 畫出來
//   @override
//   Widget build(BuildContext context) {
//     //葉面的Widge，提供接入的 parameters
//     return Scaffold(
//       //上方AppBar標題
//       appBar: new AppBar(title: Text('MyApp Demo')),
//       //中間主要內容
//       // Row 橫向排列
//       // column 縱向排列
//       body: Row(
//         children: [
//           Container(
//             color: Colors.red,
//             width: 100,
//             height: 100,
//             margin: EdgeInsets.only(left: 10),
//           ),
//           Container(color: Colors.green, width: 100, height: 100),
//           Container(color: Colors.blue, width: 100, height: 100),
//         ],
//       ),
//     );
//   }
// }

// // 有東西要更新 StatefullWidget
// class HomePage2 extends StatefulWidget {
//   // createState() 必須回傳一個 State 類別的實例 => 不能直接「接內容」在後面
//   // 這個 State 物件會被 Flutter 框架保存，用來管理「狀態」和「生命週期」
//   @override
//   State<StatefulWidget> createState() => HomePage2State();
// }

// //真正實體邏輯存在state => 因為Widge會被刷新，無法儲存邏輯
// class HomePage2State extends State<HomePage2> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       floatingActionButton: FloatingActionButton(
//         child: Icon(Icons.forward),
//         onPressed: () {
//           //透過setState告訴state要刷新資料
//           setState(() {});
//         },
//       ),
//       //上方AppBar標題
//       appBar: new AppBar(title: Text('MyApp Demo')),
//       //中間主要內容
//       // Row 橫向排列
//       // column 縱向排列
//       body: Column(
//         children: [
//           Row(
//             children: [
//               Container(
//                 color: getColor(),
//                 width: 100,
//                 height: 100,
//                 margin: EdgeInsets.only(left: 10),
//               ),
//               Container(color: getColor(), width: 100, height: 100),
//               Container(color: getColor(), width: 100, height: 100),
//             ],
//           ),
//           Text(
//             'Demo',
//             style: TextStyle(
//               fontSize: 20.0, //大小
//               fontWeight: FontWeight.w600, // 粗體
//               color: Colors.deepPurple, // 顏色
//               fontStyle: FontStyle.italic, //斜體
//             ),
//           ),

//           // Expanded自動填充剩餘空間
//           // Expanded(child: Container(color: Colors.greenAccent)),

//           //container 隨著父層改變，例如Row 高度無限(但寬度未設置時為0)，Column寬度無限
//           //當長寬沒有時，自動fit child
//           Container(
//             // color: Colors.greenAccent,
//             //全部padding
//             padding: EdgeInsets.all(10),
//             //單邊padding單邊padding
//             // padding: EdgeInsets.only(left: 10, top: 10),
//             child: Text("This is a data"),
//             decoration: BoxDecoration(
//               color: Colors.greenAccent,
//               borderRadius: BorderRadius.circular(10.0),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Color getColor() {
//     return Color.fromARGB(
//       255,
//       Random().nextInt(255),
//       Random().nextInt(255),
//       Random().nextInt(255),
//     );
//   }
// }

// class HomePage3 extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     //葉面的Widge，提供接入的 parameters
//     return Scaffold(
//       //上方AppBar標題
//       appBar: new AppBar(title: Text('MyApp Demo')),
//       // 小卡
//       // body: Card(
//       //   //用cantainer作為大小框架(因為 card 預設fix child的大小)
//       //   child: Container(child: Text("Test Demo"), width: 100, height: 50),
//       // ),
//       body: Center(
//         child: SizedBox(
//           width: 300,
//           height: 200,
//           child: Card(child: Text("Chaewon love Jimmy")),
//         ),
//       ),
//     );
//   }
// }

// class HomePage4 extends StatelessWidget {
//   final List<Widget> cards; // 透過建構子傳入的卡片清單（不可變）=> 泛型清單，裡面裝的是 Widget
//   const HomePage4({super.key, required this.cards}); // 建構子：要求一定要提供 cards

//   final bool useFraction = true;
//   static bool useFraction2 = true;

//   @override
//   Widget build(BuildContext context) {
//     final n = cards.length; // 取卡片個數，後面依張數決定排版
//     return Scaffold(
//       appBar: new AppBar(title: Text('MyApp Demo')),
//       body: Column(
//         children: [
//           if (useFraction)
//             Expanded(
//               child: FractionallySizedBox(
//                 widthFactor: 1,
//                 heightFactor: 0.8,
//                 child: _buildBody(n),
//               ),
//             )
//           else
//             Expanded(child: SizedBox.expand(child: _buildBody(n))),
//         ],
//       ),
//     );
//   }

//   // 依卡片數量決定要回傳的版面
//   Widget _buildBody(int n) {
//     if (n == 0) {
//       return const Center(child: Text('沒有卡片'));
//     }

//     if (n == 1) {
//       return Center(
//         child: Expanded(
//           child: Padding(padding: const EdgeInsets.all(30), child: cards[0]),
//         ),
//       );
//     }

//     if (n == 2) {
//       return Column(
//         children: [
//           Expanded(
//             child: Padding(padding: const EdgeInsets.all(30), child: cards[0]),
//           ),
//           Expanded(
//             child: Padding(padding: const EdgeInsets.all(30), child: cards[1]),
//           ),
//         ],
//       );
//     }

//     // 3 張以上
//     return GridView.count(
//       padding: const EdgeInsets.all(12),
//       crossAxisCount: 2,
//       crossAxisSpacing: 12,
//       mainAxisSpacing: 12,
//       childAspectRatio: 3 / 2,
//       children: cards,
//     );
//   }
// }
