import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'prebuilt_widgets_wj.dart';

class AScaffold extends StatelessWidget {
  final Widget title;
  final Widget body;
  final Widget action;
  final bool isScrollable;
  AScaffold({this.title, this.body, this.action, this.isScrollable = true});

  @override
  Widget build(BuildContext context) {
    final Widget defaultBodyWidget = SafeArea(child: body);

    if (Platform.isIOS) {
      if (title == null) return CupertinoPageScaffold(child: defaultBodyWidget);

      final Color navBorderColor = MediaQuery.of(context).platformBrightness == Brightness.dark ? DIVIDER_COLOR_DARK : DIVIDER_COLOR;
      final Border navBorder = Border(bottom: BorderSide(color: navBorderColor, width: 0.0, style: BorderStyle.solid));
      Widget appBar;

      if (isScrollable) {
        final Color color = CupertinoDynamicColor.withBrightness(color: SLIVER_COLOR, darkColor: SLIVER_COLOR_DARK);
        appBar = CupertinoSliverNavigationBar(border: navBorder, largeTitle: title, transitionBetweenRoutes: false, backgroundColor: color, trailing: action);
        return CupertinoPageScaffold(child: Scrollbar(child: CustomScrollView(slivers: [appBar, SliverToBoxAdapter(child: body)])));
      } else {
        appBar = CupertinoNavigationBar(border: navBorder, middle: title, transitionBetweenRoutes: false, trailing: action);
        return CupertinoPageScaffold(navigationBar: appBar, child: defaultBodyWidget);
      }
    } else {
      if (title == null) return Scaffold(body: defaultBodyWidget);
      return Scaffold(appBar: AppBar(title: title, actions: [if (action != null) action]), body: defaultBodyWidget);
    }
  }
}

class ATabScaffold extends StatefulWidget {
  final List<Widget> tabTitleList;
  final List<BottomNavigationBarItem> tabItemList;
  final List<Widget> tabBodyList;
  ATabScaffold({@required this.tabTitleList, @required this.tabItemList, @required this.tabBodyList});

  @override
  _ATabScaffoldState createState() => _ATabScaffoldState();
}

class _ATabScaffoldState extends State<ATabScaffold> {
  CupertinoTabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    if (_tabController == null && Platform.isIOS) {
      _tabController = CupertinoTabController();
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabTitleList = widget.tabTitleList;
    final List<BottomNavigationBarItem> tabItemList = widget.tabItemList;
    final List<Widget> tabBodyList = widget.tabBodyList;

    if (Platform.isIOS) {
      return CupertinoTabScaffold(
        controller: _tabController,
        tabBar: CupertinoTabBar(items: tabItemList),
        tabBuilder: (_, index) => CupertinoTabView(builder: (context) => tabBodyList[index]),
      );
    } else {
      return WillPopScope(
        onWillPop: _onAndroidTabPop,
        child: Scaffold(
          appBar: AppBar(title: tabTitleList[_selectedIndex]),
          body: tabBodyList.elementAt(_selectedIndex),
          bottomNavigationBar: BottomNavigationBar(
            items: tabItemList,
            onTap: _onAndroidNavBarTapped,
            currentIndex: _selectedIndex,
          ),
        ),
      );
    }
  }

  Future<bool> _onAndroidTabPop() async {
    if (_selectedIndex == 0) return true;
    setState(() => _selectedIndex = 0);
    return false;
  }

  void _onAndroidNavBarTapped(int index) {
    setState(() => _selectedIndex = index);
  }
}
