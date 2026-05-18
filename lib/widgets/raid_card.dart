import 'package:flutter/material.dart';
import '../services/raid_service.dart';

class RaidCard extends StatefulWidget {
  final RaidService raidService;
  final String userId;

  const RaidCard({
    super.key,
    required this.raidService,
    required this.userId,
  });

  @override
  State<RaidCard> createState() => _RaidCardState();
}

class _RaidCardState extends State<RaidCard> {
  bool _userJoined = false;
  static const int _maxSlots = 15;

  Future<void> _handleJoin() async {
    final bool success = await widget.raidService.joinRaid(userId: widget.userId);
    if (success) {
      if (mounted) {
        setState(() {
          _userJoined = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: widget.raidService.filledSlotsStream,
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        final int filledSlots = snapshot.data ?? 0;
        final int remaining = _maxSlots - filledSlots;
        final bool isFull = filledSlots >= _maxSlots;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF10102A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.amber, width: 1.5),
            boxShadow: <BoxShadow>[
              BoxShadow(color: Colors.amber.withValues(alpha: 0.2), blurRadius: 12),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Row(
                children: <Widget>[
                  Icon(Icons.shield_outlined, color: Colors.amber, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'GEO-RAID: Shadow Rift',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: List<Widget>.generate(_maxSlots, (int i) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      height: 10,
                      decoration: BoxDecoration(
                        color: i < filledSlots ? Colors.amber : Colors.white10,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              Text(
                '$filledSlots / $_maxSlots raiders joined',
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (isFull || _userJoined) ? null : _handleJoin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _userJoined
                        ? Colors.green.shade700
                        : isFull
                        ? Colors.grey.shade800
                        : Colors.amber.shade700,
                    disabledBackgroundColor: _userJoined
                        ? Colors.green.shade700
                        : Colors.grey.shade800,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    _userJoined
                        ? '✅  YOU ARE IN THE RAID!'
                        : (isFull ? '🔒  RAID FULL' : '⚔️  JOIN RAID — $remaining left'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
