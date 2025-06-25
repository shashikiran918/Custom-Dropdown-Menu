// @dart=2.9

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
      'Template D': true,
      'Template E': true,
      'Template F': true,
      'Template G': true,
      'Template H': true,
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
    final RenderBox renderBox = _actionKey.currentContext.findRenderObject() as RenderBox;
    final size = renderBox.size;
    const double tileHeight = 60.0;
    final visibleTemplates = settingsVisibility.entries.where((entry) => entry.value).map((entry) => entry.key).toList();
    final double dropdownHeight = visibleTemplates.length * tileHeight;
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: 230,
        child: CompositedTransformFollower(
          offset: Offset(30.0, size.height + 5),
          link: _layerLink,
          showWhenUnlinked: false,
          child: Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(8),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: visibleTemplates.length > 5 ? tileHeight * 5 : visibleTemplates.isEmpty ? 50 : dropdownHeight,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: visibleTemplates.isEmpty
                      ? Center(
                    child: Text(
                      'No Settings Found',
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                  )
                      : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: visibleTemplates.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(visibleTemplates[index],style: Theme.of(context).textTheme.subtitle1.copyWith(fontWeight: FontWeight.bold)),
                        onTap: () {
                          _removeDropdown();
                          // if(visibleTemplates[index] == "TDS") {
                          //   Map empContract = {
                          //     "contractEmployeeId": contractEmployeeId,
                          //     "contractId": contractId
                          //   };
                          //   Navigator.of(context).push(MaterialPageRoute(
                          //     builder: (context) => ApplyTds(arguments: empContract),
                          //   ));
                          // }
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry);
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
                  width: 230,
                  margin: const EdgeInsets.only(left: 30,bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Payroll Settings",
                        style: Theme.of(context).textTheme.subtitle1.copyWith(color: Colors.black87, fontSize: 16),
                      ),
                      Container(
                        padding: const EdgeInsets.all(0),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).primaryColor.withOpacity(0.2)
                        ),
                        child: Icon(
                          isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                          size: 25,
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
}
