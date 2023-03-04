import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphics_app/data/laughing_data.dart';
import 'package:graphics_app/widgets/chart_labels.dart';
import 'package:graphics_app/widgets/slide_selector.dart';
import 'package:graphics_app/widgets/week_summary.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
  ));
  runApp(const LOLTrackerApp());
}

class LOLTrackerApp extends StatelessWidget {
  const LOLTrackerApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'LOLTracker',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        extendBodyBehindAppBar: true,
        body: Dashboard(),
      ),
    );
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  int activeWeek = 1;
  PageController summaryController = PageController(
    viewportFraction: 1,
    initialPage: 1,
  );
  double chartHeight = 240;
  late List<ChartDataPoint> chartData;
  static const leftPadding = 60.0;
  static const rightPadding = 60.0;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    //start the animation
    _controller.forward();
    //add a callback to obeserve various state during animation
    _controller.addListener(() {
      setState(() {});
    });
    setState(() {
      chartData = normalizeData(weeksData[activeWeek - 1]);
    });

    @override
    void dispose() {
      _controller.dispose();
      super.dispose();
    }
  }

  List<ChartDataPoint> normalizeData(WeekData weekData) {
    final maxDay = weekData.days.reduce((DayData dayA, DayData dayB) {
      return dayA.laughs > dayB.laughs ? dayA : dayB;
    });

    final normalizedList = <ChartDataPoint>[];

    weekData.days.forEach((element) {
      normalizedList.add(ChartDataPoint(
          value: maxDay.laughs == 0 ? 0 : element.laughs / maxDay.laughs));
    });

    normalizedList.forEach((element) => print(element.value));

    return normalizedList;
  }

  void changeWeek(int week) {
    setState(() {
      activeWeek = week;
      chartData = normalizeData(weeksData[activeWeek - 1]);
      summaryController.animateToPage(week,
          duration: const Duration(milliseconds: 300), curve: Curves.ease);
    });
  }

  Path drawPath(bool closePath, double progress) {
    final width = MediaQuery.of(context).size.width;
    final height = chartHeight;
    final segmentWidth =
        (width - leftPadding - rightPadding) / ((chartData.length - 1) * 3);

    final path = Path()..moveTo(0, height - chartData[0].value * height);
    path.lineTo(leftPadding, height - chartData[0].value * height);

    for (var i = 1; i < chartData.length; i++) {
      path.cubicTo(
          (3 * (i - 1) + 1) * segmentWidth + leftPadding * progress,
          height - chartData[i - 1].value * height * progress,
          (3 * (i - 1) + 2) * segmentWidth + leftPadding * progress,
          height - chartData[i].value * height * progress,
          (3 * (i - 1) + 3) * segmentWidth + leftPadding * progress,
          height - chartData[i].value * height * progress);
    }

    path.lineTo(width, height - chartData[chartData.length - 1].value * height);

    if (closePath) {
      path.lineTo(width, height);
      path.lineTo(0, height);
    }

    return path;
  }

  /* Path drawPath(bool closePath) {
    final width = MediaQuery.of(context).size.width;
    final height = chartHeight;
    final segmentWiidth = width / (chartData.length - 1);
    final path = Path()..moveTo(0, height - chartData[0].value * height);

    for (var i = 0; i < chartData.length; i++) {
      final x = i * segmentWiidth;
      final y = height - (chartData[i].value * height);
      path.lineTo(x, y);
    }

    if (closePath) {
      path.lineTo(width, height);
      path.lineTo(0, height);
    }

    return path;
  }  */

  /* Path drawPath(bool closePath) {
    final width = MediaQuery.of(context).size.width;
    final height = chartHeight;
    final path = Path();
    final segmentWidth = width / 3 / 2;
    print(segmentWidth);
    path.moveTo(0, height);
    path.cubicTo(
        segmentWidth, height, 2 * segmentWidth, 0, 3 * segmentWidth, 0);

    path.cubicTo(4 * segmentWidth, 0, 5 * segmentWidth, height,
        6 * segmentWidth, height);

    return path;
  } */

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const DashboardBackground(),
        ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 60,
              margin: const EdgeInsets.only(top: 60),
              alignment: Alignment.center,
              child: const Text(
                'GRAPHICS',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SlideSelector(
                defaultSelectedIndex: activeWeek - 1,
                items: <SlideSelectorItem>[
                  SlideSelectorItem(
                    text: 'Week 1',
                    onTap: () {
                      changeWeek(1);
                    },
                  ),
                  SlideSelectorItem(
                    text: 'Week 2',
                    onTap: () {
                      changeWeek(2);
                    },
                  ),
                  SlideSelectorItem(
                    text: 'Week 3',
                    onTap: () {
                      changeWeek(3);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: chartHeight + 80,
              color: const Color(0xFF158443),
              child: Stack(
                children: [
                  ChartLaughLabels(
                    chartHeight: chartHeight,
                    topPadding: 40,
                    leftPadding: leftPadding,
                    rightPadding: rightPadding,
                    weekData: weeksData[activeWeek - 1],
                  ),
                  const Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: ChartDayLabels(
                      leftPadding: leftPadding,
                      rightPadding: rightPadding,
                    ),
                  ),
                  Positioned(
                    top: 40,
                    child: CustomPaint(
                      size:
                          Size(MediaQuery.of(context).size.width, chartHeight),
                      painter: PathPainter(
                          path: drawPath(false, _controller.value),
                          fillPath: drawPath(true, _controller.value)),
                    ),
                  )
                ],
              ),
            ),
            Container(
              color: Colors.white,
              height: 400,
              child: PageView.builder(
                clipBehavior: Clip.none,
                physics: const NeverScrollableScrollPhysics(),
                controller: summaryController,
                itemCount: 4,
                itemBuilder: (_, i) {
                  return WeekSummary(week: i);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class DashboardBackground extends StatelessWidget {
  const DashboardBackground({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: const Color(0xFF158443),
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class PathPainter extends CustomPainter {
  final Path path;
  final Path fillPath;

  PathPainter({required this.path, required this.fillPath});

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    canvas.drawPath(path, paint);
    paint.style = PaintingStyle.fill;
    paint.shader = ui.Gradient.linear(
      Offset.zero,
      Offset(0.0, size.height),
      [
        Colors.white.withOpacity(0.2),
        Colors.white.withOpacity(0.85),
      ],
    );

    canvas.drawPath(fillPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ChartDataPoint {
  final double value;

  ChartDataPoint({required this.value});
}
