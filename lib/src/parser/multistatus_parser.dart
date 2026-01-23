import '../model/multistatus.dart';
import '../model/response.dart' as model;
import '../dav_resource.dart';
import '../util/webdav_util.dart';
import '../webdav_exception.dart';

/// Parse WebDAV multistatus XML into a list of DavResource
List<DavResource> parseMultistatusResources(String xmlString) {
  try {
    final multistatus = Multistatus.fromXml(xmlString);
    return [
      for (final response in multistatus.responses)
        if (_parseResponseToDavResource(response) case final r?) r,
    ];
  } catch (e) {
    if (e is WebDAVException) rethrow;
    throw WebDAVXmlException('Failed to parse multistatus response', cause: e);
  }
}

DavResource? _parseResponseToDavResource(model.Response response) {
  try {
    final href = response.href;
    final properties = <String, String>{};

    // Extract custom properties and mark presence of standard props
    for (final propstat in response.propstats) {
      if (propstat.status.contains('200')) {
        properties.addAll(propstat.prop.customProperties);
        for (final propName in propstat.prop.properties) {
          properties.putIfAbsent(propName, () => '');
        }
      }
    }

    return DavResource(
      href: Uri.parse(href),
      creation: WebDAVUtil.parseDate(properties['creationdate']),
      displayName: properties['displayname'],
      contentLength: int.tryParse(properties['getcontentlength'] ?? '0') ?? 0,
      contentType:
          properties['getcontenttype'] ?? DavResource.defaultContentType,
      etag: properties['getetag'],
      modified: WebDAVUtil.parseDate(properties['getlastmodified']),
      resourceTypes: _parseResourceType(properties['resourcetype']),
      customProperties: properties,
    );
  } catch (e) {
    return null;
  }
}

List<String> _parseResourceType(String? resourceType) {
  if (resourceType == null || resourceType.isEmpty) return [];
  if (resourceType.contains('collection')) return ['collection'];
  return [];
}
