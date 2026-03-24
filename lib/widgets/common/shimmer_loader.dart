import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../config/theme.dart';

class ShimmerCard extends StatelessWidget {
  final double height;
  const ShimmerCard({super.key, this.height = 160});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: height,
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              _box(40, 40, radius: 12),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _box(16, double.infinity),
                const SizedBox(height: 8),
                _box(12, 160),
              ])),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _box(48, double.infinity, radius: 10)),
              const SizedBox(width: 8),
              Expanded(child: _box(48, double.infinity, radius: 10)),
              const SizedBox(width: 8),
              Expanded(child: _box(48, double.infinity, radius: 10)),
            ]),
            const SizedBox(height: 14),
            _box(8, double.infinity, radius: 4),
          ]),
        ),
      ),
    );
  }

  Widget _box(double h, double w, {double radius = 8}) => Container(
    height: h,
    width: w == double.infinity ? null : w,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}

class ShimmerStatGrid extends StatelessWidget {
  final int count;
  const ShimmerStatGrid({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade100,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.7),
        itemCount: count,
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}

class ShimmerList extends StatelessWidget {
  final int count;
  final double cardHeight;
  const ShimmerList({super.key, this.count = 3, this.cardHeight = 160});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, __) => ShimmerCard(height: cardHeight),
          childCount: count,
        ),
      ),
    );
  }
}
