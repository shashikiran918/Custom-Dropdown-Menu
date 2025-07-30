// ignore_for_file: must_be_immutable, deprecated_member_use, prefer_typing_uninitialized_variables, unused_field, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile/DrawerMenu/drawer_menu_page.dart';
import 'package:mobile/easy_localization/public_ext.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DropDownMenu extends StatefulWidget {
  const DropDownMenu({Key key}) : super(key: key);

  @override
  State<DropDownMenu> createState() => _DropDownMenuState();
}

class _DropDownMenuState extends State<DropDownMenu> with TickerProviderStateMixin {
  SharedPreferences prefs;
  bool isTDSEnabled = false;
  AnimationController _animationController;
  Animation<double> _fadeAnimation;
  Animation<Offset> _slideAnimation;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry _overlayEntry;
  bool isDropdownOpen = false;
  final GlobalKey _actionKey = GlobalKey();
  Map<String, bool> settingsVisibility = {};

  @override
  void initState() {
    initPrefs();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _removeDropdown();
    super.dispose();
  }

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    if (prefs != null) {
      _loadSettings();
    }
  }

  Future<void> _loadSettings() async {
    setState(() {
      isTDSEnabled = prefs.getBool('isTDSEnabled') ?? false;
      _buildSettingsVisibility();
    });
  }

  void _buildSettingsVisibility() {
    settingsVisibility = {
      'TDS': isTDSEnabled,
      'Template A': true,
      'Template B': true,
      'Template C': true,
    };
    if (settingsVisibility.values.every((v) => v == false)) {
      settingsVisibility = {
        'No Settings Found': true,
      };
    }
  }
  
  void _toggleDropdown() {
    if (isDropdownOpen) {
      _removeDropdown();
    } else {
      _showDropdown();
    }
  }

   void _showDropdown() {
    final RenderBox renderBox = _actionKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final visibleTemplates = settingsVisibility.entries.where((entry) => entry.value).map((entry) => entry.key).toList();
    const double dropdownHeight = 200;
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          offset: Offset(0.0, size.height + 5),
          link: _layerLink,
          showWhenUnlinked: false,
          child: Material(
            elevation: 0,
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: visibleTemplates.contains("No Settings Found") ? 60 : dropdownHeight,
                  ),
                  margin: const EdgeInsets.all(4),
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: visibleTemplates.contains("No Settings Found")
                      ? Center(
                          child: Text(
                            'No Settings Found',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        )
                      : buildGridView(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
    _animationController.forward();
    setState(() {
      isDropdownOpen = true;
    });
  }

  void _removeDropdown() async {
    await _animationController.reverse();
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      isDropdownOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: Builder(
          builder: (context) {
            _removeDropdown();
            return const HomeDrawer();
          }
      ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.color,
        title: Text("Settings".tr(), style: Theme.of(context).textTheme.headline5.copyWith(fontWeight: FontWeight.bold)),
        centerTitle: Theme.of(context).appBarTheme.centerTitle,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: SvgPicture.asset(
                'assets/images/menu.svg',
                width: 30,
                height: 30,
                color: Colors.black87,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        shape: const Border(
            bottom: BorderSide(
              color: Colors.white,
              width: 1,
            )),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             CompositedTransformTarget(
                link: _layerLink,
                child: GestureDetector(
                  key: _actionKey,
                  onTap: _toggleDropdown,
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                              child: Icon(
                                Icons.tune,
                                color: Theme.of(context).primaryColor,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              "Payroll Settings".tr(),
                              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        AnimatedRotation(
                          turns: isDropdownOpen ? 0.5 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            Icons.expand_more,
                            size: 28,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
             ),
          ],
        ),
      ),
    );
  }
  
  GridView buildGridView() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      padding: const EdgeInsets.all(12),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.35,
      physics: const NeverScrollableScrollPhysics(),
      children: [
          _contractFeatureCard(
            svgAsset: 'assets/images/tds_card.svg',
            title: "Tax".tr(),
            progressColor: Colors.pink,
          ),
          _contractFeatureCard(
            svgAsset: 'assets/images/salary.svg',
            title: "Annual Salary".tr(),
            progressColor: Colors.indigo,
          ),
      ],
    );
  }

  Widget _contractFeatureCard({String? title, Color? progressColor, String? svgAsset}) {
    return GestureDetector(
      onTap: () {},
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 2,
        color: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                svgAsset!,
                height: 40,
                width: 40,
                color: progressColor,
              ),
              const SizedBox(height: 14),
              Text(
                title!,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
