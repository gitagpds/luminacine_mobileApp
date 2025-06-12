import 'package:flutter/material.dart';
import 'package:luminacine/models/movie_model.dart';
import 'package:luminacine/pages/user_pages/movie_detail_page.dart';

class UserMovieCard extends StatelessWidget {
  final Movie movie;

  const UserMovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = movie.posterUrl != null && movie.posterUrl!.isNotEmpty;

    final releaseYear = (() {
      try {
        final date = DateTime.tryParse(movie.releaseDate ?? '');
        return date != null ? date.year.toString() : 'Unknown';
      } catch (e) {
        return 'Unknown';
      }
    })();

    return SizedBox(
      width: 240,
      height: 290, // fixed height to avoid overflow
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 4,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster
            Container(
              height: 160, // Adjusted to leave more space for text/buttons
              width: double.infinity,
              color: Colors.grey[900],
              child: hasImage
                  ? Image.network(
                      movie.posterUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(child: Icon(Icons.error_outline)),
                    )
                  : const Center(
                      child: Icon(Icons.hide_image_outlined,
                          color: Colors.white54, size: 40)),
            ),

            // Movie Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title ?? 'No Title',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          movie.genre ?? 'No Genre',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.yellow,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        releaseYear,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        backgroundColor: theme.colorScheme.secondary,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                MovieDetailPage(idMovie: movie.idMovie!),
                          ),
                        );
                      },
                      child: const Text('Detail'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
