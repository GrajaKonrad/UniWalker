import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../widgets/custom_app_bar.dart';
import '../widgets/arrow.dart';

enum CameraViewMode {
  camera,
  map,
}

@RoutePage()
class CameraView extends StatefulWidget {
  const CameraView({super.key});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  CameraViewMode mode = CameraViewMode.camera;
  CameraController? _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => initializeCamera());
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title: const TextField(
            decoration: InputDecoration(
              hintText: 'Znajdź salę',
              suffixIcon: Icon(Icons.search),
            ),
          ),
        ),
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            switch (mode) {
              CameraViewMode.camera => _buildCamera(context),
              CameraViewMode.map => _buildMap(context),
            },
            Positioned(
              top: 16,
              right: 16,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(64),
                    child: switch (mode) {
                      CameraViewMode.camera => _buildMap(context),
                      CameraViewMode.map => ColoredBox(
                          color: Colors.black,
                          child: SizedBox(
                            width: 128,
                            height: 128,
                            child: _buildCamera(context),
                          ),
                        ),
                    },
                  ),
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(64),
                      child: InkWell(
                        splashColor:
                            Colors.amberAccent.shade100.withOpacity(0.2),
                        highlightColor: Colors.amberAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(64),
                        onTap: () {
                          setState(() {
                            mode = switch (mode) {
                              CameraViewMode.camera => CameraViewMode.map,
                              CameraViewMode.map => CameraViewMode.camera,
                            };
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (mode == CameraViewMode.camera)
              const Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 64),
                  child: Arrow(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCamera(BuildContext context) {
    if (_controller?.value.isInitialized ?? false) {
      return Center(
        child: CameraPreview(_controller!),
      );
    }
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildMap(BuildContext context) {
    return Image(
      width: mode == CameraViewMode.camera ? 128 : null,
      height: mode == CameraViewMode.camera ? 128 : null,
      fit: BoxFit.cover,
      image: const AssetImage('assets/mapa.png'),
    );
  }

  Future<void> initializeCamera() async {
    final camera = (await availableCameras()).first;
    _controller = CameraController(
      camera,
      ResolutionPreset.ultraHigh,
      enableAudio: false,
    );

    await _controller?.initialize();
    if (mounted) {
      setState(() {});
    }
  }
}
