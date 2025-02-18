import 'dart:html' as html; // Import dart:html
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Web Image Viewer',
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  String imageUrl = '';
  bool _isMenuOpen = false;

  void _loadImage() {
    setState(() {
      imageUrl = _controller.text;
    });
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  // Function to toggle fullscreen using JavaScript
  void _toggleFullScreenJS() {
    html.Document document = html.window.document;
    html.Element? element = document.documentElement;

    if (html.document.fullscreenElement != null) {
      html.document.exitFullscreen(); // Exit fullscreen if already in fullscreen
    } else {
      element?.requestFullscreen(); // Enter fullscreen
    }
  }

  // Function to close the menu
  void _closeMenu() {
    if (_isMenuOpen) {
      setState(() {
        _isMenuOpen = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Web Image Viewer')),
      body: Stack(
        children: [
          GestureDetector(
            onTap: _closeMenu, // Close menu if clicking outside
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(hintText: 'Enter Image URL'),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: _loadImage,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GestureDetector(
                      onDoubleTap: _toggleFullScreenJS, // Double tap to toggle fullscreen
                      child: imageUrl.isNotEmpty
                          ? Image.network(imageUrl, loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        } else {
                          return Center(
                            child: CircularProgressIndicator(value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                : null
                                : null),
                          );
                        }
                      })
                          : Center(child: const Text("Enter a valid URL to load an image")),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Context menu when _isMenuOpen is true
          if (_isMenuOpen)
            GestureDetector(
              onTap: _closeMenu, // Close menu if clicked outside
              child: Container(
                color: Colors.black54, // Dimming the background
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        FloatingActionButton.extended(
                          onPressed: () {
                            _toggleFullScreenJS();
                            _closeMenu(); // Close menu after action
                          },
                          label: const Text("Enter fullscreen"),
                          icon: const Icon(Icons.fullscreen),
                        ),
                        const SizedBox(height: 8),
                        FloatingActionButton.extended(
                          onPressed: () {
                            _toggleFullScreenJS();
                            _closeMenu(); // Close menu after action
                          },
                          label: const Text("Exit fullscreen"),
                          icon: const Icon(Icons.fullscreen_exit),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          // Floating "Plus" button
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              onPressed: _toggleMenu,
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleFullScreen(BuildContext context) {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      // Switch to fullscreen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      // Exit fullscreen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }
}
