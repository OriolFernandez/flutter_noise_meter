part of 'noise_cubit.dart';

@immutable
abstract class NoiseState {
  const NoiseState();
}

class NoiseInitialState extends NoiseState {
  const NoiseInitialState();
}

class NoiseIddleState extends NoiseState {
  const NoiseIddleState();
}

class NoiseChangedState extends NoiseState {
  final double noiseLevelInDB;
  const NoiseChangedState({
    this.noiseLevelInDB,
  });

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is NoiseChangedState && o.noiseLevelInDB == noiseLevelInDB;
  }

  @override
  int get hashCode => noiseLevelInDB.hashCode;
}

class NoiseErrorState extends NoiseState {}
