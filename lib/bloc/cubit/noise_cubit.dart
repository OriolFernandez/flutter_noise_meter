import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:noise_meter/noise_meter.dart';

part 'noise_state.dart';

class NoiseCubit extends Cubit<NoiseState> {
  NoiseCubit() : super(NoiseInitialState());

  bool _isRecording = false;
  StreamSubscription<NoiseReading> _noiseSubscription;
  NoiseMeter _noiseMeter;

  void startRecording() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      print("Noise meter created");
      emit(NoiseIddleState());
      _noiseMeter = new NoiseMeter(_onError);
    });
  }

  void _onData(NoiseReading noiseReading) {
    this._isRecording = true;
    emit(NoiseChangedState(noiseLevelInDB: noiseReading.maxDecibel));
  }

  void _onError(PlatformException e) {
    print(e.toString());
    emit(NoiseErrorState());
    _isRecording = false;
  }

  void start() async {
    try {
      _noiseSubscription = _noiseMeter.noiseStream.listen(_onData);
      print("start listening");
    } catch (exception) {
      emit(NoiseErrorState());
      print(exception);
    }
  }

  void stopRecorder() async {
    try {
      if (_noiseSubscription != null) {
        _noiseSubscription.cancel();
        _noiseSubscription = null;
      }

      this._isRecording = false;
      emit(NoiseIddleState());
    } catch (err) {
      emit(NoiseErrorState());
      print('stopRecorder error: $err');
    }
  }
}
