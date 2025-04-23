import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(Lucky888SlotGame());

class Lucky888SlotGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: SlotGamePage(), debugShowCheckedModeBanner: false);
  }
}

class SlotGamePage extends StatefulWidget {
  @override
  State<SlotGamePage> createState() => _SlotGamePageState();
}

class _SlotGamePageState extends State<SlotGamePage> {
  // รายการสัญลักษณ์สล็อต
  List<String> symbols = ["8️⃣", "🍒", "💎", "🔔", "🍇"];
  int money = 10000; // เงินรวมเริ่มต้นของผู้เล่น
  int bet = 1; // เงินเดิมพันเริ่มต้น
  int lastWin = 0; // เงินที่ชนะในรอบล่าสุด

  bool isAutoPlay = false; // สถานะโหมด Auto Spin
  bool isTurbo = false; // สถานะโหมด Turbo
  Timer? autoSpinTimer; // ตัวจับเวลา Auto Spin

  // ตารางสล็อต 3x3
  List<List<String>> slotGrid = List.generate(3, (_) => List.filled(3, ""));

  Map<List<int>, bool> winningCells = {}; // ตำแหน่งช่องที่ถูกรางวัล

  Timer? _betHoldTimer; // ตัวจับเวลาสำหรับกดค้างปุ่มเดิมพัน

  @override
  void initState() {
    super.initState();

    // สุ่มค่าเริ่มต้นในตารางสล็อต
    slotGrid = List.generate(
      3,
      (_) => List.generate(3, (_) => symbols[Random().nextInt(symbols.length)]),
    );
  }

  // ฟังก์ชันหมุนสล็อต
  void spin() {
    if (money < bet || bet > 5000) return;
    setState(() {
      money -= bet; // หักเงินเดิมพัน
      lastWin = 0;
      winningCells.clear();
      // สุ่มผลลัพธ์สล็อต
      bool forceWin = Random().nextDouble() < 0.12; // 12% ที่จะบังคับชนะ
      int forceType = Random().nextInt(5);
      String winSymbol = symbols[Random().nextInt(symbols.length)];

      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          if (forceWin) {
            if (forceType < 3 && i == forceType) {
              slotGrid[i][j] = winSymbol;
            } else if (forceType == 3 && i == j) {
              slotGrid[i][j] = winSymbol;
            } else if (forceType == 4 && i + j == 2) {
              slotGrid[i][j] = winSymbol;
            } else {
              slotGrid[i][j] = symbols[Random().nextInt(symbols.length)];
            }
          } else {
            slotGrid[i][j] = symbols[Random().nextInt(symbols.length)];
          }
        }
      }
    });

    // คำนวณเงินที่ชนะ
    int win = calculateWin();
    setState(() {
      lastWin = win;
      money += win;
    });
    highlightWinningCombinations();
  }

  // หาตำแหน่งที่ถูกรางวัล
  void highlightWinningCombinations() {
    winningCells.clear();

    // ตรวจสอบแต่ละแถว
    for (int i = 0; i < 3; i++) {
      if (isMatch(slotGrid[i])) {
        if ((i == 1 && bet >= 1) || (i != 1 && bet >= 2)) {
          for (int j = 0; j < 3; j++) {
            winningCells[<int>[i, j]] = true;
          }
        }
      }
    }

    // ตรวจสอบแนวทแยง
    if (bet == 3) {
      if (slotGrid[0][0] == slotGrid[1][1] &&
          slotGrid[1][1] == slotGrid[2][2]) {
        winningCells[<int>[0, 0]] = true;
        winningCells[<int>[1, 1]] = true;
        winningCells[<int>[2, 2]] = true;
      }
      if (slotGrid[0][2] == slotGrid[1][1] &&
          slotGrid[1][1] == slotGrid[2][0]) {
        winningCells[<int>[0, 2]] = true;
        winningCells[<int>[1, 1]] = true;
        winningCells[<int>[2, 0]] = true;
      }
    }

    setState(() {});
  }

  // คำนวณเงินรางวัล
  int calculateWin() {
    int totalWin = 0;

    // แถวกลาง
    if (isMatch(slotGrid[1])) {
      if (slotGrid[1][0] == "8️⃣") {
        totalWin += bet * 5;
      } else {
        totalWin += bet * 4;
      }
    }

    // แถวบน
    if (bet >= 2 && isMatch(slotGrid[0])) {
      if (slotGrid[0][0] == "8️⃣") {
        totalWin += bet * 5;
      } else {
        totalWin += bet * 4;
      }
    }

    // แถวล่าง
    if (bet >= 3 && isMatch(slotGrid[2])) {
      if (slotGrid[2][0] == "8️⃣") {
        totalWin += bet * 5;
      } else {
        totalWin += bet * 4;
      }
    }

    // แนวทแยง
    if (bet == 3 &&
        slotGrid[0][0] == slotGrid[1][1] &&
        slotGrid[1][1] == slotGrid[2][2]) {
      if (slotGrid[0][0] == "8️⃣") {
        totalWin += bet * 8;
      } else {
        totalWin += bet * 5;
      }
    }

    if (bet == 3 &&
        slotGrid[0][2] == slotGrid[1][1] &&
        slotGrid[1][1] == slotGrid[2][0]) {
      if (slotGrid[0][2] == "8️⃣") {
        totalWin += bet * 8;
      } else {
        totalWin += bet * 5;
      }
    }

    return totalWin;
  }

  // เช็คว่าแถวที่ส่งเข้ามาเหมือนกันทั้งแถวหรือไม่
  bool isMatch(List<String> row) {
    return row[0] == row[1] && row[1] == row[2];
  }

  // สร้างกล่องสล็อตแต่ละช่อง
  Widget buildSlotBox(String symbol, int row, int col) {
    bool isWinningCell = false;
    for (var position in winningCells.keys) {
      if (position[0] == row && position[1] == col) {
        isWinningCell = true;
        break;
      }
    }

    return Container(
      width: 70,
      height: 70,
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isWinningCell ? Colors.yellow.shade100 : Colors.white,
        border: Border.all(
          color: isWinningCell ? Colors.amber.shade700 : Colors.brown.shade700,
          width: isWinningCell ? 4 : 2,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Center(
        child: Text(
          symbol,
          style: TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.bold,
            color: Colors.red.shade900,
            shadows: [
              Shadow(
                color: Colors.amber.shade700,
                blurRadius: 8,
                offset: Offset(1, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // สร้างปุ่มเพิ่ม/ลดเงินเดิมพัน (กดค้างได้)
  Widget _betButton(
    String label,
    VoidCallback onPressed,
    Color color,
    double screenWidth,
  ) {
    return GestureDetector(
      onTap: onPressed,
      onLongPressStart: (_) {
        _startBetHold(onPressed);
      },
      onLongPressEnd: (_) {
        _stopBetHold();
      },
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          minimumSize: Size(
            screenWidth < 400 ? 36 : 44,
            screenWidth < 400 ? 36 : 44,
          ),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 2,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: screenWidth < 400 ? 15 : 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ฟังก์ชัน กดปุ่มเดิมพันค้าง
  void _startBetHold(VoidCallback onPressed) {
    _betHoldTimer?.cancel();
    _betHoldTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      onPressed();
    });
  }

  void _stopBetHold() {
    _betHoldTimer?.cancel();
  }

  // เริ่มโหมด Auto Spin
  void startAutoPlay() {
    stopAutoPlay();
    setState(() {
      isAutoPlay = true;
    });
    autoSpinTimer = Timer.periodic(
      Duration(milliseconds: isTurbo ? 100 : 350),
      (_) {
        if (money >= bet && bet <= 5000) {
          spin();
        } else {
          stopAutoPlay();
        }
      },
    );
  }

  // หยุดโหมด Auto Spin
  void stopAutoPlay() {
    autoSpinTimer?.cancel();
    setState(() {
      isAutoPlay = false;
    });
  }

  @override
  void dispose() {
    autoSpinTimer?.cancel();
    _betHoldTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          double slotBoxSize = screenWidth < 400 ? screenWidth / 5 : 70;
          double containerWidth = screenWidth < 400 ? screenWidth * 0.95 : 360;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFe96443), Color(0xFF904e95)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ชื่อเกม
                    Text(
                      'Lucky 888',
                      style: TextStyle(
                        fontSize: screenWidth < 400 ? 22 : 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade100,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 8,
                            offset: Offset(2, 4),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 18),
                    // กรอบเครื่องสล็อต
                    Container(
                      width: containerWidth,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0xFFB22222),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.amber.shade700,
                          width: 5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.4),
                            blurRadius: 24,
                            spreadRadius: 6,
                          ),
                          BoxShadow(
                            color: Colors.black54,
                            blurRadius: 12,
                            spreadRadius: 2,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ไฟด้านบน
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(9, (i) {
                              final lights = [
                                Colors.red,
                                Colors.yellow,
                                Colors.green,
                              ];
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 1),
                                child: Icon(
                                  Icons.circle,
                                  color: lights[i % 3],
                                  size: screenWidth < 400 ? 10 : 16,
                                ),
                              );
                            }),
                          ),
                          SizedBox(height: 6),
                          // ชื่อเครื่อง
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 4),
                            margin: EdgeInsets.only(bottom: 6),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade700,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.brown.shade900,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'SLOT GAME',
                                style: TextStyle(
                                  fontSize: screenWidth < 400 ? 12 : 18,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                  shadows: [
                                    Shadow(
                                      color: Colors.red.shade900,
                                      blurRadius: 4,
                                      offset: Offset(1, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // กริดสล็อต 3x3
                          Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.amber.shade700,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              children: List.generate(
                                3,
                                (i) => Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    3,
                                    (j) => Container(
                                      width: slotBoxSize,
                                      height: slotBoxSize,
                                      margin: EdgeInsets.all(2),
                                      child: buildSlotBox(slotGrid[i][j], i, j),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // ไฟด้านล่าง
                          SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(9, (i) {
                              final lights = [
                                Colors.green,
                                Colors.yellow,
                                Colors.red,
                              ];
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 1),
                                child: Icon(
                                  Icons.circle,
                                  color: lights[i % 3],
                                  size: screenWidth < 400 ? 10 : 16,
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 18),

                    // เงินรวม
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '💰 เงินของคุณ: ',
                          style: TextStyle(
                            fontSize: screenWidth < 400 ? 16 : 20,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          width: 90,
                          height: 32,
                          alignment: Alignment.center,
                          child: Text(
                            '$money',
                            style: TextStyle(
                              fontSize: screenWidth < 400 ? 16 : 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    // แสดงเงินที่ชนะรอบนี้
                    Text(
                      '🏆 ชนะรอบนี้: $lastWin',
                      style: TextStyle(
                        fontSize: screenWidth < 400 ? 14 : 18,
                        color: Colors.lightBlueAccent,
                      ),
                    ),
                    SizedBox(height: 12),

                    // ปุ่มเพิ่มลดเงินเดิมพัน
                    if (screenWidth < 370) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _betButton(
                            '-100',
                            () {
                              setState(() {
                                bet = (bet - 100 > 0) ? bet - 100 : 1;
                                if (bet > 5000) bet = 5000;
                              });
                            },
                            Colors.red.shade900,
                            screenWidth,
                          ),
                          SizedBox(width: 2),
                          _betButton(
                            '-10',
                            () {
                              setState(() {
                                bet = (bet - 10 > 0) ? bet - 10 : 1;
                              });
                            },
                            Colors.red.shade700,
                            screenWidth,
                          ),
                          SizedBox(width: 2),
                          _betButton(
                            '-1',
                            () {
                              setState(() {
                                bet = (bet - 1 > 0) ? bet - 1 : 1;
                              });
                            },
                            Colors.red.shade300,
                            screenWidth,
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      // แสดงจำนวนเงินเดิมพัน
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 60,
                            alignment: Alignment.center,
                            child: Text(
                              '$bet',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: screenWidth < 400 ? 16 : 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 2),
                          _betButton(
                            '+1',
                            () {
                              setState(() {
                                bet = (bet + 1 > 5000) ? 5000 : bet + 1;
                              });
                            },
                            Colors.green.shade300,
                            screenWidth,
                          ),
                          SizedBox(width: 2),
                          _betButton(
                            '+10',
                            () {
                              setState(() {
                                bet = (bet + 10 > 5000) ? 5000 : bet + 10;
                              });
                            },
                            Colors.green.shade700,
                            screenWidth,
                          ),
                          SizedBox(width: 2),
                          _betButton(
                            '+100',
                            () {
                              setState(() {
                                bet = (bet + 100 > 5000) ? 5000 : bet + 100;
                              });
                            },
                            Colors.green.shade900,
                            screenWidth,
                          ),
                        ],
                      ),
                    ] else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _betButton(
                            '-100',
                            () {
                              setState(() {
                                bet = (bet - 100 > 0) ? bet - 100 : 1;
                                if (bet > 5000) bet = 5000;
                              });
                            },
                            Colors.red.shade900,
                            screenWidth,
                          ),
                          SizedBox(width: 2),
                          _betButton(
                            '-10',
                            () {
                              setState(() {
                                bet = (bet - 10 > 0) ? bet - 10 : 1;
                              });
                            },
                            Colors.red.shade700,
                            screenWidth,
                          ),
                          SizedBox(width: 2),
                          _betButton(
                            '-1',
                            () {
                              setState(() {
                                bet = (bet - 1 > 0) ? bet - 1 : 1;
                              });
                            },
                            Colors.red.shade300,
                            screenWidth,
                          ),
                          SizedBox(width: 6),
                          // แสดงจำนวนเงินเดิมพัน
                          Container(
                            width: 60,
                            alignment: Alignment.center,
                            child: Text(
                              '$bet',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: screenWidth < 400 ? 16 : 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 6),
                          _betButton(
                            '+1',
                            () {
                              setState(() {
                                bet = (bet + 1 > 5000) ? 5000 : bet + 1;
                              });
                            },
                            Colors.green.shade300,
                            screenWidth,
                          ),
                          SizedBox(width: 2),
                          _betButton(
                            '+10',
                            () {
                              setState(() {
                                bet = (bet + 10 > 5000) ? 5000 : bet + 10;
                              });
                            },
                            Colors.green.shade700,
                            screenWidth,
                          ),
                          SizedBox(width: 2),
                          _betButton(
                            '+100',
                            () {
                              setState(() {
                                bet = (bet + 100 > 5000) ? 5000 : bet + 100;
                              });
                            },
                            Colors.green.shade900,
                            screenWidth,
                          ),
                        ],
                      ),

                    SizedBox(height: 16),

                    // ปุ่มหมุน/Auto/Turbo
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: money >= bet && bet <= 5000 ? spin : null,
                          child: Text(
                            '🎰 หมุน',
                            style: TextStyle(
                              fontSize: screenWidth < 400 ? 12 : 15,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: isAutoPlay ? stopAutoPlay : startAutoPlay,
                          child: Text(
                            isAutoPlay ? '⏹ หยุด Auto' : '🔁 Auto',
                            style: TextStyle(
                              fontSize: screenWidth < 400 ? 14 : 18,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            setState(() => isTurbo = !isTurbo);
                            if (isAutoPlay) {
                              stopAutoPlay();
                              startAutoPlay();
                            }
                          },
                          child: Text(
                            isTurbo ? '⚡ Turbo ON' : '⚡ Turbo OFF',
                            style: TextStyle(
                              fontSize: screenWidth < 400 ? 14 : 18,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isTurbo ? Colors.amber : Colors.grey,
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 18),

                    // ปุ่มรีสตาร์ทเกม
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          money = 10000;
                          bet = 1;
                          lastWin = 0;
                          slotGrid = List.generate(
                            3,
                            (_) => List.generate(
                              3,
                              (_) => symbols[Random().nextInt(symbols.length)],
                            ),
                          );
                          winningCells.clear();
                        });
                      },
                      child: Text(
                        '🔄 รีสตาร์ท',
                        style: TextStyle(
                          fontSize: screenWidth < 400 ? 13 : 16,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
