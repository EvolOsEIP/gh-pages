import 'package:flutter/material.dart';
import 'package:mobile_app/utils/fetchData.dart';
import 'package:mobile_app/services/dataCaching.dart';

class LoginPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if the user is already logged in
    final tokenService = CachingStorageService();
    tokenService.getFromCache('token').then((token) {
      if (token != null) {
            fetchFromApi(
          '/auth/test',
          headers: {'Authorization': "Bearer " + token.toString()}).then((response) {
            if (response.toString().contains('Exception')) {
              tokenService.clearFromCache('token');
            } else {
              Navigator.pushNamed(context, '/roadmap');
            }
          });
    }
    });
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Connexion',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value != null && value.contains('@')
                      ? null
                      : 'Email invalide',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Mot de passe',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value != null && value.length >= 6
                      ? null
                      : 'Mot de passe trop court',
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      postToApi('/auth/login', {
                        'email': emailController.text,
                        'passwordHash': passwordController.text
                      }).then((response) async {
                        if (response != null && !response.isEmpty) {
                          // Store the token in local storage
                          final token = response['token'];
                          final tokenService = CachingStorageService();
                          tokenService.clearFromCache('token');
                          await tokenService.saveInCache(token, 'token');
                          // Store the profile in local storage
                          fetchFromApi('/api/profile/me', headers: {
                            'Authorization': "Bearer " + token.toString()
                          }).then((response) {
                            if (response != null) {
                              tokenService.clearFromCache('profile');
                              tokenService.saveInCache(response.toString(), 'profile');
                          }});
                          // Navigate to the roadmap page
                          Navigator.pushNamed(context, '/roadmap');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Email ou mot de passe incorrect'),
                              duration: Duration(seconds: 2),
                              backgroundColor: Colors.red,  
                            ),
                          );
                        }
                      });
                    }
                  },
                  child: const Text('Se connecter'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text("Pas encore de compte ? S'inscrire"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
