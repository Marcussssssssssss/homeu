import 'package:flutter/material.dart';
import 'dart:async';

import 'package:homeu/app/favorites/homeu_favorites_controller.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/core/localization/homeu_l10n.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:homeu/pages/home/property_item.dart';
import 'package:homeu/pages/home/property_details_screen.dart';

class HomeUFavoritesScreen extends StatefulWidget {
  const HomeUFavoritesScreen({super.key});

  @override
  State<HomeUFavoritesScreen> createState() => _HomeUFavoritesScreenState();
}

class _HomeUFavoritesScreenState extends State<HomeUFavoritesScreen> {
  final HomeUFavoritesController _favoritesController =
      HomeUFavoritesController.instance;

  @override
  void initState() {
    super.initState();
    unawaited(_favoritesController.loadForCurrentTenant());
  }

  Future<void> _handleRemoveFavorite(PropertyItem property) async {
    final result = await _favoritesController.remove(property.id);
    if (!mounted) return;
    switch (result) {
      case HomeUFavouriteActionResult.removed:
        break;
      case HomeUFavouriteActionResult.requiresLogin:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to save favourites.'),
          ),
        );
        break;
      case HomeUFavouriteActionResult.requiresTenant:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Favourites are only available for tenants.'),
          ),
        );
        break;
      case HomeUFavouriteActionResult.policyBlocked:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Favourites are blocked by Supabase RLS. Run favourites_rls.sql in Supabase.',
            ),
          ),
        );
        break;
      case HomeUFavouriteActionResult.failed:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to update favourite. Please try again.'),
          ),
        );
        break;
      case HomeUFavouriteActionResult.busy:
      case HomeUFavouriteActionResult.added:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;

    return AnimatedBuilder(
      animation: _favoritesController,
      builder: (context, _) {
        final favorites = _favoritesController.favorites;

        if (_favoritesController.isLoading &&
            !_favoritesController.hasLoadedForCurrentUser) {
          return Scaffold(
            backgroundColor: context.colors.surface,
            appBar: AppBar(
              title: Text(t.navFavorites),
              backgroundColor: context.colors.surface,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: context.colors.surface,
          appBar: AppBar(
            title: Text(t.navFavorites),
            backgroundColor: context.colors.surface,
          ),
          body: favorites.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.favorite_border_rounded,
                          size: 52,
                          color: context.homeuAccent,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          t.navFavorites,
                          style: TextStyle(
                            color: context.homeuPrimaryText,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          HomeUSession.loggedInRole == HomeURole.tenant
                              ? 'No saved properties yet.'
                              : 'Favourites are available for tenants only.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: context.homeuSecondaryText,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  key: const Key('favorites_list'),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  itemCount: favorites.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final property = favorites[index];

                    return Card(
                      key: Key('favorite_property_${property.id}'),
                      color: context.homeuCard,
                      child: ListTile(
                        title: Text(property.name),
                        subtitle: Text(
                          '${property.location} • ${property.pricePerMonth}',
                        ),
                        trailing: IconButton(
                          key: Key('remove_favorite_${property.id}'),
                          icon: const Icon(Icons.favorite_rounded),
                          color: Colors.red,
                          onPressed: _favoritesController.isBusy(property.id)
                              ? null
                              : () => _handleRemoveFavorite(property),
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => HomeUPropertyDetailsScreen(
                                property: property,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
