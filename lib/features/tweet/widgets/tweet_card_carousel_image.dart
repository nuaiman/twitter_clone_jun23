import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class TweetCardCarouselImages extends StatefulWidget {
  const TweetCardCarouselImages({
    super.key,
    required this.imageLinks,
  });

  final List<String> imageLinks;

  @override
  State<TweetCardCarouselImages> createState() =>
      _TweetCardCarouselImagesState();
}

class _TweetCardCarouselImagesState extends State<TweetCardCarouselImages> {
  int _current = 0;
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CarouselSlider(
              items: widget.imageLinks
                  .map(
                    (i) => Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25)),
                      height: 100,
                      margin: const EdgeInsets.all(10),
                      child: Image.network(
                        i,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                  .toList(),
              options: CarouselOptions(
                viewportFraction: 1,
                enableInfiniteScroll: false,
                onPageChanged: (index, reason) {
                  setState(() {
                    _current = index;
                  });
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.imageLinks.asMap().entries.map((e) {
                return Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white
                          .withOpacity(_current == e.key ? 0.9 : 0.4)),
                );
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }
}
