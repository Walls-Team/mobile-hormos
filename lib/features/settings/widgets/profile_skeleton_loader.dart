import 'package:flutter/material.dart';

class ProfileSkeletonLoader extends StatefulWidget {
  const ProfileSkeletonLoader({Key? key}) : super(key: key);

  @override
  State<ProfileSkeletonLoader> createState() => _ProfileSkeletonLoaderState();
}

class _ProfileSkeletonLoaderState extends State<ProfileSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Avatar skeleton
          Center(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: [
                        _animation.value - 0.3,
                        _animation.value,
                        _animation.value + 0.3,
                      ],
                      colors: [
                        Colors.grey[800]!.withOpacity(0.3),
                        Colors.grey[700]!.withOpacity(0.4),
                        Colors.grey[800]!.withOpacity(0.3),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          
          // Texto ayuda skeleton
          Center(
            child: _buildShimmerBox(
              width: 180,
              height: 12,
            ),
          ),
          const SizedBox(height: 20),

          // Username label
          _buildShimmerBox(width: 80, height: 14),
          const SizedBox(height: 8),
          
          // Username field
          _buildShimmerBox(width: double.infinity, height: 48),
          const SizedBox(height: 16),

          // Height label
          _buildShimmerBox(width: 60, height: 14),
          const SizedBox(height: 8),
          
          // Height field
          _buildShimmerBox(width: double.infinity, height: 48),
          const SizedBox(height: 16),

          // Weight label
          _buildShimmerBox(width: 60, height: 14),
          const SizedBox(height: 8),
          
          // Weight field
          _buildShimmerBox(width: double.infinity, height: 48),
          const SizedBox(height: 16),

          // Birth Date label
          _buildShimmerBox(width: 90, height: 14),
          const SizedBox(height: 8),
          
          // Birth Date field
          _buildShimmerBox(width: double.infinity, height: 48),
          const SizedBox(height: 16),

          // Gender label
          _buildShimmerBox(width: 70, height: 14),
          const SizedBox(height: 8),
          
          // Gender field
          _buildShimmerBox(width: double.infinity, height: 48),
          const SizedBox(height: 24),

          // Save button
          _buildShimmerBox(width: double.infinity, height: 48, borderRadius: 12),
        ],
      ),
    );
  }

  Widget _buildShimmerBox({
    required double width,
    required double height,
    double borderRadius = 8,
  }) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ],
              colors: [
                Colors.grey[800]!.withOpacity(0.3),
                Colors.grey[700]!.withOpacity(0.4),
                Colors.grey[800]!.withOpacity(0.3),
              ],
            ),
          ),
        );
      },
    );
  }
}
