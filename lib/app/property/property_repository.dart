import 'package:homeu/app/property/property_remote_datasource.dart';
import 'package:homeu/pages/home/property_item.dart';

class HomeUPropertyRepository {
  HomeUPropertyRepository({PropertyRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? const PropertyRemoteDataSource();

  final PropertyRemoteDataSource _remoteDataSource;

  Future<List<PropertyItem>> fetchPublishedProperties({
    int limit = 10,
    int offset = 0,
  }) {
    return _remoteDataSource.fetchPublishedProperties(
      limit: limit,
      offset: offset,
    );
  }
}
