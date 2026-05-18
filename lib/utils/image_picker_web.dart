// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:async';

Future<String?> pickImageBytes() async {
  final completer = Completer<String?>();
  final input = html.FileUploadInputElement()..accept = 'image/*';
  
  input.onChange.listen((e) {
    if (input.files == null || input.files!.isEmpty) {
      completer.complete(null);
      return;
    }
    final file = input.files![0];
    final reader = html.FileReader();
    reader.readAsDataUrl(file);
    reader.onLoadEnd.listen((e) {
      completer.complete(reader.result as String?);
    });
  });
  
  input.onError.listen((e) => completer.complete(null));
  input.click();
  
  return completer.future;
}
