import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_pallete.dart';
import '../widgets/music_slab.dart';
import 'library_page.dart';
import 'songs_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 0;
  final _pages = [
    const SongsPage(),
    const LibraryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (value) {
          setState(() {
            _selectedIndex = value;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              _selectedIndex == 0
                  ? "assets/images/home_filled.png"
                  : "assets/images/home_unfilled.png",
              color: _selectedIndex == 0
                  ? Pallete.whiteColor
                  : Pallete.inactiveBottomBarItemColor,
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              "assets/images/library.png",
              color: _selectedIndex == 1
                  ? Pallete.whiteColor
                  : Pallete.inactiveBottomBarItemColor,
            ),
            label: "Library",
          ),
        ],
      ),
      body: Stack(
        children: [
          _pages[_selectedIndex],
          const Positioned(
            bottom: 0,
            child: MusicSlab(),
          ),
        ],
      ),
    );
  }
}
