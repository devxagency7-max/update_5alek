import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motareb/core/extensions/loc_extension.dart';
import '../../../../core/models/property_model.dart';

class PropertyBooking extends StatelessWidget {
  final Property property;
  final int selectedBedCount;
  final Function(int) onBedCountChanged;
  final bool isWholeApartment;
  final Set<String> selectedUnitKeys;
  final bool showSelectionError;
  final Function(bool isWhole, String? key) onUnitSelectionChanged;
  final GlobalKey? unitSelectionKey;

  const PropertyBooking({
    super.key,
    required this.property,
    required this.selectedBedCount,
    required this.onBedCountChanged,
    required this.isWholeApartment,
    required this.selectedUnitKeys,
    required this.showSelectionError,
    required this.onUnitSelectionChanged,
    this.unitSelectionKey,
  });

  @override
  Widget build(BuildContext context) {
    if (!property.bookingEnabled) {
      return Center(
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 25),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.05),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.orange.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(Icons.event_busy, color: Colors.orange.shade800, size: 40),
              const SizedBox(height: 10),
              Text(
                'هذا العقار غير متاح للحجز المباشر حالياً',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade900,
                ),
              ),
              Text(
                'يمكنك التواصل مع المشرف للاستفسار',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (property.bookingMode == 'bed') {
      return _buildBedMode(context);
    } else if (property.isFullApartmentBooking) {
      return _buildFullApartmentFixed(context);
    } else {
      return _buildUnitSelection(context);
    }
  }

  Widget _buildBedMode(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(bottom: 25),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: Theme.of(context).brightness == Brightness.dark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
          border: Border.all(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.bed,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    context.loc.bookBeds,
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              context.loc.roomType(property.localizedType(context)),
              style: GoogleFonts.cairo(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 20),
            // Styled Counter
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 25),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.loc.requestedBedsCount,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCounterButton(
                          context,
                          icon: Icons.remove,
                          onPressed: selectedBedCount > 1
                              ? () => onBedCountChanged(selectedBedCount - 1)
                              : null,
                        ),
                        Container(
                          width: 100,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Theme.of(context).canvasColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Theme.of(context).dividerColor,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            '$selectedBedCount',
                            style: GoogleFonts.cairo(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: property.isHotelApartment
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                        _buildCounterButton(
                          context,
                          icon: Icons.add,
                          onPressed:
                              (property.totalBeds > 0 &&
                                  selectedBedCount < property.totalBeds)
                              ? () => onBedCountChanged(selectedBedCount + 1)
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    // Availability Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: LinearProgressIndicator(
                        value:
                            1 -
                            (selectedBedCount /
                                (property.totalBeds > 0
                                    ? property.totalBeds
                                    : 1)),
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          property.totalBeds - selectedBedCount < 2
                              ? Colors.orange
                              : Theme.of(context).primaryColor,
                        ),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          context.loc.remainingBeds(
                            property.totalBeds - selectedBedCount,
                          ),
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            ),
          ],
        ),
    );
  }

  Widget _buildFullApartmentFixed(BuildContext context) {
    if (property.isHotelApartment) {
      return const SizedBox.shrink();
    }
    return Container(
        margin: const EdgeInsets.only(bottom: 25),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: (property.isHotelApartment
              ? Theme.of(context).primaryColor
              : Theme.of(context).colorScheme.secondary).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: (property.isHotelApartment
                ? Theme.of(context).primaryColor
                : Theme.of(context).colorScheme.secondary).withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (property.isHotelApartment
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).colorScheme.secondary).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.home_work_rounded,
                    color: property.isHotelApartment
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).colorScheme.secondary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.loc.bookApartmentFull,
                        style: GoogleFonts.cairo(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: property.isHotelApartment
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      Text(
                        context.loc.includesComponents,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (!property.isHotelApartment) ...[
              // Composition Summary
              Row(
                children: [
                  Expanded(
                    child: _buildCompositionCard(
                      context,
                      icon: Icons.meeting_room_rounded,
                      count: property.rooms.length.toString(),
                      label: context.loc.rooms,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildCompositionCard(
                      context,
                      icon: Icons.bed_rounded,
                      count: property.rooms
                          .fold<int>(
                            0,
                            (sum, room) => sum + ((room['beds'] as int?) ?? 1),
                          )
                          .toString(),
                      label: context.loc.beds,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildCompositionCard(
                      context,
                      icon: Icons.bathtub_outlined,
                      count: property.bathroomsCount.toString(),
                      label: context.loc.bathrooms,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
            ],
            // Room Types Breakdown
            Builder(
              builder: (context) {
                final typeCounts = <String, int>{};
                for (final room in property.rooms) {
                  final type = room['type']?.toString() ?? 'Other';
                  typeCounts[type] = (typeCounts[type] ?? 0) + 1;
                }

                final arabicTypes = {
                  'Single': context.loc.single,
                  'Double': context.loc.double,
                  'Triple': context.loc.triple,
                  'Quadruple': context.loc.quadruple,
                };

                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: typeCounts.entries.map((entry) {
                    final label = arabicTypes[entry.key] ?? entry.key;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: (property.isHotelApartment
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).colorScheme.secondary).withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: property.isHotelApartment
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).colorScheme.secondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${entry.value} $label',
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: property.isHotelApartment
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
    );
  }

  Widget _buildUnitSelection(BuildContext context) {
    if (property.rooms.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        UnitSelectionWidget(
          key: unitSelectionKey,
          property: property,
          isWholeApartment: isWholeApartment,
          selectedUnitKeys: selectedUnitKeys,
          showError: showSelectionError,
          onSelectionChanged: onUnitSelectionChanged,
        ),
        const SizedBox(height: 25),
      ],
    );
  }

  Widget _buildCounterButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: onPressed == null
              ? Colors.grey.shade200
              : (property.isHotelApartment
                    ? Theme.of(context).primaryColor.withValues(alpha: 0.5)
                    : Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5)),
        ),
        boxShadow: onPressed == null
            ? []
            : [
                BoxShadow(
                  color: (property.isHotelApartment
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).colorScheme.secondary).withValues(alpha: 0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: onPressed == null
              ? Colors.grey
              : (property.isHotelApartment
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).colorScheme.secondary),
        ),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildCompositionCard(
    BuildContext context, {
    required IconData icon,
    required String count,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.grey.shade400, size: 22),
          const SizedBox(height: 5),
          Text(
            count,
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: property.isHotelApartment
                ? Theme.of(context).primaryColor
                : Theme.of(context).colorScheme.secondary,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.cairo(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class UnitSelectionWidget extends StatelessWidget {
  final Property property;
  final bool isWholeApartment;
  final Set<String> selectedUnitKeys;
  final bool showError;
  final Function(bool isWhole, String? key) onSelectionChanged;
  final bool isReadOnly;

  const UnitSelectionWidget({
    super.key,
    required this.property,
    required this.isWholeApartment,
    required this.selectedUnitKeys,
    this.showError = false,
    required this.onSelectionChanged,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final rooms = property.rooms;
    if (rooms.isEmpty) return const SizedBox();

    // Split rooms into rows (max 6 beds per row)
    final List<List<Map<String, dynamic>>> roomRows = [];
    List<Map<String, dynamic>> currentRow = [];
    int currentBedsInRow = 0;

    for (int i = 0; i < rooms.length; i++) {
      final room = rooms[i];
      final bedsCount = (room['beds'] as int?) ?? 1;

      if (currentBedsInRow + bedsCount > 4 && currentRow.isNotEmpty) {
        roomRows.add(currentRow);
        currentRow = [];
        currentBedsInRow = 0;
      }

      currentRow.add({...room, 'originalIndex': i});
      currentBedsInRow += bedsCount;
    }
    if (currentRow.isNotEmpty) {
      roomRows.add(currentRow);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.loc.selectNeed,
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 15),

        if (!property.isHotelApartment) ...[
          // Header: "Whole Apartment" Option
          GestureDetector(
            onTap: () {
              if (isReadOnly) return;
              if (property.bookedUnits.isNotEmpty) {
                return; // Cannot book whole apartment if partially booked
              }
              onSelectionChanged(true, null);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                gradient: isWholeApartment
                    ? LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      )
                    : null,
                color: isWholeApartment
                    ? null
                    : (property.bookedUnits.isNotEmpty
                          ? Theme.of(context).disabledColor.withOpacity(0.1)
                          : Theme.of(context).cardTheme.color),
                borderRadius: BorderRadius.circular(12),
                border: isWholeApartment
                    ? null
                    : Border.all(
                        color: Theme.of(context).dividerColor,
                        width: 1.5,
                      ),
                boxShadow: isWholeApartment
                    ? [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    property.bookedUnits.isNotEmpty
                        ? "غير متاح (محجوز جزئياً)"
                        : context.loc.bookApartmentFull,
                    style: GoogleFonts.cairo(
                      color: isWholeApartment
                          ? ((property.isHotelApartment && property.tier == 'premium')
                                ? Colors.black
                                : Colors.white)
                          : (property.bookedUnits.isNotEmpty
                                ? Theme.of(context).disabledColor
                                : Theme.of(context).textTheme.bodyMedium?.color),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (isWholeApartment)
                    Icon(
                      Icons.check_circle,
                      color: (property.isHotelApartment && property.tier == 'premium')
                          ? Colors.black
                          : Colors.white,
                      size: 22,
                    )
                  else if (property.bookedUnits.isNotEmpty)
                    Icon(
                      Icons.block,
                      color: Theme.of(context).disabledColor,
                      size: 22,
                    ),
                ],
              ),
            ),
          ),
        ],
        if (showError)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              context.loc.selectUnitsFirst,
              style: GoogleFonts.cairo(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

        // Visualizer Rectangle (Now Multi-row)
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: showError ? Colors.red : Theme.of(context).dividerColor,
              width: showError ? 2 : 1,
            ),
            color: showError
                ? Colors.red.withValues(alpha: 0.05)
                : Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).cardTheme.color
                : const Color(0xFFF5F5F5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Column(
              children: roomRows.asMap().entries.map((rowEntry) {
                final rowIndex = rowEntry.key;
                final rowRooms = rowEntry.value;

                return Container(
                  height: 120,
                  decoration: BoxDecoration(
                    border: rowIndex < roomRows.length - 1
                        ? Border(
                            bottom: BorderSide(
                              color: Theme.of(context).dividerColor,
                              width: 1,
                            ),
                          )
                        : null,
                  ),
                  child: Row(
                    children: rowRooms.asMap().entries.map((roomEntry) {
                      final roomInRowIndex = roomEntry.key;
                      final room = roomEntry.value;
                      final globalIndex = room['originalIndex'];

                      final type = room['type'];
                      final bedsCount = (room['beds'] as int?) ?? 1;
                      final roomKey = 'r$globalIndex';

                      final isRoomSelected =
                          !isWholeApartment &&
                          selectedUnitKeys.contains(roomKey);

                      return Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: roomInRowIndex < rowRooms.length - 1
                                ? Border(
                                    left: BorderSide(
                                      color: Theme.of(context).dividerColor,
                                      width: 1,
                                    ),
                                  )
                                : null,
                          ),
                          child: Column(
                            children: [
                              // Room Header
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 5,
                                ),
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[800]?.withValues(alpha: 0.5)
                                    : Colors.grey[200],
                                width: double.infinity,
                                child: Text(
                                  type == 'Single'
                                      ? context.loc.single
                                      : (type == 'Double'
                                            ? context.loc.double
                                            : context.loc.room),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.cairo(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color,
                                  ),
                                ),
                              ),
                              // Unit Area
                              Expanded(
                                child: type == 'Single'
                                    ? _buildSelectableUnit(
                                        context: context,
                                        isSelected: isRoomSelected,
                                        isDisabled: property.bookedUnits
                                            .contains(roomKey),
                                        label: context.loc.room,
                                        onTap: () {
                                          if (isReadOnly) return;
                                          onSelectionChanged(false, roomKey);
                                        },
                                      )
                                    : Row(
                                        // Split for beds
                                        children: List.generate(bedsCount, (
                                          bedIdx,
                                        ) {
                                          final bedKey = '${roomKey}_b$bedIdx';
                                          final isBedSelected =
                                              !isWholeApartment &&
                                              selectedUnitKeys.contains(bedKey);
                                          final isBedBooked = property
                                              .bookedUnits
                                              .contains(bedKey);
                                          return Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: bedIdx < bedsCount - 1
                                                    ? Border(
                                                        left: BorderSide(
                                                          color: Theme.of(
                                                            context,
                                                          ).dividerColor,
                                                        ),
                                                      )
                                                    : null,
                                              ),
                                              child: _buildSelectableUnit(
                                                context: context,
                                                isSelected: isBedSelected,
                                                isDisabled: isBedBooked,
                                                label: context.loc.bed,
                                                onTap: () {
                                                  if (isReadOnly) return;
                                                  onSelectionChanged(
                                                    false,
                                                    bedKey,
                                                  );
                                                },
                                                isSmall: true,
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectableUnit({
    required BuildContext context,
    required bool isSelected,
    required bool isDisabled,
    required String label,
    required VoidCallback onTap,
    bool isSmall = false,
  }) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Color (Unselected or Disabled)
          Container(
            color: isDisabled
                ? Theme.of(context).brightness == Brightness.dark
                      ? Colors.black.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.3)
                : Colors.transparent,
          ),

          if (!isDisabled)
            // Selected Gradient Overlay (Animated Fade)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isSelected ? 1.0 : 0.0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),

          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isDisabled)
                  Icon(
                    Icons.block,
                    color: Theme.of(context).disabledColor,
                    size: isSmall ? 16 : 20,
                  )
                else
                  Icon(
                    isSelected ? Icons.check_circle : Icons.add_circle_outline,
                    color: isSelected
                        ? ((property.isHotelApartment && property.tier == 'premium')
                              ? Colors.black
                              : Colors.white)
                        : Colors.grey.shade400,
                    size: isSmall ? 18 : 22,
                  ),
                const SizedBox(height: 4),
                Text(
                  isDisabled ? (context.isAr ? 'مباع' : 'Sold') : label,
                  style: GoogleFonts.cairo(
                    fontSize: isSmall ? 10 : 12,
                    fontWeight: FontWeight.bold,
                    color: isDisabled
                        ? Theme.of(context).disabledColor
                        : (isSelected
                              ? ((property.isHotelApartment && property.tier == 'premium')
                                    ? Colors.black
                                    : Colors.white)
                              : Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
