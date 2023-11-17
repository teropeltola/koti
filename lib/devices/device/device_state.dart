part of 'device_cubit.dart';

@immutable
abstract class DeviceState {}

class DeviceInitial extends DeviceState {
  String name = '';
  State state = State();

  DeviceInitial();

  DeviceInitial.setState(State newState) {
    state = newState;
  }
}
