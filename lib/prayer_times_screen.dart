import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:adhan_dart/adhan_dart.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color _royalBlack = Color(0xFF111329);
const Color _panelBlack = Color(0xC9252B4A);
const Color _gold = Color(0xFFC9B9FF);
const Color _turquoise = Color(0xFF9D8CFF);
const Color _ivory = Color(0xFFF4F1FF);
const Color _mutedIvory = Color(0xFFC6C2DC);

const List<_PrayerCity> _iraqiCities = [
  _PrayerCity('baghdad', 'بغداد', 33.3152, 44.3661),
  _PrayerCity('basra', 'البصرة', 30.5085, 47.7804),
  _PrayerCity('maysan', 'العمارة – ميسان', 31.8359, 47.1440),
  _PrayerCity('najaf', 'النجف', 32.0003, 44.3354),
  _PrayerCity('karbala', 'كربلاء', 32.6160, 44.0249),
  _PrayerCity('nasiriyah', 'الناصرية – ذي قار', 31.0539, 46.2572),
  _PrayerCity('kut', 'الكوت – واسط', 32.5128, 45.8182),
  _PrayerCity('hillah', 'الحلة – بابل', 32.4837, 44.4274),
  _PrayerCity('diwaniyah', 'الديوانية', 31.9929, 44.9255),
  _PrayerCity('samawah', 'السماوة – المثنى', 31.3187, 45.2806),
  _PrayerCity('kirkuk', 'كركوك', 35.4681, 44.3922),
  _PrayerCity('mosul', 'الموصل – نينوى', 36.34, 43.13),
  _PrayerCity('erbil', 'أربيل', 36.19, 44.01),
  _PrayerCity('sulaymaniyah', 'السليمانية', 35.56, 45.44),
  _PrayerCity('duhok', 'دهوك', 36.86, 42.99),
  _PrayerCity('tikrit', 'تكريت – صلاح الدين', 34.61, 43.68),
  _PrayerCity('ramadi', 'الرمادي – الأنبار', 33.42, 43.31),
  _PrayerCity('baqubah', 'بعقوبة – ديالى', 33.75, 44.64),
];

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  static const _cityKey = 'prayer_times_city';
  static const _latitudeKey = 'prayer_times_latitude';
  static const _longitudeKey = 'prayer_times_longitude';
  static const _methodKey = 'prayer_times_method';
  static const _asrKey = 'prayer_times_hanafi_asr';

  String _selectedCity = 'baghdad';
  String _cityName = 'بغداد';
  double _latitude = 33.3152;
  double _longitude = 44.3661;
  String _method = 'jafari';
  bool _hanafiAsr = false;
  bool _loading = true;
  String? _error;
  DateTime _now = DateTime.now();
  PrayerTimes? _today;
  PrayerTimes? _tomorrow;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      final current = DateTime.now();
      if (current.year != _now.year ||
          current.month != _now.month ||
          current.day != _now.day) {
        _now = current;
        _calculateTimes();
      } else {
        setState(() => _now = current);
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final preferences = await SharedPreferences.getInstance();
    final city = preferences.getString(_cityKey) ?? 'baghdad';
    final savedCity = _iraqiCities.where((item) => item.id == city);
    if (savedCity.isNotEmpty) {
      final selected = savedCity.first;
      _selectedCity = selected.id;
      _cityName = selected.name;
      _latitude = selected.latitude;
      _longitude = selected.longitude;
    } else if (city == 'custom') {
      _selectedCity = 'custom';
      _cityName = 'موقع مخصص';
      _latitude = preferences.getDouble(_latitudeKey) ?? 33.3152;
      _longitude = preferences.getDouble(_longitudeKey) ?? 44.3661;
    }
    _method = preferences.getString(_methodKey) ?? 'jafari';
    _hanafiAsr = preferences.getBool(_asrKey) ?? false;
    if (!mounted) return;
    setState(() {
      _loading = false;
      _now = DateTime.now();
    });
    _calculateTimes();
  }

  CalculationParameters _calculationParameters() {
    final parameters = _method == 'tehran'
        ? CalculationMethodParameters.tehran()
        : CalculationMethodParameters.jafari();
    parameters.madhab = _hanafiAsr ? Madhab.hanafi : Madhab.shafi;
    parameters.highLatitudeRule = HighLatitudeRule.middleOfTheNight;
    return parameters;
  }

  PrayerTimes _calculateFor(DateTime date) {
    return PrayerTimes(
      coordinates: Coordinates(_latitude, _longitude),
      date: DateTime(date.year, date.month, date.day),
      calculationParameters: _calculationParameters(),
      precision: false,
    );
  }

  void _calculateTimes() {
    try {
      final current = DateTime.now();
      _today = _calculateFor(current);
      _tomorrow = _calculateFor(current.add(const Duration(days: 1)));
      _error = null;
    } catch (_) {
      _today = null;
      _tomorrow = null;
      _error = 'تعذّر حساب المواقيت لهذه الإحداثيات. تحقق من الموقع المختار.';
    }
    if (mounted) setState(() => _now = DateTime.now());
  }

  Future<void> _saveSettings() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_cityKey, _selectedCity);
    await preferences.setDouble(_latitudeKey, _latitude);
    await preferences.setDouble(_longitudeKey, _longitude);
    await preferences.setString(_methodKey, _method);
    await preferences.setBool(_asrKey, _hanafiAsr);
  }

  Future<void> _selectCity(String? id) async {
    if (id == null) return;
    if (id == 'custom') {
      await _editCoordinates();
      return;
    }
    final city = _iraqiCities.firstWhere((item) => item.id == id);
    setState(() {
      _selectedCity = city.id;
      _cityName = city.name;
      _latitude = city.latitude;
      _longitude = city.longitude;
    });
    await _saveSettings();
    _calculateTimes();
  }

  Future<void> _editCoordinates() async {
    final latitudeController =
        TextEditingController(text: _latitude.toStringAsFixed(4));
    final longitudeController =
        TextEditingController(text: _longitude.toStringAsFixed(4));
    final result = await showDialog<List<double>>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: _panelBlack,
          title: const Text('إدخال الإحداثيات',
              style: TextStyle(color: _gold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'أدخل خط العرض وخط الطول للموقع. تبقى الإحداثيات محفوظة على جهازك.',
                style: TextStyle(color: _mutedIvory, height: 1.7),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('prayer_latitude_input'),
                controller: latitudeController,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true, signed: true),
                style: const TextStyle(color: _ivory),
                decoration: const InputDecoration(
                  labelText: 'خط العرض (Latitude)',
                  labelStyle: TextStyle(color: _turquoise),
                ),
              ),
              TextField(
                key: const Key('prayer_longitude_input'),
                controller: longitudeController,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true, signed: true),
                style: const TextStyle(color: _ivory),
                decoration: const InputDecoration(
                  labelText: 'خط الطول (Longitude)',
                  labelStyle: TextStyle(color: _turquoise),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                final latitude = double.tryParse(
                  latitudeController.text.trim().replaceAll(',', '.'),
                );
                final longitude = double.tryParse(
                  longitudeController.text.trim().replaceAll(',', '.'),
                );
                if (latitude == null ||
                    longitude == null ||
                    latitude < -90 ||
                    latitude > 90 ||
                    longitude < -180 ||
                    longitude > 180) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('أدخل إحداثيات صحيحة ضمن الحدود الجغرافية.'),
                    ),
                  );
                  return;
                }
                Navigator.pop(dialogContext, [latitude, longitude]);
              },
              child: const Text('حفظ الموقع'),
            ),
          ],
        ),
      ),
    );
    latitudeController.dispose();
    longitudeController.dispose();
    if (result == null || !mounted) return;
    setState(() {
      _selectedCity = 'custom';
      _cityName = 'موقع مخصص';
      _latitude = result[0];
      _longitude = result[1];
    });
    await _saveSettings();
    _calculateTimes();
  }

  Future<void> _selectMethod(String? value) async {
    if (value == null) return;
    setState(() => _method = value);
    await _saveSettings();
    _calculateTimes();
  }

  Future<void> _selectAsr(bool value) async {
    setState(() => _hanafiAsr = value);
    await _saveSettings();
    _calculateTimes();
  }

  Future<void> _chooseCity() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: _panelBlack,
          title: const Text('اختر المدينة', style: TextStyle(color: _gold)),
          content: SizedBox(
            width: 320,
            height: 390,
            child: ListView(
              children: [
                for (final city in _iraqiCities)
                  InkWell(
                    key: ValueKey('prayer_city_${city.id}'),
                    onTap: () => Navigator.pop(dialogContext, city.id),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      child: Text(city.name, style: const TextStyle(color: _ivory)),
                    ),
                  ),
                InkWell(
                  onTap: () => Navigator.pop(dialogContext, 'custom'),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    child: Text('إحداثيات مخصصة…', style: TextStyle(color: _turquoise)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (selected != null) await _selectCity(selected);
  }

  Future<void> _chooseMethod() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: _panelBlack,
          title: const Text('طريقة الحساب الفلكي', style: TextStyle(color: _gold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final option in [
                ('jafari', 'الجعفري – مؤسسة ليوا، قم'),
                ('tehran', 'جامعة طهران'),
              ])
                InkWell(
                  onTap: () => Navigator.pop(dialogContext, option.$1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(option.$2, style: const TextStyle(color: _ivory)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (selected != null) await _selectMethod(selected);
  }

  DateTime? _nextPrayerTime() {
    if (_today == null || _tomorrow == null) return null;
    final entries = [
      _today!.fajr.toLocal(),
      _today!.dhuhr.toLocal(),
      _today!.asr.toLocal(),
      _today!.maghrib.toLocal(),
      _today!.isha.toLocal(),
    ];
    for (final time in entries) {
      if (time.isAfter(_now)) return time;
    }
    return _tomorrow!.fajr.toLocal();
  }

  String _nextPrayerName() {
    if (_today == null) return 'الصلاة القادمة';
    final entries = [
      ('الفجر', _today!.fajr.toLocal()),
      ('الظهر', _today!.dhuhr.toLocal()),
      ('العصر', _today!.asr.toLocal()),
      ('المغرب', _today!.maghrib.toLocal()),
      ('العشاء', _today!.isha.toLocal()),
    ];
    for (final entry in entries) {
      if (entry.$2.isAfter(_now)) return entry.$1;
    }
    return 'الفجر';
  }

  String _arabicDigits(String value) {
    const digits = '٠١٢٣٤٥٦٧٨٩';
    return value.split('').map((character) {
      final number = int.tryParse(character);
      return number == null ? character : digits[number];
    }).join();
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return _arabicDigits('$hour:$minute');
  }

  String _formatDate(DateTime date) {
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];
    return '${_arabicDigits(date.day.toString())} ${months[date.month - 1]} ${_arabicDigits(date.year.toString())}';
  }

  String _formatCountdown(DateTime? target) {
    if (target == null) return '—';
    var difference = target.difference(_now);
    if (difference.isNegative) difference = Duration.zero;
    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);
    final seconds = difference.inSeconds.remainder(60);
    return '${_arabicDigits(hours.toString().padLeft(2, '0'))}:${_arabicDigits(minutes.toString().padLeft(2, '0'))}:${_arabicDigits(seconds.toString().padLeft(2, '0'))}';
  }

  @override
  Widget build(BuildContext context) {
    final nextTime = _nextPrayerTime();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _royalBlack,
        appBar: AppBar(
          toolbarHeight: 70,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleSpacing: 8,
          title: Row(
            children: [
              _PrayerGlassSurface(
                radius: 22,
                child: IconButton(
                  tooltip: 'رجوع',
                  onPressed: () => Navigator.maybePop(context),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 17, color: Color(0xFFF4F0FF)),
                ),
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: Text('مواقيت الصلاة', style: TextStyle(color: Color(0xFFF4F0FF), fontSize: 17, fontWeight: FontWeight.w700)),
              ),
              _PrayerGlassSurface(
                radius: 22,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('بحث', style: TextStyle(color: Color(0xFFD5D0E8), fontSize: 11)),
                    SizedBox(width: 7),
                    Icon(Icons.search_rounded, color: Color(0xFFF4F0FF), size: 17),
                  ]),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              key: const Key('prayer_times_refresh'),
              tooltip: 'تحديث المواقيت',
              onPressed: _loading ? null : _calculateTimes,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: _gold))
            : ListView(
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 28),
                children: [
                  _PrayerGlassSurface(radius: 17,
                    child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(17),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF34356C), _panelBlack, Color(0xFF392B62)],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      border: Border.all(color: _gold.withValues(alpha: 0.55)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded,
                                color: _turquoise, size: 19),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _cityName,
                                key: const Key('prayer_current_city'),
                                style: const TextStyle(
                                  color: _ivory,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Icon(Icons.wifi_off_rounded,
                                color: _mutedIvory, size: 16),
                            const SizedBox(width: 4),
                            const Text('حساب دون إنترنت',
                                style: TextStyle(
                                    color: _mutedIvory, fontSize: 10)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(_formatDate(_now),
                            style: const TextStyle(
                                color: _mutedIvory, fontSize: 12)),
                        const SizedBox(height: 16),
                        const Text('الصلاة القادمة',
                            style: TextStyle(
                                color: _mutedIvory, fontSize: 12)),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Text(
                                _nextPrayerName(),
                                style: const TextStyle(
                                  color: _gold,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              _formatCountdown(nextTime),
                              key: const Key('prayer_next_countdown'),
                              style: const TextStyle(
                                color: _turquoise,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ),
                        if (nextTime != null) ...[
                          const SizedBox(height: 4),
                          Text('موعدها ${_formatTime(nextTime)}',
                              style: const TextStyle(
                                  color: _ivory, fontSize: 12)),
                        ],
                      ],
                    ),
                  )
                  ),
                  const SizedBox(height: 14),
                  if (_error != null)
                    _PrayerGlassSurface(radius: 12,
                      child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF252B4A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(_error!,
                          style: const TextStyle(color: _ivory)),
                    )
                    )
                  else
                    _PrayerGlassSurface(radius: 15,
                      child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _panelBlack,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: _gold.withValues(alpha: 0.25)),
                      ),
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(4, 2, 4, 10),
                            child: Row(
                              children: [
                                Icon(Icons.schedule_rounded, color: _turquoise, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'مواقيت الصلاة لهذا اليوم',
                                  style: TextStyle(
                                    color: _ivory,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Spacer(),
                                Icon(Icons.wifi_off_rounded, color: _mutedIvory, size: 14),
                                SizedBox(width: 4),
                                Text('محلياً', style: TextStyle(color: _mutedIvory, fontSize: 10)),
                              ],
                            ),
                          ),
                          const Divider(color: Color(0x33C9B9FF), height: 1),
                          const SizedBox(height: 4),
                          for (final prayer in [
                            _PrayerEntry('الفجر', Icons.nights_stay_rounded,
                                _today!.fajr.toLocal(), 'fajr'),
                            _PrayerEntry('الشروق', Icons.wb_twilight_rounded,
                                _today!.sunrise.toLocal(), 'sunrise',
                                isSunrise: true),
                            _PrayerEntry('الظهر', Icons.wb_sunny_rounded,
                                _today!.dhuhr.toLocal(), 'dhuhr'),
                            _PrayerEntry('العصر', Icons.wb_sunny_outlined,
                                _today!.asr.toLocal(), 'asr'),
                            _PrayerEntry('المغرب', Icons.wb_twilight_rounded,
                                _today!.maghrib.toLocal(), 'maghrib'),
                            _PrayerEntry('العشاء', Icons.dark_mode_rounded,
                                _today!.isha.toLocal(), 'isha'),
                          ])
                            _PrayerTimeTile(
                              entry: prayer,
                              highlighted: !prayer.isSunrise &&
                                  prayer.time == nextTime,
                              formattedTime: _formatTime(prayer.time),
                            ),
                        ],
                      ),
                    )
                    ),
                  const SizedBox(height: 16),
                  _PrayerGlassSurface(radius: 18,
                    child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _panelBlack.withValues(alpha: 0.68),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: _turquoise.withValues(alpha: 0.42)),
                      boxShadow: [BoxShadow(color: _turquoise.withValues(alpha: 0.07), blurRadius: 18)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('إعدادات المواقيت',
                            style: TextStyle(
                                color: _gold,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          key: const Key('prayer_city_dropdown'),
                          onPressed: _chooseCity,
                          icon: const Icon(Icons.location_city_rounded),
                          label: Text('اختيار المدينة: $_cityName'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _ivory,
                            side: BorderSide(color: _gold.withValues(alpha: 0.4)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          key: const Key('prayer_method_dropdown'),
                          onPressed: _chooseMethod,
                          icon: const Icon(Icons.tune_rounded),
                          label: Text(
                            "طريقة الحساب: ${_method == 'tehran' ? 'جامعة طهران' : 'الجعفري – مؤسسة ليوا، قم'}",
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _ivory,
                            side: BorderSide(color: _gold.withValues(alpha: 0.4)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Material(
                          color: _panelBlack,
                          child: SwitchListTile(
                          key: const Key('prayer_hanafi_asr_switch'),
                          contentPadding: EdgeInsets.zero,
                          value: _hanafiAsr,
                          activeThumbColor: _turquoise,
                          title: const Text(
                            'حساب وقت العصر بالطريقة الحنفية',
                            style: TextStyle(color: _ivory, fontSize: 12),
                          ),
                          subtitle: const Text(
                            'إيقافه يستخدم الحساب القياسي (ظل بمقدار واحد)',
                            style: TextStyle(color: _mutedIvory, fontSize: 10),
                          ),
                          onChanged: _selectAsr,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'الإحداثيات: ${_latitude.toStringAsFixed(4)}، ${_longitude.toStringAsFixed(4)}',
                          style: const TextStyle(
                              color: _mutedIvory, fontSize: 10),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          key: const Key('prayer_custom_location_button'),
                          onPressed: _editCoordinates,
                          icon: const Icon(Icons.edit_location_alt_rounded),
                          label: const Text('إدخال موقع بالإحداثيات'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _turquoise,
                            side: BorderSide(
                                color: _turquoise.withValues(alpha: 0.5)),
                          ),
                        ),
                      ],
                    ),
                  )
                  ),
                  const SizedBox(height: 14),
                  _PrayerGlassSurface(radius: 12,
                    child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF202542),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'تنبيه مهم: هذه مواقيت فلكية تقديرية محسوبة محلياً، وقد تختلف دقائق عن الجداول الرسمية بحسب الإحداثيات وطريقة الحساب والاحتياط. وقت المغرب المحسوب فلكياً لا يحسم وحده الحكم الفقهي لدخول المغرب؛ راجع توقيت مكتب مرجع تقليدك، ولا سيما مسألة زوال الحمرة المشرقية. لا يحتاج هذا القسم إلى الإنترنت أو إذن الموقع؛ اختر مدينتك أو أدخل إحداثياتها يدوياً.',
                      style: TextStyle(
                          color: _ivory, height: 1.9, fontSize: 11),
                    ),
                  )
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'مصدر الخوارزمية: مكتبة Adhan Dart 2.0.1، الحسابات الفلكية وفق معادلات Jean Meeus. طريقة الجعفري – قم: فجر 16°، عشاء 14°، ومغرب عند انخفاض الشمس 4° تحت الأفق. طريقة طهران: فجر 17.7°، عشاء 14°، ومغرب 4.5°.',
                    style: TextStyle(
                        color: _mutedIvory, height: 1.8, fontSize: 10),
                  ),
                  const SelectableText(
                    'https://pub.dev/packages/adhan_dart',
                    style: TextStyle(color: _turquoise, fontSize: 10),
                  ),
                ],
              ),
      ),
    );
  }
}

class _PrayerCity {
  const _PrayerCity(this.id, this.name, this.latitude, this.longitude);
  final String id;
  final String name;
  final double latitude;
  final double longitude;
}

class _PrayerEntry {
  const _PrayerEntry(this.name, this.icon, this.time, this.id,
      {this.isSunrise = false});
  final String name;
  final IconData icon;
  final DateTime time;
  final String id;
  final bool isSunrise;
}

class _PrayerTimeTile extends StatelessWidget {
  const _PrayerTimeTile({
    required this.entry,
    required this.highlighted,
    required this.formattedTime,
  });

  final _PrayerEntry entry;
  final bool highlighted;
  final String formattedTime;

  @override
  Widget build(BuildContext context) {
    final color = highlighted ? _turquoise : _ivory;
    return Container(
      key: Key('prayer_time_${entry.id}'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
      decoration: BoxDecoration(
        color: highlighted
            ? _turquoise.withValues(alpha: 0.08)
            : Colors.transparent,
        border: Border(
          bottom: BorderSide(color: _gold.withValues(alpha: 0.12)),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(entry.icon,
              color: entry.isSunrise ? _mutedIvory : _gold, size: 21),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              entry.name,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: highlighted ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ),
          Text(
            formattedTime,
            style: TextStyle(
              color: color,
              fontSize: 17,
              fontWeight: FontWeight.bold,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (highlighted) ...[
            const SizedBox(width: 6),
            const Icon(Icons.notifications_active_rounded,
                color: _turquoise, size: 16),
          ],
        ],
      ),
    );
  }
}


class _PrayerGlassSurface extends StatelessWidget {
  const _PrayerGlassSurface({required this.child, required this.radius});

  final Widget child;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 13, sigmaY: 13),
        child: child,
      ),
    );
  }
}
