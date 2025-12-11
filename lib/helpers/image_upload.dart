import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<String?> pickAndUploadPetImage() async {
  // Pick image file from downloads/photos/camera, works on Web + Android
  final result = await FilePicker.platform.pickFiles(
    type: FileType.image,
    allowMultiple: false,
    withData: true, // needed for Web uploads
  );

  if (result == null) return null; // user cancelled

  final file = result.files.first;
  Uint8List fileBytes = file.bytes!;

  final user = FirebaseAuth.instance.currentUser;

  final storageRef = FirebaseStorage.instance
      .ref()
      .child("pets/${user!.uid}/${file.name}");

  await storageRef.putData(fileBytes);
  return await storageRef.getDownloadURL();
}
