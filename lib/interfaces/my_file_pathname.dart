import 'package:path_provider/path_provider.dart';

const String _pathDivider = '/';

/// general pathname used for different bbong files
class MyFilePathname {

  Future<String> _localPath() async {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
  }

  String _pathName = '';

  /// class async initialization function called in main
  Future<void> init() async {
    _pathName = await _localPath() + _pathDivider;
  }

  /// returns the path name used for internal files
  String name() {
    return _pathName;
  }
}