import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EventRescueCountCard extends StatelessWidget {
  const EventRescueCountCard({
    super.key,
    required this.eventCount,
    required this.rescueCount,
  });

  final String eventCount;
  final String rescueCount;

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: (themeData.brightness == Brightness.dark)
            ? Theme.of(context).colorScheme.secondary
            : Colors.black87,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            children: [
              const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.green,
                size: 35,
              ),
              const SizedBox(
                width: 10,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Events',
                    style: GoogleFonts.inter().copyWith(
                        color: const Color.fromARGB(255, 220, 217, 217),
                        fontSize: 12),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(eventCount,
                      style: GoogleFonts.inter().copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      )),
                ],
              ),
            ],
          ),
          const VerticalDivider(
            color: Colors.white,
            indent: 15,
            endIndent: 15,
          ),
          Row(
            children: [
              const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.green,
                size: 35,
              ),
              const SizedBox(
                width: 10,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rescue Ops',
                    style: GoogleFonts.inter().copyWith(
                        color: const Color.fromARGB(255, 220, 217, 217),
                        fontSize: 12),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    rescueCount,
                    style: GoogleFonts.inter().copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
