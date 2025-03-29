import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late SharedPreferences _prefs;
  bool _darkMode = false;
  String _username = '';
  String _language = 'English';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _loadFromPrefs();
  }

  _loadFromPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = _prefs.getBool('darkMode') ?? false;
      _username = _prefs.getString('username') ?? 'Rishabh';
      _language = _prefs.getString('language') ?? 'English';
      _email = _prefs.getString('email') ?? 'xyz@gmail.com';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: Text('Account'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: Icon(Icons.person),
                title: Text('Username'),
                value: Text(_username),
                onPressed: (context) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Enter your username'),
                        content: TextField(
                          onChanged: (value) {
                            setState(() {
                              _username = value;
                            });
                          },
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              _prefs.setString('username', _username);
                              Navigator.of(context).pop();
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              SettingsTile.navigation(
                leading: Icon(Icons.email),
                title: Text('Email'),
                value: Text(_email),
                onPressed: (context) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Enter your email'),
                        content: TextField(
                          onChanged: (value) {
                            setState(() {
                              _email = value;
                            });
                          },
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              _prefs.setString('email', _email);
                              Navigator.of(context).pop();
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
          SettingsSection(
            title: Text('Appearance'),
            tiles: <SettingsTile>[
              SettingsTile.switchTile(
                onToggle: (value) {
                  setState(() {
                    _darkMode = value;
                  });
                  _prefs.setBool('darkMode', value);
                },
                initialValue: _darkMode,
                leading: Icon(Icons.brightness_2),
                title: Text('Dark mode'),
              ),
            ],
          ),
          SettingsSection(
            title: Text('Language'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: Icon(Icons.language),
                title: Text('Language'),
                value: Text(_language),
                onPressed: (context) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Select language'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              title: Text('English'),
                              onTap: () {
                                setState(() {
                                  _language = 'English';
                                });
                                _prefs.setString('language', 'English');
                                Navigator.of(context).pop();
                              },
                            ),
                            ListTile(
                              title: Text('Hindi'),
                              onTap: () {
                                setState(() {
                                  _language = 'Hindi';
                                });
                                _prefs.setString('language', 'Hindi');
                                Navigator.of(context).pop();
                              },
                            ),
                            ListTile(
                              title: Text('Bangla'),
                              onTap: () {
                                setState(() {
                                  _language = 'Bangla';
                                });
                                _prefs.setString('language', 'Bangla');
                                Navigator.of(context).pop();
                              },
                            ),
                            ListTile(
                              title: Text('Urdu'),
                              onTap: () {
                                setState(() {
                                  _language = 'Urdu';
                                });
                                _prefs.setString('language', 'Urdu');
                                Navigator.of(context).pop();
                              },
                            ),
                            ListTile(
                              title: Text('Tamil'),
                              onTap: () {
                                setState(() {
                                  _language = 'Tamil';
                                });
                                _prefs.setString('language', 'Tamil');
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
