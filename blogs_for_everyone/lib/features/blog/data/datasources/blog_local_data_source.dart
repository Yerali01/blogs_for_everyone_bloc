import 'package:blogs_for_everyone/features/blog/data/models/blog_model.dart';
import 'package:hive/hive.dart';

abstract interface class BlogLocalDatasource {
  void uploadLocalBlogs({
    required List<BlogModel> blogs,
  });

  List<BlogModel> loadBlogs();
}

class BlogLocalDatasourceImplementation implements BlogLocalDatasource {
  final Box box;
  BlogLocalDatasourceImplementation(this.box);

  @override
  List<BlogModel> loadBlogs() {
    List<BlogModel> blogs = [];
    box.read(
      () {
        for (int i = 0; i < box.length; i++) {
          blogs.add(BlogModel.fromJson(
              box.get(i.toString()))); //box.get return a JSON
        }
      },
    );

    return blogs;
  }

  @override
  void uploadLocalBlogs({required List<BlogModel> blogs}) {
    box.clear(); // we need to clear the local database to avoid redundancy, because when we will have internet connection second time, all blogs will be saved second time
    box.write(
      () {
        for (int i = 0; i < blogs.length; i++) {
          box.put(i.toString(), blogs[i].toJson());
        }
      },
    ); //write is used to add a bunch of blogs in hive
  }
}
