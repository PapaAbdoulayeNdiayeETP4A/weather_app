import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main_screen.dart';
import 'weather_details_screen.dart';
import '../providers/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String? _searchError;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final searchQuery = _searchController.text.trim();

    // Validation
    if (searchQuery.isEmpty) {
      setState(() {
        _searchError = "Veuillez entrer le nom d'une ville";
      });
      return;
    }

    if (searchQuery.length < 2) {
      setState(() {
        _searchError = "Le nom doit contenir au moins 2 caractères";
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchError = null;
    });

    // Navigation vers l'écran de détails
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WeatherDetailsScreen(cityName: searchQuery),
      ),
    ).then((_) {
      setState(() {
        _isSearching = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors:
                    isDark
                        ? [
                          Colors.grey.shade900,
                          Colors.grey.shade800,
                          Colors.black,
                        ]
                        : [
                          Colors.blueAccent.shade200,
                          Colors.blueAccent.shade400,
                          Colors.blueAccent.shade700,
                        ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        screenHeight -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
                    child: Column(
                      children: [
                        // Bouton de basculement de thème
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () => themeProvider.toggleTheme(),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isDark
                                          ? Icons.light_mode
                                          : Icons.dark_mode,
                                      color: Colors.white,
                                      size: isSmallScreen ? 18 : 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isDark ? 'Clair' : 'Sombre',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isSmallScreen ? 10 : 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: isSmallScreen ? 16 : 20),

                        // Section de recherche
                        _buildSearchSection(isSmallScreen),

                        SizedBox(height: isSmallScreen ? 20 : 30),

                        // Section principale avec logo et titre
                        _buildMainSection(isDark, isSmallScreen),

                        SizedBox(height: isSmallScreen ? 16 : 20),

                        // Section des fonctionnalités
                        if (!isSmallScreen) _buildFeaturesSection(),

                        SizedBox(height: isSmallScreen ? 16 : 20),

                        // Bouton d'exploration aléatoire
                        _buildExplorationButton(isDark, isSmallScreen),

                        SizedBox(height: isSmallScreen ? 10 : 20),

                        // Texte d'aide
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Text(
                            "Recherchez une ville ou explorez aléatoirement",
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 14,
                              color: Colors.white.withOpacity(0.8),
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchSection(bool isSmallScreen) {
    return Column(
      children: [
        // Barre de recherche améliorée
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Colors.white.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: "Rechercher une ville...",
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Container(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  Icons.search,
                  color: Colors.white.withOpacity(0.9),
                  size: isSmallScreen ? 20 : 22,
                ),
              ),
              suffixIcon:
                  _searchController.text.isNotEmpty
                      ? Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchError = null;
                            });
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.clear,
                              color: Colors.white,
                              size: isSmallScreen ? 16 : 18,
                            ),
                          ),
                        ),
                      )
                      : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 20 : 24,
                vertical: isSmallScreen ? 16 : 18,
              ),
            ),
            onChanged: (value) {
              setState(() {
                if (_searchError != null) {
                  _searchError = null;
                }
              });
            },
            onSubmitted: (_) => _performSearch(),
          ),
        ),

        // Message d'erreur amélioré
        if (_searchError != null)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
              decoration: BoxDecoration(
                color: Colors.red.shade400.withOpacity(0.15),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.red.shade300.withOpacity(0.6),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade400.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline,
                      color: Colors.white,
                      size: isSmallScreen ? 14 : 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _searchError!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 11 : 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Bouton de recherche optimisé
        SizedBox(height: isSmallScreen ? 16 : 20),
        Center(
          child: Container(
            width: isSmallScreen ? 200 : 240, // Largeur fixe plus raisonnable
            child: ElevatedButton(
              onPressed: _isSearching ? null : _performSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.25),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 20 : 24,
                  vertical: isSmallScreen ? 12 : 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                  side: BorderSide(
                    color: Colors.white.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                shadowColor: Colors.black.withOpacity(0.2),
              ).copyWith(
                overlayColor: MaterialStateProperty.all(
                  Colors.white.withOpacity(0.1),
                ),
              ),
              child:
                  _isSearching
                      ? SizedBox(
                        height: isSmallScreen ? 18 : 20,
                        width: isSmallScreen ? 18 : 20,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.search,
                              size: isSmallScreen ? 16 : 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "Rechercher",
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainSection(bool isDark, bool isSmallScreen) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 20 : 30),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 5,
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                isDark ? Icons.nightlight_round : Icons.wb_sunny_outlined,
                size: isSmallScreen ? 60 : 80,
                color: Colors.white,
              ),
            ),
            SizedBox(height: isSmallScreen ? 20 : 30),
            Text(
              "Météo Explorer",
              style: TextStyle(
                fontSize: isSmallScreen ? 24 : 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isSmallScreen ? 8 : 12),
            Text(
              "Recherchez la météo d'une ville ou découvrez 5 villes aléatoires",
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFeatureCard(
                icon: Icons.search,
                title: "Recherche",
                subtitle: "Personnalisée",
              ),
              _buildFeatureCard(
                icon: Icons.thermostat,
                title: "Température",
                subtitle: "En temps réel",
              ),
              _buildFeatureCard(
                icon: Icons.water_drop,
                title: "Humidité",
                subtitle: "Détaillée",
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildWeatherIcon(Icons.wb_sunny, Colors.orange.shade300),
              const SizedBox(width: 15),
              _buildWeatherIcon(Icons.cloud, Colors.white),
              const SizedBox(width: 15),
              _buildWeatherIcon(Icons.water_drop, Colors.lightBlue.shade300),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExplorationButton(bool isDark, bool isSmallScreen) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder:
                    (context, animation, secondaryAnimation) =>
                        const MainScreen(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(opacity: animation, child: child);
                },
                transitionDuration: const Duration(milliseconds: 500),
              ),
            );
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 24 : 32,
              vertical: isSmallScreen ? 14 : 18,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.explore,
                  color:
                      isDark
                          ? Colors.grey.shade800
                          : Colors.blueAccent.shade400,
                  size: isSmallScreen ? 20 : 24,
                ),
                const SizedBox(width: 12),
                Text(
                  "Exploration aléatoire",
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color:
                        isDark
                            ? Colors.grey.shade800
                            : Colors.blueAccent.shade400,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
