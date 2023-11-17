class PlugsUiGetConfig {
  PlugsUiGetConfig({
    required this.leds,
    required this.controls,
  });

  late final Leds leds;
  late final Controls controls;

  PlugsUiGetConfig.fromJson(Map<String, dynamic> json) {
    leds = Leds.fromJson(json['leds'] ?? {});
    controls = Controls.fromJson(json['controls'] ?? {});
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['leds'] = leds.toJson();
    data['controls'] = controls.toJson();
    return data;
  }
}

class Leds {
  Leds({
    required this.mode,
    required this.colors,
    required this.nightMode,
  });

  late final String mode;
  late final Colors colors;
  late final NightMode nightMode;

  Leds.fromJson(Map<String, dynamic> json) {
    mode = json['mode'] ?? '';
    colors = Colors.fromJson(json['colors'] ?? {});
    nightMode = NightMode.fromJson(json['night_mode'] ?? {});
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['mode'] = mode;
    data['colors'] = colors.toJson();
    data['night_mode'] = nightMode.toJson();
    return data;
  }
}

class Colors {
  Colors({
    required this.switchh,
    required this.power,
  });

  late final Switch switchh;
  late final Power power;

  Colors.fromJson(Map<String, dynamic> json) {
    switchh = Switch.fromJson(json['switch:0'] ?? {});

    var jsonPower = json['power'];
    power = ((jsonPower != null) && (jsonPower is Map<String, dynamic>))
        ? Power.fromJson(json['power'])
        : Power(brightness: 0.0);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['switch:0'] = switchh.toJson();
    data['power'] = power.toJson();
    return data;
  }
}

class Switch {
  Switch({
    required this.on,
    required this.off,
  });

  late final On on;
  late final Off off;

  Switch.fromJson(Map<String, dynamic> json)
      : on = On.fromJson(json['on'] ?? {}),
        off = Off.fromJson(json['off'] ?? {});

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['on'] = on.toJson();
    data['off'] = off.toJson();
    return data;
  }
}

class On {
  On({
    required this.rgb,
    required this.brightness,
  });

  late final List<double> rgb;
  late final double brightness;

  On.fromJson(Map<String, dynamic> json)
      : rgb = List.castFrom<dynamic, double>(json['rgb'] ?? []),
        brightness = json['brightness'] ?? 0.0;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['rgb'] = rgb;
    data['brightness'] = brightness;
    return data;
  }
}

class Off {
  Off({
    required this.rgb,
    required this.brightness,
  });

  late final List<double> rgb;
  late final double brightness;

  Off.fromJson(Map<String, dynamic> json)
      : rgb = List.castFrom<dynamic, double>(json['rgb'] ?? []),
        brightness = json['brightness'] ?? 0.0;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['rgb'] = rgb;
    data['brightness'] = brightness;
    return data;
  }
}

class Power {
  Power({
    required this.brightness,
  });

  late final double brightness;

  Power.fromJson(Map<String, dynamic> json)
      : brightness = json['brightness'] ?? 0.0;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['brightness'] = brightness;
    return data;
  }
}

class NightMode {
  NightMode({
    required this.enable,
    required this.brightness,
    required this.activeBetween,
  });

  late final bool enable;
  late final double brightness;
  late final List<String> activeBetween;

  NightMode.fromJson(Map<String, dynamic> json)
      : enable = json['enable'] ?? false,
        brightness = json['brightness'] ?? 0.0,
        activeBetween = List.castFrom<dynamic, String>(json['active_between'] ?? []);

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['enable'] = enable;
    data['brightness'] = brightness;
    data['active_between'] = activeBetween;
    return data;
  }
}

class Controls {
  Controls({
    required this.switchh,
  });

  late final Switch switchh;

  Controls.fromJson(Map<String, dynamic> json)
      : switchh = Switch.fromJson(json['switch:0'] ?? {});

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['switch:0'] = switchh.toJson();
    return data;
  }
}

/*
class PlugsUiGetConfig {
  PlugsUiGetConfig({
    required this.leds,
    required this.controls,
  });

  late final Leds leds;
  late final Controls controls;

  PlugsUiGetConfig.fromJson(Map<String, dynamic> json) {
    leds = Leds.fromJson(json['leds']);
    controls = Controls.fromJson(json['controls']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['leds'] = leds.toJson();
    _data['controls'] = controls.toJson();
    return _data;
  }
}

class Leds {
  Leds({
    required this.mode,
    required this.colors,
    required this.nightMode,
  });

  late final String mode;
  late final Colors colors;
  late final NightMode nightMode;

  Leds.fromJson(Map<String, dynamic> json) {
    mode = json['mode'];
    colors = Colors.fromJson(json['colors']);
    nightMode = NightMode.fromJson(json['night_mode']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['mode'] = mode;
    _data['colors'] = colors.toJson();
    _data['night_mode'] = nightMode.toJson();
    return _data;
  }
}

class Colors {
  Colors({
    required this.switchh,
    required this.power,
  });

  late final Switch switchh;
  late final Power power;

  Colors.fromJson(Map<String, dynamic> json) {
    switchh = Switch.fromJson(json['switch:0']);
    power = Power.fromJson(json['power']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['switch:0'] = switchh.toJson();
    _data['power'] = power.toJson();
    return _data;
  }
}

const _defaultLights = '{"rgb":[0.000,100.000,0.000],"brightness":100.000}';

class Switch {
  Switch({
    required this.on,
    required this.off,
  });

  late final On on;
  late final Off off;

  Switch.fromJson(Map<String, dynamic> json) {

    on = (json['on'] == null) ? On(rgb:[], brightness: 0.0) : On.fromJson(json['on'] ?? _defaultLights);
    off = (json['off'] == null) ? Off(rgb:[], brightness: 0.0) : Off.fromJson(json['off']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['on'] = on.toJson();
    _data['off'] = off.toJson();
    return _data;
  }
}

class On {
  On({
    required this.rgb,
    required this.brightness,
  });

  late final List<double> rgb;
  late final double brightness;

  On.fromJson(Map<String, dynamic> json) {
    rgb = List.castFrom<dynamic, double>(json['rgb']);
    brightness = json['brightness'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['rgb'] = rgb;
    _data['brightness'] = brightness;
    return _data;
  }
}

class Off {
  Off({
    required this.rgb,
    required this.brightness,
  });

  late final List<double> rgb;
  late final double brightness;

  Off.fromJson(Map<String, dynamic> json) {
    rgb = List.castFrom<dynamic, double>(json['rgb']);
    brightness = json['brightness'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['rgb'] = rgb;
    _data['brightness'] = brightness;
    return _data;
  }
}

class Power {
  Power({
    required this.brightness,
  });

  late final double brightness;

  Power.fromJson(Map<String, dynamic> json) {
    brightness = json['brightness'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['brightness'] = brightness;
    return _data;
  }
}

class NightMode {
  NightMode({
    required this.enable,
    required this.brightness,
    required this.activeBetween,
  });

  late final bool enable;
  late final double brightness;
  late final List<String> activeBetween;

  NightMode.fromJson(Map<String, dynamic> json) {
    enable = json['enable'];
    brightness = json['brightness'];
    activeBetween = List.castFrom<dynamic, String>(json['active_between']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['enable'] = enable;
    _data['brightness'] = brightness;
    _data['active_between'] = activeBetween;
    return _data;
  }
}

class Controls {
  Controls({
    required this.switchh,
  });

  late final Switch switchh;

  Controls.fromJson(Map<String, dynamic> json) {
    switchh = Switch.fromJson(json['switch:0']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['switch:0'] = switchh.toJson();
    return _data;
  }
}

 */
