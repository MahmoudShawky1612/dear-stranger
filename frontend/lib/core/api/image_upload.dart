String? imageContentTypeForExtension(String? extension) {
  switch (extension?.toLowerCase()) {
    case 'png':
      return 'image/png';
    case 'webp':
      return 'image/webp';
    case 'jpg':
    case 'jpeg':
    case 'jpe':
      return 'image/jpeg';
    default:
      return null;
  }
}
