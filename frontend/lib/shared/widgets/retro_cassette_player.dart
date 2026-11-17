import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class RetroCassettePlayer extends StatefulWidget {
  const RetroCassettePlayer({super.key});

  @override
  State<RetroCassettePlayer> createState() => _RetroCassettePlayerState();
}

class _RetroCassettePlayerState extends State<RetroCassettePlayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinCtrl;
  bool _isPlaying = false;
  int _currentTrackIdx = 0;

  final List<Map<String, String>> _playlist = [
    {'title': '1998 Midnight Lo-Fi', 'artist': 'Retro Radio', 'duration': '3:45'},
    {'title': 'Autumn Rain & Piano', 'artist': 'Nostalgia Tape', 'duration': '2:50'},
    {'title': 'Stranger Coffee Shop', 'artist': 'Acoustic Dreams', 'duration': '4:12'},
    {'title': 'Cassette Memories Side-A', 'artist': 'The Muse Ambient', 'duration': '3:20'},
  ];

  @override
  void initState() {
    super.initState();
    _spinCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4));
  }

  @override
  void dispose() {
    _spinCtrl.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _spinCtrl.repeat();
      } else {
        _spinCtrl.stop();
      }
    });
  }

  void _nextTrack() {
    setState(() {
      _currentTrackIdx = (_currentTrackIdx + 1) % _playlist.length;
    });
  }

  void _prevTrack() {
    setState(() {
      _currentTrackIdx = (_currentTrackIdx - 1 + _playlist.length) % _playlist.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final track = _playlist[_currentTrackIdx];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2430),
        border: Border.all(color: const Color(0xFF3B4860), width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: const Color(0xFF003399),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            child: Row(
              children: [
                const Icon(Icons.radio, size: 11, color: Colors.amber),
                const SizedBox(width: 4),
                const Expanded(
                  child: Text(
                    'RETRO CASSETTE DECK',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _isPlaying ? Colors.greenAccent : Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              children: [
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C3545),
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(color: const Color(0xFF18202C), width: 1),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0ECE1),
                            border: Border.all(color: const Color(0xFFCC3300), width: 1),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'SIDE A • STEREO HI-FI',
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 7,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown.shade800,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildTapeSprocket(),
                          _buildTapeSprocket(),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  width: double.infinity,
                  color: const Color(0xFF0B1017),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '♪ ${track['title']}',
                        style: const TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF55FF55),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${track['artist']} [${track['duration']}]',
                        style: const TextStyle(fontFamily: 'Arial', fontSize: 8, color: Color(0xFF88AA88)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildMiniBtn(icon: Icons.skip_previous, onTap: _prevTrack),
                    const SizedBox(width: 4),
                    _buildMiniBtn(
                      icon: _isPlaying ? Icons.pause : Icons.play_arrow,
                      isPrimary: true,
                      onTap: _togglePlay,
                    ),
                    const SizedBox(width: 4),
                    _buildMiniBtn(icon: Icons.skip_next, onTap: _nextTrack),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTapeSprocket() {
    return RotationTransition(
      turns: _spinCtrl,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF444444), width: 2),
        ),
        child: const Center(
          child: Icon(Icons.star, size: 10, color: Color(0xFF555555)),
        ),
      ),
    );
  }

  Widget _buildMiniBtn({required IconData icon, required VoidCallback onTap, bool isPrimary = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isPrimary ? RetroColors.btnPrimary : const Color(0xFFECE9D8),
          border: Border.all(color: isPrimary ? const Color(0xFFCC3300) : const Color(0xFF808080), width: 1),
        ),
        child: Icon(icon, size: 12, color: isPrimary ? Colors.white : Colors.black87),
      ),
    );
  }
}
