import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pyjama_runner/widgets/app/Sidebar.dart';

class CharacterDisplayScreen extends StatefulWidget {
  const CharacterDisplayScreen({super.key});

  @override
  State<CharacterDisplayScreen> createState() => _CharacterDisplayScreenState();
}

class _CharacterDisplayScreenState extends State<CharacterDisplayScreen> {
  @override
  void initState() {
    super.initState();

    // Lock orientation to portrait when entering this screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    // Optionally reset to allow all orientations when leaving the screen
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  final List<Activity> activities = [
    Activity(
        name: 'cuddle',
        label: 'Cuddle with John',
        color: const Color(0xFFFED127),
        value: '+20%'),
    Activity(
        name: 'walk',
        label: 'Walk with John',
        color: const Color(0xFFFED127),
        value: '+70%'),
    Activity(
        name: 'talk',
        label: 'Talk with John',
        color: const Color(0xFFFED127),
        value: '+10%'),
    Activity(
        name: 'eat',
        label: 'Eat with John',
        color: const Color(0xFFFED127),
        value: '+70%'),
  ];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF1C153C),
      drawer: SideBar(onClose: () => Navigator.of(context).pop()),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.00, -1.00),
            end: Alignment(0, 1),
            colors: [Color(0xFF24243E), Color(0xFF302B63), Color(0xFF0F0C29)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              _buildCharacterInfo(),
              _buildCharacterActions(),
              const SizedBox(height: 24),
              _buildActivityList(),
              const SizedBox(height: 16),
              _buildCoinCourse(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTopCard(
            icon: Icons.emoji_events,
            value: '153 PJC',
            color: const Color(0xFFFFD33A),
          ),
          IconButton(
            icon: const Icon(Icons.menu),
            color: const Color(0xFFFED127),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterInfo() {
    return Column(
      children: [
        Image.asset("assets/images/pyjama/pyjama.png", height: 64),
        const SizedBox(height: 8),
        const Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '153',
                style: TextStyle(
                  color: Color(0xFF08FAFA),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(text: ' '),
              TextSpan(
                text: 'PJC',
                style: TextStyle(
                  color: Color(0xFF08FAFA),
                  fontSize: 11,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCharacterActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTimeUntilBedtime(),
        _buildCharacterImage(),
        _buildProgressBarSection(),
      ],
    );
  }

  Widget _buildTimeUntilBedtime() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '2h:1min',
          style: TextStyle(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Text(
          'Until bedtime',
          style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 10,
              fontWeight: FontWeight.w400),
        ),
      ],
    );
  }

  Widget _buildCharacterImage() {
    return Column(
      children: [
        Stack(
          children: [
            Image.asset(
              'assets/images/pyjama/characters/shiba-pyjama-red-halbmond.png',
              height: 326.0,
            ),
            Positioned(
              bottom: 0,
              child: Container(
                height: 35,
                width: 240,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(200),
                    topRight: Radius.circular(200),
                    bottomLeft: Radius.circular(200),
                    bottomRight: Radius.circular(200),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4), // Shadow color
                      spreadRadius: 5, // Spread radius
                      blurRadius: 15, // Blur radius for a softer shadow
                      offset: const Offset(0, 10), // Shadow below the container
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 36),
        const Text(
          'John is very unhappy',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Color(0xFFFED127),
              fontSize: 14,
              fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 16.0),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF08FAFA),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            '0.020 PJC',
            style: TextStyle(
                color: Color(0xFF0F0C29),
                fontSize: 12,
                fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'earning, while sleeping',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 9,
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildProgressBarSection() {
    return Column(
      children: [
        _buildProgressBar(0.15),
        const SizedBox(height: 8),
        const Text('15%', style: TextStyle(color: Colors.white, fontSize: 16)),
      ],
    );
  }

  Widget _buildActivityList() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final activity = activities[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: _buildActionButton(activity),
          );
        },
      ),
    );
  }

  Widget _buildCoinCourse() {
    return Column(
      children: [
        Text(
          'Pyjama Coin Course',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.yellowAccent.withOpacity(0.8), fontSize: 18),
        ),
        const SizedBox(height: 8),
        const Text(
          '0.009',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.pinkAccent,
              fontSize: 24,
              fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildTopCard(
      {required IconData icon, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: ShapeDecoration(
        color: const Color(0x35C6C6C6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28.0),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double value) {
    return Container(
      height: 240,
      width: 20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.black,
        border: Border.all(color: const Color(0xFF08FAFA), width: 2),
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 200 * value,
          width: 20,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.redAccent,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(Activity activity) {
    return Container(
      height: 195,
      width: 153,
      margin: const EdgeInsets.all(6.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.yellowAccent),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/pyjama/activities/${activity.name}.png",
                height: 80),
            const SizedBox(height: 8),
            Text(
              activity.label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(activity.value,
                    style: TextStyle(color: activity.color, fontSize: 11)),
                Image.asset("assets/icons/heart-yellow.png", width: 12),
                const SizedBox(width: 2),
                Text('|',
                    style: TextStyle(color: activity.color, fontSize: 11)),
                const SizedBox(width: 2),
                Text('4 min',
                    style: TextStyle(color: activity.color, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Activity {
  final String name;
  final String label;
  final Color color;
  final String value;

  Activity(
      {required this.name,
      required this.label,
      required this.color,
      required this.value});
}
