export 'gallery_decoder_stub.dart'
    if (dart.library.html) 'gallery_decoder_web.dart'
    if (dart.library.io) 'gallery_decoder_mobile.dart';
