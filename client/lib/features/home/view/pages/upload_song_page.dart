import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_pallete.dart';
import '../../../../core/utils.dart';
import '../../../../core/widgets/custom_textfield.dart';
import '../../../../core/widgets/loader.dart';
import '../../viewmodel/home_viewmodel.dart';
import '../widgets/audio_wave.dart';

class UploadSongPage extends ConsumerStatefulWidget {
  const UploadSongPage({super.key});

  @override
  ConsumerState<UploadSongPage> createState() => _UploadSongPageState();
}

class _UploadSongPageState extends ConsumerState<UploadSongPage> {
  late final TextEditingController _artistController;
  late final TextEditingController _songNameController;
  var _selectedColor = Pallete.cardColor;
  final formKey = GlobalKey<FormState>();
  File? _selectedImage;
  File? _selectedAudio;

  @override
  void initState() {
    super.initState();
    _artistController = TextEditingController();
    _songNameController = TextEditingController();
  }

  @override
  void dispose() {
    _artistController.dispose();
    _songNameController.dispose();
    super.dispose();
  }

  void selectAudio() async {
    final pickedAudio = await pickAudio();
    if (pickedAudio != null) {
      setState(() {
        _selectedAudio = pickedAudio;
      });
    }
  }

  void selectImage() async {
    final pickedImage = await pickImage();
    if (pickedImage != null) {
      setState(() {
        _selectedImage = pickedImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(homeViewModelProvider.select(
      (value) => value?.isLoading == true,
    ));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload song"),
        actions: [
          IconButton(
            onPressed: () async {
              if (formKey.currentState!.validate() &&
                  _selectedAudio != null &&
                  _selectedImage != null) {
                ref.read(homeViewModelProvider.notifier).uploadSong(
                      audioFile: _selectedAudio!,
                      thumbnailFile: _selectedImage!,
                      songName: _songNameController.text,
                      artist: _artistController.text,
                      color: _selectedColor,
                    );
              } else {
                showSnackBar(context, "Missing fields!");
              }
            },
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: isLoading
          ? const Loader()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: selectImage,
                        child: _selectedImage != null
                            ? SizedBox(
                                height: 150,
                                width: double.infinity,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    _selectedImage!,
                                    fit: BoxFit.cover,
                                    alignment: Alignment.center,
                                  ),
                                ),
                              )
                            : DottedBorder(
                                color: Pallete.borderColor,
                                dashPattern: const [10, 4],
                                radius: const Radius.circular(10),
                                borderType: BorderType.RRect,
                                strokeCap: StrokeCap.round,
                                child: const SizedBox(
                                  width: double.infinity,
                                  height: 150,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.folder_open,
                                        size: 40,
                                      ),
                                      SizedBox(height: 14),
                                      Text(
                                        "Select the thumbnail for your song",
                                        style: TextStyle(fontSize: 15),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 40),
                      _selectedAudio != null
                          ? AudioWave(path: _selectedAudio!.path)
                          : CustomTextFormField(
                              hintText: "Pick Song",
                              readOnly: true,
                              onTap: selectAudio,
                            ),
                      const SizedBox(height: 20),
                      CustomTextFormField(
                        hintText: "Artist",
                        controller: _artistController,
                      ),
                      const SizedBox(height: 20),
                      CustomTextFormField(
                        hintText: "Song Name",
                        controller: _songNameController,
                      ),
                      const SizedBox(height: 20),
                      ColorPicker(
                        color: _selectedColor,
                        pickersEnabled: const {
                          ColorPickerType.wheel: true,
                        },
                        onColorChanged: (color) {
                          setState(() {
                            _selectedColor = color;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
