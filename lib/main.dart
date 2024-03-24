import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    await _player.setUrl('https://samplelib.com/lib/preview/mp3/sample-15s.mp3');

    _player.play();
  }

  Future<void> _initPlayerFromAsset() async {
    final ByteData data = await rootBundle.load('assets/your_audio_file.mp3');
    final Uint8List bytes = data.buffer.asUint8List();
    await _player.setAudioSource(
      AudioSource.uri(Uri.dataFromBytes(
        bytes,
        mimeType: 'audio/mpeg',
      )),
    );

    _player.play();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Just Audio Demo'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  if (_player.playing) {
                    _player.pause();
                  } else {
                    _player.play();
                  }
                  setState(() {});
                },
                child: Text(_player.playing ? 'Pause' : 'Play'),
              ),
              ElevatedButton(
                onPressed: () {
                  _player.stop();
                  setState(() {});
                },
                child: Text('Stop'),
              ),
              ElevatedButton(
                onPressed: () {
                  _initPlayerFromAsset();
                },
                child: Text('Play From Asset'),
              ),
              StreamBuilder<Duration?>(
                stream: _player.durationStream,
                builder: (context, snapshot) {
                  final duration = snapshot.data ?? Duration.zero;
                  return Text(durationToString(duration));
                },
              ),
              StreamBuilder<Duration>(
                stream: _player.positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  return Text(durationToString(position));
                },
              ),
              StreamBuilder<Duration>(
                stream: _player.positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  final duration = _player.duration ?? Duration.zero;
                  return Slider(
                    value: position.inSeconds.toDouble(),
                    min: 0,
                    max: duration.inSeconds.toDouble(),
                    onChanged: (value) {
                      _player.seek(Duration(seconds: value.toInt()));
                    },
                  );
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.volume_down),
                    onPressed: () {
                      if (_player.volume != null && _player.volume > 0.1) {
                        _player.setVolume(_player.volume - 0.1);
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.volume_up),
                    onPressed: () {
                      if (_player.volume != null && _player.volume < 1.0) {
                        _player.setVolume(_player.volume + 0.1);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String durationToString(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
