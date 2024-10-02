import 'dart:io';

import 'package:google_oauth2/src/data/parse_file_as_json.dart';
import 'package:test/test.dart';

void main() {
  test('Parses service account JSON file.', () async {
    final sut = parseFileAsJson;
    final file = File('test/data/service_account_example.json');
    final actual = await sut(file);
    expect(
      actual,
      {
        'type': 'service_account',
        'project_id': 'example',
        'private_key_id': '5db6fa24c0c5ad90e6d927f3b19c84d5f2e170cb',
        'private_key': '-----BEGIN PRIVATE KEY-----\n'
            'KBvMSDBNAAOAA5gkikhii9w0BAQEFAASCBKcggSjAgEAAoIBAQDLbjBLsMsOrwzGX\n'
            'bshyPco8DhZ5RoCnpbB9nods7Oq8rwUb2LHn7FgDHnOpxVgJAPpGpHS00dBXewRh\n'
            'gC+4tVZ50EK5XR2lqkPaDlQDQE/eAtwoQi5AzQ26QSH5un50lkHi4OB0FP3IXtv\n'
            'J6O+Jl26GdTtxcNT1Bee+a4gfs4o5hhKvY93QSNkjrUJNdOn6GNLbyJgixJPHa+z\n'
            'hfkzaQNgz8rXSDQnz6IGW6FPepaNFGWHcoyWzx4AZLVp/CL1zY/VukEKaQo7NBt/\n'
            'BWDLNX+KbKZj2Kgx/9yx/4voL8oLt5j8kzVLWbcQz1YUarRb0xV2x4u9sxmA62hF\n'
            'O+Qdv5+nAgMBAAECggEAXzt+MHDbHkykVlhyrVCZ4cNWkf+HSvQt4yDLlRpz6VCl\n'
            'u5t97Wye5xbiXp+bzts+TsO+PsfaGJnmOzz+athtuGCh+k/gbYOqMSRBcFAmPWgd\n'
            'MuSwCKyPTQVYsaZP8jueogGV1reIFzD9b9PGu8WKKwzcuVLTVfL7+9g2w8+ZA1ue\n'
            'aWJPslrKVPuOiobr2dA4DwjnEowVMk8D+9cv/4DKKsejVOzjZHQIGsCZu0+k5qgT\n'
            'OshB8WqcmJWjbjEDaMSc2QPTP3U+6gs5ILuX81qoG9tnAt7q+aoFUMrbc2un5eKL\n'
            'jyfdCozF/SYWDqaVlllkBpKG1UWvxzUA6K2x6VjlwQKBgQDkOOTa79sMQwxz+goP\n'
            'gVY+sZj7b4SRtCv2T3T0vmkBzcZuzwX4a9P0DXaBljpx8WbKILw/j77ww9ZCbKws\n'
            'lt8e6czFpd3BNc+ybZHlzfQ0TJNqF3RDbGSurm01FBGx+ITVU4bWC8RupbN9VvXl\n'
            '442KD0thoSY0dHMB6E2Up+az2wKBgQDkMNBrMczI9t7yCfxATmOIiYpnEBsyt5z2\n'
            'HOF08p+qsrq9UicyCzl0kwXt5I/paXAcepNZbgalxFCI/HlnK2W/6S9mI0FE42WV\n'
            '5MDorJhPyxHiqaoJHUdYgzP7H5+RfKYJIvqDisyd+v7ZTSNU7+cRgzMoYKsGc5CQ\n'
            'TbkE+KkzJQKBgHWKG8vqhn1tNsewemf768hEPY8Zo0RLb+zehVTbkEdejJlbRC7q\n'
            'kfH60RLypU0z0AXAEFQIG4XyxrHVOGOKnIVWUqFkyK4Ooda6ec7KYMBiw/V6+OUU\n'
            'uVICAbq5iFeJsBgSebpZuyRlcOjX1bM9nBMDx4YTshKH+wd7diFezAHLAoGBAK+V\n'
            'UAnrm+PW8d3UCSGCL9xT2QdMwWDZIBHQTzsppeo29LHQkRBUyrUEnD9c689yri17\n'
            's/3QR5Ut5bpCazgTkIuG5k31OrfDMduQ1U8z308mtnBulMPGn6tf6ZOF1cag3zGQ\n'
            'lKq7Fo9JHugeDt3Aa1ByX97l4zNnoQkohQFqROdxAoGAYBHmQc3FdmCu8OTGTGCF\n'
            'n5IrnjMLBDrRzP6Y9tUjsE7qO2J8OcYOFJS/vBAf7B54OH31mmAHvwLJB9GPJ+ra\n'
            'bxZ2Q6HG7MKVIYctOSw3+b5sYXcrHtGGlkeRc6oMq4GihbFPR/ohy+EmxBaQJ7Ev\n'
            'Q0Wl1eCsJz0iCPZPLNHEa8Sk=\n'
            '-----END PRIVATE KEY-----\n',
        'client_email': 'example@example.iam.gserviceaccount.com',
        'client_id': '695034175462447092505',
        'auth_uri': 'https://accounts.google.com/o/oauth2/auth',
        'token_uri': 'https://oauth2.googleapis.com/token',
        'auth_provider_x509_cert_url':
            'https://www.googleapis.com/oauth2/v1/certs',
        'client_x509_cert_url':
            'https://www.googleapis.com/robot/v1/metadata/x509/example%40example.iam.gserviceaccount.com',
        'universe_domain': 'googleapis.com'
      },
    );
  });
}
