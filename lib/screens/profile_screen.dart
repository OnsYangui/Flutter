import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/backup_service.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import '../utils/theme_colors.dart';
import '../widgets/custom_button.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import 'history_screen.dart';
import '../utils/helpers.dart';
import '../utils/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final BackupService _backupService = BackupService();
  bool _isDarkMode = false;
  String _selectedLanguage = 'fr';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      body: Consumer<AuthService>(
        builder: (context, authService, child) {
          final user = authService.currentUser;

          if (authService.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (user == null) {
            return _buildErrorState(authService);
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [const Color(0xFF00BCD4), context.bgColor],
                      stops: const [0.0, 0.45],
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Mon Profil',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          _HeaderIcon(
                            icon: Icons.edit_outlined,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen())),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      _buildModernProfileHeader(user),
                      const SizedBox(height: 30),
                      
                      _buildSectionTitle('Informations personnelles'),
                      _buildSettingsGroup([
                        _SettingsTile(
                          icon: Icons.phone_outlined,
                          title: 'Téléphone',
                          subtitle: user.phone,
                          iconColor: Colors.blue,
                        ),
                        _SettingsTile(
                          icon: Icons.cake_outlined,
                          title: 'Date de naissance',
                          subtitle: _formatDate(user.birthDate),
                          iconColor: Colors.orange,
                        ),
                        if (user.address != null)
                          _SettingsTile(
                            icon: Icons.location_on_outlined,
                            title: 'Adresse',
                            subtitle: user.address,
                            iconColor: Colors.red,
                          ),
                      ]),
                      const SizedBox(height: 25),

                      _buildSectionTitle('Données médicales'),
                      _buildSettingsGroup([
                        _SettingsTile(
                          icon: Icons.water_drop_outlined,
                          title: 'Groupe sanguin',
                          subtitle: user.bloodType,
                          iconColor: Colors.red,
                        ),
                        _SettingsTile(
                          icon: Icons.monitor_weight_outlined,
                          title: 'Poids',
                          subtitle: user.weight != null ? '${user.weight} kg' : 'Non renseigné',
                          iconColor: Colors.teal,
                        ),
                        _SettingsTile(
                          icon: Icons.height,
                          title: 'Taille',
                          subtitle: user.height != null ? '${user.height} cm' : 'Non renseigné',
                          iconColor: Colors.indigo,
                        ),
                      ]),
                      const SizedBox(height: 25),

                      _buildSectionTitle('Paramètres de l\'application'),
                      _buildSettingsGroup([
                        _SettingsTile(
                          icon: Icons.history,
                          title: 'Historique d\'activité',
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryScreen())),
                          iconColor: const Color(0xFF00BCD4),
                        ),
                        _SettingsTile(
                          icon: Icons.settings_outlined,
                          title: 'Paramètres',
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
                          iconColor: Colors.grey,
                        ),
                        _SettingsTile(
                          icon: Icons.cloud_upload_outlined,
                          title: 'Sauvegarder les données',
                          onTap: () async {
                            await _backupService.autoBackup();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Sauvegarde réussie'), backgroundColor: AppColors.success),
                              );
                            }
                          },
                          iconColor: Colors.blueGrey,
                        ),
                      ]),
                      const SizedBox(height: 25),

                      _buildSettingsGroup([
                        _SettingsTile(
                          icon: Icons.logout,
                          title: 'Déconnexion',
                          onTap: () => _showLogoutDialog(authService),
                          iconColor: Colors.red,
                          textColor: Colors.red,
                          showChevron: false,
                        ),
                      ]),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorState(AuthService authService) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_off_outlined, size: 64, color: AppColors.grey400),
            const SizedBox(height: 20),
            const Text('Profil indisponible', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('Veuillez vous reconnecter pour voir votre profil', style: TextStyle(color: AppColors.grey500)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => authService.logout(),
              child: const Text('Aller à la connexion'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernProfileHeader(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppBorderRadius.xl,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: AppColors.grey100),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            backgroundImage: user.profileImageUrl != null ? FileImage(File(user.profileImageUrl!)) : null,
            child: user.profileImageUrl == null ? const Icon(Icons.person, size: 40, color: AppColors.primary) : null,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                Text(
                  user.email,
                  style: const TextStyle(color: AppColors.grey500, fontSize: 14),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _ProfileBadge(
                      label: user.age != null ? '${user.age} yrs' : 'N/A',
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    _ProfileBadge(
                      label: user.bloodType,
                      color: AppColors.error,
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.grey600,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppBorderRadius.lg,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.02),
            blurRadius: 10,
          ),
        ],
        border: Border.all(color: AppColors.grey100),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return Helpers.formatDate(date);
  }

  void _showLogoutDialog(AuthService authService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              authService.logout();
            },
            child: const Text('Déconnecter', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _ProfileBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _ProfileBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppBorderRadius.sm,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color iconColor;
  final Color? textColor;
  final bool showChevron;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    required this.iconColor,
    this.textColor,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: textColor ?? AppColors.black,
        ),
      ),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: showChevron ? const Icon(Icons.chevron_right, size: 20, color: AppColors.grey400) : null,
      onTap: onTap,
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.black, size: 22),
      ),
    );
  }
}
