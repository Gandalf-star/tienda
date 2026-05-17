import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});
  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppTheme.gold), onPressed: () => Navigator.pop(context))),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppTheme.goldGradient, shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppTheme.gold.withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 8))],
                ),
                child: const Icon(Icons.lock_outline, size: 36, color: AppTheme.bgPrimary),
              ),
              const SizedBox(height: 28),
              Text('Panel de Administración', style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              const SizedBox(height: 8),
              Text('Ingresa tu contraseña para acceder', style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textMuted)),
              const SizedBox(height: 32),
              TextField(
                controller: _passwordCtrl, obscureText: _obscure,
                style: GoogleFonts.poppins(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Contraseña', prefixIcon: const Icon(Icons.key, color: AppTheme.gold),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppTheme.textMuted),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final ok = context.read<AuthProvider>().login(_passwordCtrl.text);
                    if (ok) {
                      Navigator.pushReplacementNamed(context, '/admin');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Contraseña incorrecta', style: GoogleFonts.poppins()),
                        backgroundColor: AppTheme.error,
                      ));
                    }
                  },
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: Text('Ingresar', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() { _passwordCtrl.dispose(); super.dispose(); }
}
