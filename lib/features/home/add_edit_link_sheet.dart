import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/models/link_item.dart';
import '../shared/services/link_preview_service.dart';
import '../shared/providers/firestore_providers.dart';
import '../auth/auth_controller.dart';

class AddEditLinkSheet extends ConsumerStatefulWidget {
  final LinkItem? linkToEdit;
  final String? initialUrl;

  const AddEditLinkSheet({super.key, this.linkToEdit, this.initialUrl});

  @override
  ConsumerState<AddEditLinkSheet> createState() => _AddEditLinkSheetState();
}

class _AddEditLinkSheetState extends ConsumerState<AddEditLinkSheet> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  final _linkPreviewService = LinkPreviewService();
  
  bool _isFavorite = false;
  String? _selectedCategoryId;
  String? _imageUrl;
  String? _domain;
  bool _isFetchingPreview = false;

  @override
  void initState() {
    super.initState();
    if (widget.linkToEdit != null) {
      _urlController.text = widget.linkToEdit!.url;
      _titleController.text = widget.linkToEdit!.title;
      _descriptionController.text = widget.linkToEdit!.description;
      _isFavorite = widget.linkToEdit!.favorite;
      _selectedCategoryId = widget.linkToEdit!.categoryId;
      _imageUrl = widget.linkToEdit!.imageUrl;
      _domain = widget.linkToEdit!.domain;
    } else if (widget.initialUrl != null) {
      _urlController.text = widget.initialUrl!;
      // Auto-fetch preview if we have a URL from sharing
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchLinkPreview();
      });
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchLinkPreview() async {
    if (_urlController.text.isEmpty) return;

    setState(() {
      _isFetchingPreview = true;
    });

    try {
      final url = _linkPreviewService.normalizeUrl(_urlController.text.trim());
      final preview = await _linkPreviewService.fetchPreview(url);

      if (mounted) {
        setState(() {
          _titleController.text = preview['title'] ?? '';
          _descriptionController.text = preview['description'] ?? '';
          _imageUrl = preview['imageUrl'];
          _domain = preview['domain'] ?? '';
          _isFetchingPreview = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isFetchingPreview = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch preview: $e')),
        );
      }
    }
  }

  Future<void> _saveLink() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = ref.read(authStateProvider).value?.uid;
    if (userId == null) return;

    final now = DateTime.now();
    final url = _linkPreviewService.normalizeUrl(_urlController.text.trim());

    final link = LinkItem(
      id: widget.linkToEdit?.id ?? '',
      url: url,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      imageUrl: _imageUrl,
      domain: _domain ?? _linkPreviewService.normalizeUrl(url),
      categoryId: _selectedCategoryId,
      favorite: _isFavorite,
      createdAt: widget.linkToEdit?.createdAt ?? now,
      updatedAt: now,
    );

    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      
      if (widget.linkToEdit == null) {
        await firestoreService.addLink(userId, link);
      } else {
        await firestoreService.updateLink(userId, link);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.linkToEdit == null ? 'Link added!' : 'Link updated!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(userCategoriesProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  widget.linkToEdit == null ? 'Add Link' : 'Edit Link',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),

                // URL field
                TextFormField(
                  controller: _urlController,
                  decoration: InputDecoration(
                    labelText: 'URL',
                    hintText: 'https://example.com',
                    prefixIcon: const Icon(Icons.link),
                    suffixIcon: _isFetchingPreview
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.download),
                            onPressed: _fetchLinkPreview,
                            tooltip: 'Fetch preview',
                          ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a URL';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _fetchLinkPreview(),
                ),
                const SizedBox(height: 16),

                // Preview image (if available)
                if (_imageUrl != null && _imageUrl!.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _imageUrl!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 150,
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image, size: 50),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Title field
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description field
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description / Notes',
                    prefixIcon: Icon(Icons.notes),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // Category dropdown
                categories.when(
                  data: (categoryList) {
                    return DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      decoration: const InputDecoration(
                        labelText: 'Category (optional)',
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('No category'),
                        ),
                        ...categoryList.map((category) {
                          return DropdownMenuItem(
                            value: category.id,
                            child: Text(category.name),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryId = value;
                        });
                      },
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (error, _) => Text('Error loading categories: $error'),
                ),
                const SizedBox(height: 16),

                // Favorite toggle
                SwitchListTile(
                  title: const Text('Favorite'),
                  subtitle: const Text('Mark as favorite link'),
                  value: _isFavorite,
                  onChanged: (value) {
                    setState(() {
                      _isFavorite = value;
                    });
                  },
                  secondary: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : null,
                  ),
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveLink,
                        child: Text(widget.linkToEdit == null ? 'Add Link' : 'Save'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
