import 'dart:html' as html;
import 'dart:ui' as ui; // Needed for registering the HTML element.
import 'package:flutter/material.dart';

void main() {
  // Register the HTML container that will hold our image.
  // ignore: undefined_prefixed_name
  ui.platformViewRegistry.registerViewFactory(
    'image-container',
        (int viewId) => html.DivElement()..id = 'imageContainer',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Web Image Viewer',
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _urlController = TextEditingController();
  bool _isMenuOpen = false;

  /// Loads the image from the URL input and inserts it as an HTML <img> element.
  void _loadImage() {
    String imageUrl = _urlController.text.trim();
    if (imageUrl.isEmpty) return;

    // Get the container div (registered earlier) by its id.
    html.Element? container = html.document.getElementById('imageContainer');
    container?.children.clear();

    // Create an HTML image element.
    html.ImageElement img = html.ImageElement(src: imageUrl)
      ..style.maxWidth = '90%'
      ..style.maxHeight = '90%'
      ..style.position = 'absolute'
      ..style.top = '50%'
      ..style.left = '50%'
      ..style.transform = 'translate(-50%, -50%)'
      ..style.cursor = 'pointer'; // Indicate that it is clickable.

    // Add a double-click listener that toggles fullscreen.
    img.onDoubleClick.listen((event) {
      if (html.document.fullscreenElement == null) {
        _enterFullscreenJS();
      } else {
        _exitFullscreenJS();
      }
    });

    container?.append(img);
  }

  /// Enters fullscreen using the browser's JS API.
  void _enterFullscreenJS() {
    html.Element? docElement = html.document.documentElement;
    if (docElement != null && html.document.fullscreenElement == null) {
      docElement.requestFullscreen();
    }
  }

  /// Exits fullscreen using the browser's JS API.
  void _exitFullscreenJS() {
    if (html.document.fullscreenElement != null) {
      html.document.exitFullscreen();
    }
  }

  /// Toggle the visibility of the context menu.
  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  /// Closes the context menu.
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
      // GestureDetector here is used to detect taps outside the context menu.
      body: GestureDetector(
        onTap: _closeMenu,
        child: Column(
          children: [
            // URL input field and Load button.
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _urlController,
                      decoration: const InputDecoration(
                        hintText: 'Enter Image URL',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _loadImage,
                    child: const Text('Load'),
                  ),
                ],
              ),
            ),
            // HTML container that displays the image.
            Expanded(
              child: HtmlElementView(
                viewType: 'image-container',
              ),
            ),
          ],
        ),
      ),
      // Floating action button and context menu overlay.
      floatingActionButton: Stack(
        children: [
          // Dimmed background overlay when the context menu is open.
          if (_isMenuOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeMenu,
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ),
          // The context menu is positioned above the FAB.
          if (_isMenuOpen)
            Positioned(
              right: 16,
              bottom: 80, // Adjust this value as needed.
              child: Material(
                color: Colors.white,
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // "Enter fullscreen" menu button.
                    TextButton(
                      onPressed: () {
                        _enterFullscreenJS();
                        _closeMenu();
                      },
                      child: const Text('Enter fullscreen'),
                    ),
                    const Divider(height: 1),
                    // "Exit fullscreen" menu button.
                    TextButton(
                      onPressed: () {
                        _exitFullscreenJS();
                        _closeMenu();
                      },
                      child: const Text('Exit fullscreen'),
                    ),
                  ],
                ),
              ),
            ),
          // The Floating Action Button ("Plus" button).
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              onPressed: _toggleMenu,
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
