import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:n3m_al3bd/core/theme/theme_cubit.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;

class OpenDrawerNotification extends Notification {}

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withOpacity(0.1)
                  : Theme.of(context).colorScheme.primary.withOpacity(0.15),
            ),
            child: Center(
              child: Image.asset('assets/logo.PNG', height: 150, width: 150),
            ),
          ),
          const SizedBox(height: 10),
          _buildDrawerItem(
            context,
            icon: Icons.info_outline_rounded,
            title: 'حول التطبيق',
            onTap: () => _showAboutApp(context),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.help_outline_rounded,
            title: 'الدعم والمساعدة',
            onTap: () => _launchSupport(context),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.star_rate_rounded,
            title: 'تقييم التطبيق',
            onTap: () => _launchRateApp(context),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 24.0, bottom: 8.0),
            child: Row(
              children: [
                Icon(
                  Icons.palette_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Text(
                  'المظهر',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'GeneralFont',
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, currentTheme) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildThemeOption(
                      context,
                      label: 'فاتح',
                      mode: ThemeMode.light,
                      currentMode: currentTheme,
                      icon: Icons.wb_sunny_rounded,
                    ),
                    _buildThemeOption(
                      context,
                      label: 'داكن',
                      mode: ThemeMode.dark,
                      currentMode: currentTheme,
                      icon: Icons.nightlight_round,
                    ),
                    _buildThemeOption(
                      context,
                      label: 'تلقائي',
                      mode: ThemeMode.system,
                      currentMode: currentTheme,
                      icon: Icons.brightness_auto_rounded,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String label,
    required ThemeMode mode,
    required ThemeMode currentMode,
    required IconData icon,
  }) {
    final isSelected = mode == currentMode;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        context.read<ThemeCubit>().updateTheme(mode);
      },
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.surfaceVariant.withOpacity(0.3),
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? colorScheme.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : colorScheme.onSurface,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: isSelected ? colorScheme.primary : colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
        size: 24,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontFamily: 'GeneralFont',
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      horizontalTitleGap: 16,
    );
  }

  Future<void> _launchSupport(BuildContext context) async {
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'الدعم والمساعدة',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontFamily: 'GeneralFont',
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.alternate_email_rounded),
                  title: Text(
                    'حساب X (تويتر)',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'GeneralFont',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    '@3tmvn',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'GeneralFont',
                      fontWeight: FontWeight.w300,
                      color: Colors.grey,
                    ),
                  ),
                  onTap: () async {
                    final url = Uri.parse('https://x.com/3tmvn?s=21');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: Text(
                    'البريد الإلكتروني',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'GeneralFont',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    'ahmed3tman20@icloud.com',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'GeneralFont',
                      fontWeight: FontWeight.w300,
                      fontSize: 12, // Reduced font size
                      color: Colors.grey,
                    ),
                  ),
                  onTap: () async {
                    final Uri emailLaunchUri = Uri(
                      scheme: 'mailto',
                      path: 'ahmed3tman20@icloud.com',
                      query: 'subject=دعم تطبيق نعم العبد',
                    );
                    try {
                      if (!await launchUrl(
                        emailLaunchUri,
                        mode: LaunchMode.externalApplication,
                      )) {
                        throw 'Could not launch';
                      }
                    } catch (e) {
                      if (context.mounted) {
                        await Clipboard.setData(
                          const ClipboardData(text: 'ahmed3tman20@icloud.com'),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Center(
                              child: Text('تم نسخ البريد الإلكتروني'),
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق'),
            ),
          ],
        ),
      ),
    );
  }


  Future<void> _launchRateApp(BuildContext context) async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String packageName = packageInfo.packageName;
    final Uri url;

    if (Platform.isAndroid) {
      url = Uri.parse('market://details?id=$packageName');
    } else if (Platform.isIOS) {
      // Replace with your App Store ID when available
      // For now, it opens the App Store search
      url = Uri.parse(
        'https://apps.apple.com/app/idYOUR_APP_ID',
      ); // Placeholder
    } else {
      return;
    }

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      // Fallback to web link if store app fails
      final webUrl = Uri.parse(
        Platform.isAndroid
            ? 'https://play.google.com/store/apps/details?id=$packageName'
            : 'https://apps.apple.com/app/idYOUR_APP_ID',
      );
      if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    }
  }

  Future<void> _showAboutApp(BuildContext context) async {
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Image.asset('assets/logo.PNG', height: 100, width: 100),
                  const SizedBox(height: 6),
                  Text(
                    'نعم العبد',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontFamily: 'GeneralFont',
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '''نعم العبد تطبيق صُمّم ليكون عونًا حقيقيًا لكل مسلم يسعى للثبات على الصلاة والفرائض اليومية، لا مجرد أداة عابرة في هاتفه.
فلسفة التطبيق تقوم على مبدأ بسيط وقوي:
"ما تراه أمامك كل يوم… يغيّر ما تفعله كل يوم."

ولهذا اعتمد التطبيق على نظام تتبّع يومي يجعل صلاتك واضحة أمامك، فتزداد رغبتك في المواظبة، وتقلّ احتمالات التأجيل، ويتحوّل الالتزام إلى عادة ثابتة.

هذا الأسلوب ليس نظريًا ولا مجرد فكرة، بل هو خلاصة تجربة شخصية امتدّت لثلاث سنوات، كان أثرها — بفضل الله — تغييرًا كاملًا في العلاقة مع الصلاة والالتزام بها. ومع هذا التحوّل ظهرت الحاجة إلى صناعة أداة تساعد الآخرين كما ساعدتني، فكان هذا التطبيق.

لماذا يعمل هذا الأسلوب؟
لأن العقل الإنساني يتفاعل بقوة مع ما يراه باستمرار؛
ولأن علامة ✔️ ترفع هرمون الدوبامين، فتزيد قوة العادة؛
ولأن علامة ❌ تذكير بخسارة لا نحب تكرارها؛
ولأن التوثيق يصنع التزامًا داخليًا لا يمكن تجاهله؛
ولأن ما يُقاس… يمكن تحسينه.

ومع الوقت، تتشكّل داخلك هوية جديدة:
"أنا شخص يحافظ على صلاته."

لماذا صُمّم التطبيق؟
لأجل هدف واحد:
أن يساعدك على الثبات.
الثبات في عبادة هي عمود الدين، وأعظم ما يربط العبد بربّه خمس مرات في اليوم.

ولأجل ذلك جاء التطبيق بخاصيات أساسية تعمل كلها دون إنترنت:
• القرآن الكريم كامل
• أذكار الصباح والمساء
• مواقيت صلاة دقيقة
• نظام تتبّع يومي بسيط وفعّال
• أداء خفيف وسريع لجميع الأجهزة

رسالة التطبيق إليك
لن تحتاج إلى حماس يومين…
بل إلى طريقة تُبقيك ثابتًا، واعيًا، ومراقبًا لعملك كل يوم.
وأملُنا أن يكون نعم العبد سببًا في أن ترى نفسك أفضل كل يوم…
أقرب إلى صلاتك، أقرب إلى ربك، وأقرب إلى نفسك الحقيقية.
نسأل الله أن يعينك، ويثبتك، ويجعل لك من هذا التطبيق نورًا وهداية.''',
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'GeneralFont',
                      height: 1.8,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق'),
            ),
          ],
        ),
      ),
    );
  }
}
