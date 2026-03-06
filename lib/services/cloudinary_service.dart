import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

class CloudinaryService {
  final String cloudName = 'dqyfeznaf';
  final String apiKey = '172781933873725';
  final String apiSecret = 'WE1qzWWFPgXOI6YyGJXuHcv8OD0';

  Future<String?> uploadImage(File image) async {
    var url = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );
    var request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('file', image.path));
    request.fields['upload_preset'] = 'ml_default';
    var response = await request.send();
    var resStr = await response.stream.bytesToString();
    var data = json.decode(resStr);
    return data['secure_url'];
  }
}
