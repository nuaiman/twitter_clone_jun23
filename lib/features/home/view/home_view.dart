import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:twitter_clone/features/home/widgets/side_drawer.dart';

import '../../../constants/assets_constants.dart';
import '../../../constants/ui_constants.dart';
import '../../../theme/pallete.dart';
import '../../tweet/view/create_tweet_view.dart';

class HomeView extends StatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => HomeView(),
      );
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final appBar = UIConstants.appBar();

  int _pageIndex = 0;

  void _onIndexChanged(int index) {
    setState(() {
      _pageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _pageIndex == 0 ? appBar : null,
      drawer: const SideDrawer(),
      body: IndexedStack(
        index: _pageIndex,
        children: UIConstants.bottomTabBarPages,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(CreateTweetView.route());
        },
        child: const Icon(
          Icons.add,
          color: Pallete.backgroundColor,
          size: 28,
        ),
      ),
      bottomNavigationBar: CupertinoTabBar(
        activeColor: Pallete.whiteColor,
        currentIndex: _pageIndex,
        onTap: (index) => _onIndexChanged(index),
        items: [
          BottomNavigationBarItem(
              icon: SvgPicture.asset(
            _pageIndex == 0
                ? AssetsConstants.homeFilledIcon
                : AssetsConstants.homeOutlinedIcon,
            colorFilter:
                const ColorFilter.mode(Pallete.whiteColor, BlendMode.srcIn),
          )),
          BottomNavigationBarItem(
              icon: _pageIndex == 1
                  ? CircleAvatar(
                      backgroundColor: Pallete.whiteColor,
                      child: SvgPicture.asset(AssetsConstants.searchIcon))
                  : SvgPicture.asset(
                      AssetsConstants.searchIcon,
                      colorFilter: const ColorFilter.mode(
                          Pallete.whiteColor, BlendMode.srcIn),
                    )),
          BottomNavigationBarItem(
              icon: SvgPicture.asset(
            _pageIndex == 2
                ? AssetsConstants.notifFilledIcon
                : AssetsConstants.notifOutlinedIcon,
            colorFilter:
                const ColorFilter.mode(Pallete.whiteColor, BlendMode.srcIn),
          )),
        ],
      ),
    );
  }
}
