import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

late List<CameraDescription> _cameras;
late BannerAd topBanner;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  _cameras = await availableCameras();
  if (_cameras.isEmpty) {
    runApp(const NoCameraScreen());
  } else {
    runApp(const CameraScreen());
  }
}

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController controller;
  CameraImage? img;
  bool isBusy = false;
  String result = "";

  //TODO declare ImageLabeler
  dynamic imageLabeler;
  @override
  void initState() {
    super.initState();
    initAds();
    createImageLabeler();
    initCameraController();

    // TODO look into translation to spanish
    //initTranslation();
  }

  initCameraController() {
    if (_cameras.isEmpty) {
      log("No camera!");
      return;
    }
    controller = CameraController(_cameras[0], ResolutionPreset.high);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      controller.startImageStream((image) => {
        if (!isBusy) {isBusy = true, img = image, doImageLabeling()}
      });
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            log('User denied camera access.');
            break;
          default:
            log('Handle other errors.');
            break;
        }
      }
    });
  }

  createImageLabeler() async {
    final modelPath = await _getModel('assets/ml/efficientnet.tflite');
    final options = LocalLabelerOptions(modelPath: modelPath);
    imageLabeler = ImageLabeler(options: options);
  }
  Future<String> _getModel(String assetPath) async {
    if (Platform.isAndroid) {
      return 'flutter_assets/$assetPath';
    }
    final path = '${(await getApplicationSupportDirectory()).path}/$assetPath';
    await Directory(dirname(path)).create(recursive: true);
    final file = File(path);
    if (!await file.exists()) {
      final byteData = await rootBundle.load(assetPath);
      await file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    }
    return file.path;
  }

  initAds() {
    final BannerAdListener listener = BannerAdListener(
      // Called when an ad is successfully received.
      onAdLoaded: (Ad ad) => log('Ad loaded.'),
      // Called when an ad request failed.
      onAdFailedToLoad: (Ad ad, LoadAdError error) {
        // Dispose the ad here to free resources.
        ad.dispose();
        log('Ad failed to load: $error');
      },
      // Called when an ad opens an overlay that covers the screen.
      onAdOpened: (Ad ad) => log('Ad opened.'),
      // Called when an ad removes an overlay that covers the screen.
      onAdClosed: (Ad ad) => log('Ad closed.'),
      // Called when an impression occurs on the ad.
      onAdImpression: (Ad ad) => log('Ad impression.'),
    );

    topBanner = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      size: AdSize.banner,
      request: AdRequest(),
      listener: listener,
    );

    topBanner.load();
  }

  /*
  bool isEnglishDownloaded = false;
  bool isSpanishDownloaded = false;
  final _modelManager = OnDeviceTranslatorModelManager();
  final _sourceLanguage = TranslateLanguage.english;
  final _targetLanguage = TranslateLanguage.spanish;
  late final _onDeviceTranslator = OnDeviceTranslator(
      sourceLanguage: _sourceLanguage, targetLanguage: _targetLanguage);

  initTranslation() async {
    isEnglishDownloaded = await _modelManager.isModelDownloaded(TranslateLanguage.english.bcpCode);
    isSpanishDownloaded = await _modelManager.isModelDownloaded(TranslateLanguage.spanish.bcpCode);

    if (!isEnglishDownloaded) {
      isEnglishDownloaded = await _modelManager.downloadModel(
          TranslateLanguage.english.bcpCode);
    }
    if (!isSpanishDownloaded) {
      isSpanishDownloaded = await _modelManager.downloadModel(
          TranslateLanguage.spanish.bcpCode);
    }
  }

  Future<String> translateText(String text) async {
    final String response = await _onDeviceTranslator.translateText(text);
    return response;
  }
*/
  log(String message) {
    // todo setup logging
  }

  doImageLabeling() async {
    result = "";
    InputImage inputImg = getInputImage();
    final List<ImageLabel> labels = await imageLabeler.processImage(inputImg);
    for (ImageLabel label in labels) {
      final String text = label.label;
      final int index = label.index;
      final double confidence = label.confidence;
      result += "$text  ${confidence.toStringAsFixed(2)}\n";
    }
    setState(() {
      result;
      isBusy = false;
    });
  }

  InputImage getInputImage() {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in img!.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(img!.width.toDouble(), img!.height.toDouble());

    final camera = _cameras[0];
    final imageRotation =
        InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    // if (imageRotation == null) return;

    final inputImageFormat =
        InputImageFormatValue.fromRawValue(img!.format.raw);
    // if (inputImageFormat == null) return null;

    final planeData = img!.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation!,
      inputImageFormat: inputImageFormat!,
      planeData: planeData,
    );

    final inputImage =
        InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

    return inputImage;
  }

  @override
  void dispose() {
    controller.dispose();
    topBanner.dispose();
    //_onDeviceTranslator.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }

    return MaterialApp(
      home: Builder(builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('QueSon : detect objects'),
          ),
          body: Column(
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CameraPreview(controller),
                    Container(
                      margin: const EdgeInsets.only(left: 10, bottom: 10),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          result,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 35, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.center,
                width: topBanner.size.width.toDouble(),
                height: topBanner.size.height.toDouble(),
                color: Colors.red,
                child: topBanner != null
                    ? AdWidget(ad: topBanner)
                    : const Text("Ad space"),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class NoCameraScreen extends StatefulWidget {
  const NoCameraScreen({Key? key}) : super(key: key);

  @override
  State<NoCameraScreen> createState() => _NoCameraScreenState();
}

class _NoCameraScreenState extends State<NoCameraScreen> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
