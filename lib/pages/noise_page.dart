import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noise_ambient/bloc/cubit/noise_cubit.dart';
import 'package:noise_ambient/widgets/decibelometer.dart';

class NoisePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Noise Meter"),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.center,
        child: BlocBuilder<NoiseCubit, NoiseState>(
          builder: (context, state) {
            if (state is NoiseInitialState) {
              return _empty();
            } else if (state is NoiseChangedState) {
              return _showNoise(state.noiseLevelInDB);
            } else if (state is NoiseErrorState) {
              return _showError();
            } else {
              return _empty();
            }
          },
        ),
      ),
      floatingActionButton: _floatingActionButton(context),
    );
  }

  Widget _floatingActionButton(BuildContext context) =>
      BlocBuilder<NoiseCubit, NoiseState>(
        builder: (_, state) {
          if (state is NoiseInitialState) {
            //context.read<NoiseCubit>().startRecording();
            return _buttonInitial(context.read<NoiseCubit>());
          } else if (state is NoiseIddleState) {
            return _buttonIddle(context.read<NoiseCubit>());
          } else if (state is NoiseChangedState) {
            return _buttonRecording(context.read<NoiseCubit>());
          } else if (state is NoiseErrorState) {
            return _showError();
          } else {
            return _empty();
          }
        },
      );

  Widget _buttonInitial(NoiseCubit noiseCubit) => FloatingActionButton(
      backgroundColor: Colors.blue,
      onPressed: noiseCubit.startRecording,
      child: Icon(Icons.power_settings_new));

  Widget _buttonIddle(NoiseCubit noiseCubit) => FloatingActionButton(
      backgroundColor: Colors.green,
      onPressed: noiseCubit.start,
      child: Icon(Icons.mic));

  Widget _buttonRecording(NoiseCubit noiseCubit) => FloatingActionButton(
      backgroundColor: Colors.red,
      onPressed: noiseCubit.stopRecorder,
      child: Icon(Icons.stop));
  // more code here...
  Widget _empty() => Container();

  Widget _showNoise(double noise) {
    return Center(
        child: Decibelometer(
      level: noise,
      levelRecord: noise,
    ));
  }

  Widget _showError() {
    return Center(child: Text("error"));
  }
}
