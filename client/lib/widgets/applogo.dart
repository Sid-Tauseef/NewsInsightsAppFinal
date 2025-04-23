import 'package:flutter/material.dart';

class CommonLogo extends StatelessWidget {
  const CommonLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Hero(
      tag: 'app-logo',
      child: Container(
        padding: const EdgeInsets.all(20),
        child: TweenAnimationBuilder(
          tween: Tween<double>(begin: 0.9, end: 1.0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon with gradient background
                  Container(
                    width: screenWidth * 0.12,
                    height: screenWidth * 0.12,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.white, Colors.purpleAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.article_outlined,
                      size: 32,
                      color: Colors.deepPurple,
                    ),
                  ).paddingOnly(right: 15),
                  
                  // Text Content
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title with gradient text
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Colors.white, Colors.purpleAccent],
                          stops: [0.4, 1.0],
                        ).createShader(bounds),
                        child: const Text(
                          "News Insights",
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      
                      // Subtitle
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Text(
                          "Verified • Reliable • Fact-Checked",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

extension WidgetPadding on Widget {
  Widget paddingOnly({double left = 0, double right = 0, double top = 0, double bottom = 0}) {
    return Padding(
      padding: EdgeInsets.only(
        left: left,
        right: right,
        top: top,
        bottom: bottom,
      ),
      child: this,
    );
  }
}