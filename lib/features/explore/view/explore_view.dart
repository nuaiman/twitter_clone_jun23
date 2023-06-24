import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/common/error_page.dart';
import 'package:twitter_clone/common/loading_page.dart';
import 'package:twitter_clone/features/explore/controller/explore_controller.dart';
import 'package:twitter_clone/theme/pallete.dart';

import '../widgets/search_tile.dart';

class ExploreView extends ConsumerStatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const ExploreView(),
      );
  const ExploreView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ExploreViewState();
}

class _ExploreViewState extends ConsumerState<ExploreView> {
  final _searchController = TextEditingController();
  bool _isShowUser = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appBarTextfieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(50),
      borderSide: const BorderSide(color: Pallete.searchBarColor),
    );
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          height: 50,
          child: TextField(
            onChanged: (value) {
              setState(() {
                _isShowUser = true;
              });
            },
            onTapOutside: (event) {
              FocusManager.instance.primaryFocus!.unfocus();
            },
            controller: _searchController,
            decoration: InputDecoration(
              fillColor: Pallete.searchBarColor,
              filled: true,
              border: appBarTextfieldBorder,
              focusedBorder: appBarTextfieldBorder,
              hintText: 'Search Twitter',
              contentPadding: const EdgeInsets.all(10).copyWith(left: 20),
            ),
          ),
        ),
      ),
      body: _isShowUser
          ? ref.watch(searchUserProvider(_searchController.text)).when(
                data: (users) {
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];

                      return SearchTile(
                        userModel: user,
                      );
                    },
                  );
                },
                error: (error, stackTrace) =>
                    ErrorText(error: error.toString()),
                loading: () => const Loader(),
              )
          : const SizedBox(),
    );
  }
}
