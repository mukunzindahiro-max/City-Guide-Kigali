import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../models/listing.dart';
import '../providers/providers.dart';

class AddEditListingScreen extends ConsumerStatefulWidget {
  final Listing? listing;

  const AddEditListingScreen({super.key, this.listing});

  @override
  ConsumerState<AddEditListingScreen> createState() =>
      _AddEditListingScreenState();
}

class _AddEditListingScreenState extends ConsumerState<AddEditListingScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _contactController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _latController;
  late final TextEditingController _lngController;

  String? _selectedCategory;
  LatLng? _selectedLocation;
  bool _isLoading = false;

  bool get _isEditing => widget.listing != null;

  @override
  void initState() {
    super.initState();
    final listing = widget.listing;
    _nameController = TextEditingController(text: listing?.name ?? '');
    _addressController =
        TextEditingController(text: listing?.address ?? '');
    _contactController =
        TextEditingController(text: listing?.contactNumber ?? '');
    _descriptionController =
        TextEditingController(text: listing?.description ?? '');
    _latController = TextEditingController(
        text: listing != null
            ? listing.latitude.toStringAsFixed(6)
            : '');
    _lngController = TextEditingController(
        text: listing != null
            ? listing.longitude.toStringAsFixed(6)
            : '');
    _selectedCategory = listing?.category;
    if (listing != null) {
      _selectedLocation = LatLng(listing.latitude, listing.longitude);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _descriptionController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final listing = Listing(
        name: _nameController.text.trim(),
        category: _selectedCategory!,
        address: _addressController.text.trim(),
        contactNumber: _contactController.text.trim(),
        description: _descriptionController.text.trim(),
        latitude: _parseCoord(_latController.text)!,
        longitude: _parseCoord(_lngController.text)!,
        createdBy: ref.read(currentUserProvider)!.uid,
      );

      final listingService = ref.read(listingServiceProvider);
      if (_isEditing) {
        await listingService.updateListing(widget.listing!.id!, listing);
      } else {
        await listingService.createListing(listing);
      }

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(_isEditing ? 'Listing updated' : 'Listing created'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _normalizeNumber(String input) {
    return input
        .replaceAll('\u2212', '-') // Unicode minus −
        .replaceAll('\u2013', '-') // en-dash –
        .replaceAll('\u2014', '-') // em-dash —
        .replaceAll('\u00AD', '-') // soft hyphen
        .trim();
  }

  double? _parseCoord(String input) {
    return double.tryParse(_normalizeNumber(input));
  }

  void _updateMapFromFields() {
    final lat = _parseCoord(_latController.text);
    final lng = _parseCoord(_lngController.text);
    if (lat != null && lng != null) {
      setState(() => _selectedLocation = LatLng(lat, lng));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const kigaliCenter = LatLng(-1.9536, 30.0606);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Listing' : 'New Listing'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Place or Service Name',
                  prefixIcon: Icon(Icons.business_rounded),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_rounded),
                ),
                items: listingCategories
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Row(
                            children: [
                              Icon(getCategoryIcon(c), size: 20),
                              const SizedBox(width: 8),
                              Text(c),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v),
                validator: (v) =>
                    v == null ? 'Select a category' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _contactController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Contact Number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description_outlined),
                  alignLabelWithHint: true,
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),

              Text(
                'Location',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap the map to set coordinates, or enter manually',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),

              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 200,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter:
                          _selectedLocation ?? kigaliCenter,
                      initialZoom:
                          _selectedLocation != null ? 15.0 : 13.0,
                      onTap: (_, point) {
                        setState(() {
                          _selectedLocation = point;
                          _latController.text =
                              point.latitude.toStringAsFixed(6);
                          _lngController.text =
                              point.longitude.toStringAsFixed(6);
                        });
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName:
                            'com.example.city_guide_kigali',
                      ),
                      if (_selectedLocation != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _selectedLocation!,
                              width: 40,
                              height: 40,
                              child: Icon(
                                Icons.location_pin,
                                color: theme.colorScheme.primary,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
                        hintText: 'e.g. -1.9518',
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                      onChanged: (_) => _updateMapFromFields(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lngController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                        hintText: 'e.g. 30.0606',
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                      onChanged: (_) => _updateMapFromFields(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _isLoading ? null : _handleSave,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _isEditing
                              ? 'Update Listing'
                              : 'Create Listing',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
