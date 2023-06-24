import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:twitter_clone/constants/assets_constants.dart';
import 'package:twitter_clone/core/utils.dart';
import 'package:twitter_clone/features/tweet/controller/tweet_controller.dart';

import '../../../common/loading_page.dart';
import '../../../common/rounded_small_button.dart';
import '../../../theme/pallete.dart';
import '../../auth/controller/auth_controller.dart';

class CreateTweetView extends ConsumerStatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const CreateTweetView(),
      );
  const CreateTweetView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateTweetViewState();
}

class _CreateTweetViewState extends ConsumerState<CreateTweetView> {
  final _tweetController = TextEditingController();
  List<File> _images = [];

  @override
  void dispose() {
    _tweetController.dispose();
    super.dispose();
  }

  void _onPickImages() async {
    _images = await pickImages();
    setState(() {});
  }

  void _onTweeted() async {
    if (_tweetController.text.trim().isEmpty) {
      return;
    }
    ref.read(tweetControllerProvider.notifier).shareTweet(
          context: context,
          images: _images,
          text: _tweetController.text,
          repliedTo: '',
          repliedToUserId: '',
        );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(getCurrentUserDetailsProvider).value;
    final isLoading = ref.watch(tweetControllerProvider);
    return isLoading || currentUser == null
        ? const Loader()
        : Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(
                  Icons.close,
                  size: 30,
                ),
              ),
              actions: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Pallete.whiteColor,
                  backgroundImage: NetworkImage(currentUser.profilePic),
                ),
                const SizedBox(width: 20),
              ],
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Expanded(
                      child: TextField(
                        onTapOutside: (event) {
                          FocusManager.instance.primaryFocus!.unfocus();
                        },
                        controller: _tweetController,
                        style: const TextStyle(fontSize: 22),
                        decoration: const InputDecoration(
                          hintText: 'What\'s happening?',
                          border: InputBorder.none,
                        ),
                        maxLines: null,
                      ),
                    ),
                    if (_images.isNotEmpty)
                      CarouselSlider(
                        items: _images
                            .map(
                              (i) => Container(
                                // width: 100,
                                height: 100,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: Image.file(
                                  i,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                            .toList(),
                        options: CarouselOptions(
                          enableInfiniteScroll: false,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: Container(
              padding: const EdgeInsets.only(bottom: 10),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Pallete.greyColor,
                    width: 0.3,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _onPickImages,
                          child: SvgPicture.asset(AssetsConstants.galleryIcon),
                        ),
                        const SizedBox(width: 20),
                        SvgPicture.asset(AssetsConstants.gifIcon),
                        const SizedBox(width: 20),
                        SvgPicture.asset(AssetsConstants.emojiIcon),
                      ],
                    ),
                    RoundedSmallButton(
                      labeltext: 'Tweet',
                      onTap: _onTweeted,
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
