import 'package:flutter/material.dart';
import 'package:homeu/app/favorites/homeu_favorites_controller.dart';
import 'package:homeu/core/localization/homeu_l10n.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:homeu/pages/home/property_details_screen.dart';

class HomeUFavoritesScreen extends StatelessWidget {
  const HomeUFavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final favoritesController = HomeUFavoritesController.instance;

    return AnimatedBuilder(
      animation: favoritesController,
      builder: (context, _) {
        final favorites = favoritesController.favorites;

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
                          'No saved properties yet.',
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
                        subtitle: Text('${property.location} • ${property.pricePerMonth}'),
                        trailing: IconButton(
                          key: Key('remove_favorite_${property.id}'),
                          icon: const Icon(Icons.favorite_rounded),
                          color: context.homeuAccent,
                          onPressed: () {
                            favoritesController.remove(property.id);
                          },
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => HomeUPropertyDetailsScreen(property: property),
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

