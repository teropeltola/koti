import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../logic/state.dart';

part 'device_state.dart';

class DeviceCubit extends Cubit<DeviceState> {
  DeviceCubit() : super(DeviceInitial());

  void install(String name) {
    emit(DeviceInitial());
  }

  void setState(State newState) {
    emit(DeviceInitial.setState(newState));
  }
}
