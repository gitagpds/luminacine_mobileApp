import 'package:flutter/material.dart';
import 'package:luminacine/models/movie_model.dart';

class ScheduleMovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onEditSchedule;

  const ScheduleMovieCard({
    super.key,
    required this.movie,
    required this.onEditSchedule,
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
          // Bagian Poster (tidak berubah)
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

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Judul dan Genre
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title ?? 'No Title',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
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
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: onEditSchedule,
                        icon: Icon(Icons.calendar_month,
                            size: 16, color: theme.colorScheme.secondary),
                        label: Text('Edit Jadwal',
                            style: TextStyle(
                                color: theme.colorScheme.secondary,
                                fontSize: 12)),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
