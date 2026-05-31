import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motareb/core/extensions/loc_extension.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  RangeValues _currentRangeValues = const RangeValues(500, 20000);
  List<String> _selectedHousingTypes = [];
  List<String> _selectedGenders = [];

  @override
  void initState() {
    super.initState();
    final provider = context.read<HomeProvider>();
    // Initialize with current provider values if set, or defaults
    if (provider.priceRange.end > 0) {
      // Clamp to max 100000 to avoid RangeSlider errors if provider has higher value
      double start = provider.priceRange.start;
      double end = provider.priceRange.end;

      if (end > 100000) end = 100000;
      if (start > end) start = 0;

      _currentRangeValues = RangeValues(start, end);
    }
    _selectedHousingTypes = List.from(provider.filterHousingTypes);
    _selectedGenders = List.from(provider.filterGenders);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        image: Theme.of(context).brightness == Brightness.dark
            ? null
            : DecorationImage(
                image: const NetworkImage(
                  "https://www.transparenttextures.com/patterns/cubes.png",
                ), // Subtle pattern placeholder or just gradient
                colorFilter: ColorFilter.mode(
                  Colors.white.withOpacity(0.9),
                  BlendMode.dstATop,
                ),
                fit: BoxFit.cover,
              ),
      ),
      child: Scaffold(
        backgroundColor:
            Colors.transparent, // Allow container decoration to show
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close, color: Theme.of(context).iconTheme.color),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text(
            context.loc.searchFilter,
            style: GoogleFonts.cairo(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _currentRangeValues = const RangeValues(0, 100000);
                  _selectedHousingTypes.clear();
                  _selectedGenders.clear();
                });
                context.read<HomeProvider>().resetFilters();
              },
              child: Text(
                context.loc.reset,
                style: GoogleFonts.cairo(
                  color: const Color(0xFF39BB5E),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).padding.bottom + 10,
            top: 10,
          ),
          child: Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF39BB5E), Color(0xFF008695)],
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF39BB5E).withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                context.read<HomeProvider>().applyFilters(
                  priceRange: _currentRangeValues,
                  housingTypes: _selectedHousingTypes,
                  genders: _selectedGenders,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  ),
              ),
              child: Text(
                context.loc.applyFilter,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Price Range
                _buildSectionTitle(
                  context.loc.priceRangeMonthly(context.loc.currency),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildPriceInput(
                        context,
                        '${_currentRangeValues.start.round()}',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '-',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildPriceInput(
                        context,
                        '${_currentRangeValues.end.round()}',
                      ),
                    ),
                  ],
                ),
                RangeSlider(
                  values: _currentRangeValues,
                  min: 0,
                  max: 100000,
                  divisions: 100,
                  activeColor: const Color(0xFF39BB5E),
                  inactiveColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade800
                      : Colors.grey.shade300,
                  labels: RangeLabels(
                    _currentRangeValues.start.round().toString(),
                    _currentRangeValues.end.round().toString(),
                  ),
                  onChanged: (RangeValues values) {
                    setState(() {
                      _currentRangeValues = values;
                    });
                  },
                ),

                const SizedBox(height: 20),

                // Housing Type
                _buildSectionTitle(context.loc.housingType),
                _buildMultiSelectOption(
                  context.loc.bedInSharedRoom,
                  'Bed',
                ), // سرير
                _buildMultiSelectOption(
                  context.loc.singleRoom,
                  'Room',
                ), // متقسمه (غرفة)
                _buildMultiSelectOption(
                  context.loc.fullApartment,
                  'Apartment',
                ), // شقة كاملة

                const SizedBox(height: 20),

                // Gender
                _buildSectionTitle(context.loc.allowedGender),
                Row(
                  children: [
                    _buildChip(context.loc.males, 'Male'),
                    const SizedBox(width: 10),
                    _buildChip(context.loc.females, 'Female'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(
        title,
        style: GoogleFonts.cairo(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
    );
  }

  Widget _buildPriceInput(BuildContext context, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFF39BB5E).withOpacity(0.5),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(15),
        color: Theme.of(context).cardTheme.color,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        value,
        style: GoogleFonts.cairo(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
    );
  }

  Widget _buildMultiSelectOption(String text, String value) {
    bool isSelected = _selectedHousingTypes.contains(value);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedHousingTypes.remove(value);
          } else {
            _selectedHousingTypes.add(value);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF39BB5E).withOpacity(0.1)
              : Theme.of(context).cardTheme.color,
          border: Border.all(
            color: isSelected
                ? const Color(0xFF39BB5E)
                : Theme.of(context).dividerColor.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF39BB5E)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF39BB5E)
                      : Colors.grey.shade400,
                  width: 2,
                ),
                shape: BoxShape.circle,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: GoogleFonts.cairo(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? const Color(0xFF39BB5E)
                    : Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, String value) {
    bool isSelected = _selectedGenders.contains(value);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedGenders.remove(value);
            } else {
              _selectedGenders.add(value);
            }
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFF39BB5E), Color(0xFF008695)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : Theme.of(context).cardTheme.color,
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : Theme.of(context).dividerColor,
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF39BB5E).withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            style: GoogleFonts.cairo(
              color: isSelected
                  ? Colors.white
                  : Theme.of(
                      context,
                    ).textTheme.bodyLarge?.color?.withOpacity(0.7),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
