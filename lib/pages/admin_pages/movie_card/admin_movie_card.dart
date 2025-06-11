import 'package:flutter/material.dart';
import 'package:luminacine/models/movie_model.dart';

class AdminMovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AdminMovieCard({
    super.key,
    required this.movie,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool hasImage =
        movie.posterUrl != null && movie.posterUrl!.isNotEmpty;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 220,
            width: double.infinity,
            color: Colors.grey[900],
            child: hasImage
                ? Image.network(
                    movie.posterUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(Icons.error_outline,
                            color: Colors.white54, size: 40)),
                  )
                : const Center(
                    child: Icon(Icons.hide_image_outlined,
                        color: Colors.white54, size: 40)),
          ),

          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Judul dan Genre
                Text(
                  movie.title ?? 'No Title',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1, // 1. Diubah menjadi 1 baris
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  movie.genre ?? 'No Genre',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: Colors.white70),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(
                    height: 8), 
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _actionButton(context,
                        icon: Icons.edit,
                        label: 'Edit',
                        color: theme.colorScheme.secondary,
                        onPressed: onEdit),
                    _actionButton(context,
                        icon: Icons.delete,
                        label: 'Delete',
                        color: Colors.red.shade400,
                        onPressed: onDelete),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(BuildContext context,
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onPressed}) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: color),
      label: Text(label, style: TextStyle(color: color, fontSize: 12)),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
