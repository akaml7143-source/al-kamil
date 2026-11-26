import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter_compass/flutter_compass.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color _qiblaBlack = Color(0xFF111329);
const Color _qiblaPanel = Color(0xC9252B4A);
const Color _qiblaGold = Color(0xFFC9B9FF);
const Color _qiblaTeal = Color(0xFF9D8CFF);
const Color _qiblaIvory = Color(0xFFF4F1FF);
const Color _qiblaMuted = Color(0xFFC6C2DC);

const double _kaabaLatitude = 21.4225;
const double _kaabaLongitude = 39.8262;

class QiblaCity {
  const QiblaCity(this.id, this.name, this.latitude, this.longitude);
  final String id;
  final String name;
  final double latitude;
  final double longitude;
}

const List<QiblaCity> qiblaCities = [
  QiblaCity('baghdad', 'بغداد', 33.3152, 44.3661),
  QiblaCity('basra', 'البصرة', 30.5085, 47.7804),
  QiblaCity('maysan', 'العمارة – ميسان', 31.8359, 47.1440),
  QiblaCity('najaf', 'النجف', 32.0003, 44.3354),
  QiblaCity('karbala', 'كربلاء', 32.6160, 44.0249),
  QiblaCity('nasiriyah', 'الناصرية – ذي قار', 31.0539, 46.2572),
  QiblaCity('kut', 'الكوت – واسط', 32.5128, 45.8182),
  QiblaCity('hillah', 'الحلة – بابل', 32.4837, 44.4274),
  QiblaCity('diwaniyah', 'الديوانية', 31.9929, 44.9255),
  QiblaCity('samawah', 'السماوة – المثنى', 31.3187, 45.2806),
  QiblaCity('kirkuk', 'كركوك', 35.4681, 44.3922),
  QiblaCity('mosul', 'الموصل – نينوى', 36.34, 43.13),
  QiblaCity('erbil', 'أربيل', 36.19, 44.01),
  QiblaCity('sulaymaniyah', 'السليمانية', 35.56, 45.44),
  QiblaCity('duhok', 'دهوك', 36.86, 42.99),
  QiblaCity('tikrit', 'تكريت – صلاح الدين', 34.61, 43.68),
  QiblaCity('ramadi', 'الرمادي – الأنبار', 33.42, 43.31),
  QiblaCity('baqubah', 'بعقوبة – ديالى', 33.75, 44.64),
];

/// Initial great-circle bearing from a location to the Kaaba, clockwise from true north.
double calculateQiblaBearing(double latitude, double longitude) {
  final lat1 = latitude * math.pi / 180;
  const lat2 = _kaabaLatitude * math.pi / 180;
  final deltaLongitude = (_kaabaLongitude - longitude) * math.pi / 180;
  final y = math.sin(deltaLongitude) * math.cos(lat2);
  final x = math.cos(lat1) * math.sin(lat2) -
      math.sin(lat1) * math.cos(lat2) * math.cos(deltaLongitude);
  final degrees = math.atan2(y, x) * 180 / math.pi;
  return (degrees + 360) % 360;
}

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  static const _cityKey = 'qibla_city';
  String _cityId = 'baghdad';
  String _cityName = 'بغداد';
  double _latitude = 33.3152;
  double _longitude = 44.3661;
  double? _heading;
  bool _loading = true;
  bool _sensorUnavailable = false;
  StreamSubscription<CompassEvent>? _subscription;

  double get _bearing => calculateQiblaBearing(_latitude, _longitude);
  double get _relativeBearing =>
      _heading == null ? _bearing : (_bearing - _heading! + 360) % 360;

  @override
  void initState() {
    super.initState();
    _loadCity();
    _listenToCompass();
  }

  void _listenToCompass() {
    final stream = FlutterCompass.events;
    if (stream == null) {
      _sensorUnavailable = true;
      return;
    }
    _subscription = stream.listen(
      (event) {
        if (!mounted) return;
        final value = event.heading;
        setState(() {
          if (value == null || !value.isFinite) {
            _sensorUnavailable = true;
          } else {
            _heading = (value + 360) % 360;
            _sensorUnavailable = false;
          }
        });
      },
      onError: (_) {
        if (mounted) setState(() => _sensorUnavailable = true);
      },
    );
  }

  Future<void> _loadCity() async {
    final preferences = await SharedPreferences.getInstance();
    final savedId = preferences.getString(_cityKey) ??
        preferences.getString('prayer_times_city') ??
        'baghdad';
    final savedCity = qiblaCities.where((city) => city.id == savedId);
    if (savedCity.isNotEmpty) {
      final city = savedCity.first;
      _cityId = city.id;
      _cityName = city.name;
      _latitude = city.latitude;
      _longitude = city.longitude;
    } else if (savedId == 'custom') {
      _cityId = 'custom';
      _cityName = 'موقع مخصص';
      _latitude = preferences.getDouble('prayer_times_latitude') ?? 33.3152;
      _longitude = preferences.getDouble('prayer_times_longitude') ?? 44.3661;
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _chooseCity() async {
    final selected = await showModalBottomSheet<QiblaCity>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                height: MediaQuery.of(sheetContext).size.height * 0.72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Color(0xEE34356C), Color(0xF2252B4A), Color(0xEE392B62)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _qiblaGold.withValues(alpha: 0.48)),
                  boxShadow: [BoxShadow(color: _qiblaTeal.withValues(alpha: 0.12), blurRadius: 24)],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      child: Row(
                        children: [
                          const Icon(Icons.location_city_rounded, color: _qiblaTeal, size: 21),
                          const SizedBox(width: 9),
                          const Expanded(
                            child: Text('اختر مدينتك', style: TextStyle(
                              color: _qiblaGold, fontSize: 18, fontWeight: FontWeight.bold,
                            )),
                          ),
                          IconButton(
                            tooltip: 'إغلاق',
                            onPressed: () => Navigator.pop(sheetContext),
                            icon: const Icon(Icons.close_rounded, color: _qiblaMuted),
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: Color(0x44C9B9FF), height: 1),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: qiblaCities.length,
                        itemBuilder: (context, index) {
                          final city = qiblaCities[index];
                          final selected = city.id == _cityId;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                            child: Material(
                              color: selected ? _qiblaTeal.withValues(alpha: 0.12) : Colors.transparent,
                              borderRadius: BorderRadius.circular(13),
                              child: ListTile(
                                key: ValueKey('qibla_city_${city.id}'),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                                title: Text(city.name, style: TextStyle(
                                  color: selected ? _qiblaGold : _qiblaIvory,
                                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                                )),
                                trailing: selected
                                    ? const Icon(Icons.check_circle_rounded, color: _qiblaTeal)
                                    : const Icon(Icons.chevron_left_rounded, color: _qiblaMuted),
                                onTap: () => Navigator.pop(sheetContext, city),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    if (selected == null) return;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_cityKey, selected.id);
    if (!mounted) return;
    setState(() {
      _cityId = selected.id;
      _cityName = selected.name;
      _latitude = selected.latitude;
      _longitude = selected.longitude;
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  String _formatDegrees(double value) => '${value.toStringAsFixed(1)}°';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _qiblaBlack,
        appBar: AppBar(
          toolbarHeight: 70,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleSpacing: 8,
          title: Row(
            children: [
              _QiblaGlassSurface(
                radius: 22,
                child: IconButton(
                  tooltip: 'رجوع',
                  onPressed: () => Navigator.maybePop(context),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 17, color: Color(0xFFF4F0FF)),
                ),
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: Text('اتجاه القبلة', style: TextStyle(color: Color(0xFFF4F0FF), fontSize: 17, fontWeight: FontWeight.w700)),
              ),
              _QiblaGlassSurface(
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
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: _qiblaGold))
            : ListView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                children: [
                  _QiblaGlassSurface(radius: 20,
                    child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: _qiblaPanel.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _qiblaGold.withValues(alpha: 0.48)),
                      boxShadow: [BoxShadow(color: _qiblaTeal.withValues(alpha: 0.08), blurRadius: 18)],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: _qiblaTeal),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('الموقع المعتمد', style: TextStyle(color: _qiblaMuted, fontSize: 11)),
                              Text(_cityName, key: const Key('qibla_selected_city'),
                                style: const TextStyle(color: _qiblaIvory, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        TextButton(
                          key: const Key('qibla_city_picker'),
                          onPressed: _chooseCity,
                          child: const Text('تغيير', style: TextStyle(color: _qiblaTeal)),
                        ),
                      ],
                    ),
                  )
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: SizedBox(
                      width: 292,
                      height: 292,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          _QiblaGlassSurface(radius: 141,
                            child: Container(
                            width: 282,
                            height: 282,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _qiblaPanel,
                              border: Border.all(color: _qiblaGold, width: 2),
                              boxShadow: [BoxShadow(
                                color: _qiblaGold.withValues(alpha: 0.10),
                                blurRadius: 25,
                                spreadRadius: 3,
                              )],
                            ),
                          )
                          ),
                          Transform.rotate(
                            angle: -(_heading ?? 0) * math.pi / 180,
                            child: SizedBox(
                              width: 260,
                              height: 260,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  const Positioned(top: 7, child: Text('شمال', style: TextStyle(color: _qiblaGold, fontWeight: FontWeight.bold))),
                                  const Positioned(bottom: 7, child: Text('جنوب', style: TextStyle(color: _qiblaMuted))),
                                  const Positioned(left: 7, child: Text('شرق', style: TextStyle(color: _qiblaMuted))),
                                  const Positioned(right: 7, child: Text('غرب', style: TextStyle(color: _qiblaMuted))),
                                  Container(
                                    width: 2,
                                    height: 220,
                                    color: _qiblaMuted.withValues(alpha: 0.16),
                                  ),
                                  Container(
                                    width: 220,
                                    height: 2,
                                    color: _qiblaMuted.withValues(alpha: 0.16),
                                  ),
                                  Transform.rotate(
                                    angle: _bearing * math.pi / 180,
                                    child: const Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.navigation_rounded, size: 65, color: _qiblaTeal),
                                        SizedBox(height: 4),
                                        Icon(Icons.circle, size: 9, color: _qiblaGold),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _qiblaBlack,
                              border: Border.all(color: _qiblaGold, width: 1.5),
                            ),
                            child: const Icon(Icons.mosque_rounded, color: _qiblaGold, size: 34),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _QiblaGlassSurface(radius: 16,
                    child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _qiblaPanel,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _qiblaTeal.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      children: [
                        const Text('اتجاه القبلة من الشمال الحقيقي', style: TextStyle(color: _qiblaMuted, fontSize: 12)),
                        const SizedBox(height: 5),
                        Text(_formatDegrees(_bearing), key: const Key('qibla_bearing'),
                          style: const TextStyle(color: _qiblaGold, fontSize: 34, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(children: [
                              const Text('اتجاه الهاتف', style: TextStyle(color: _qiblaMuted, fontSize: 11)),
                              Text(_heading == null ? '—' : _formatDegrees(_heading!),
                                key: const Key('qibla_heading'),
                                style: const TextStyle(color: _qiblaIvory, fontSize: 17)),
                            ]),
                            Column(children: [
                              const Text('زاوية التوجيه', style: TextStyle(color: _qiblaMuted, fontSize: 11)),
                              Text(_formatDegrees(_relativeBearing),
                                style: const TextStyle(color: _qiblaTeal, fontSize: 17, fontWeight: FontWeight.bold)),
                            ]),
                          ],
                        ),
                      ],
                    ),
                  )
                  ),
                  const SizedBox(height: 14),
                  if (_sensorUnavailable || _heading == null)
                    _QiblaGlassSurface(radius: 12,
                      child: Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: const Color(0xFF202542),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'حساب اتجاه القبلة متاح، لكن بوصلة الهاتف غير متاحة حالياً أو لم ترسل قراءة. يمكنك الاعتماد على زاوية القبلة الرقمية، أو تجربة الجهاز في مكان مفتوح بعيداً عن المعادن والمغناطيس.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: _qiblaIvory, height: 1.8, fontSize: 12),
                      ),
                    )
                    )
                  else
                    const Text(
                      'حرّك الهاتف ببطء حتى يتجه سهم القبلة إلى أعلى الشاشة. ابتعد عن مصادر التشويش المغناطيسي.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _qiblaMuted, height: 1.8, fontSize: 12),
                    ),
                  const SizedBox(height: 12),
                  const Text(
                    'ملاحظة: دقة الاتجاه تعتمد على معايرة بوصلة الجهاز وخلو المكان من التشويش المغناطيسي. الحساب الجغرافي يعمل محلياً دون إنترنت.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _qiblaMuted, height: 1.8, fontSize: 11),
                  ),
                ],
              ),
      ),
    );
  }
}


class _QiblaGlassSurface extends StatelessWidget {
  const _QiblaGlassSurface({required this.child, required this.radius});

  final Widget child;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: child,
      ),
    );
  }
}
