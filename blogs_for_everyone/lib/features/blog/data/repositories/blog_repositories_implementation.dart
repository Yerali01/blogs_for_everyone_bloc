import 'dart:io';
import 'package:blogs_for_everyone/core/error/exceptions.dart';
import 'package:blogs_for_everyone/core/error/failures.dart';
import 'package:blogs_for_everyone/core/network/connection_checker.dart';
import 'package:blogs_for_everyone/features/blog/data/datasources/blog_local_data_source.dart';
import 'package:blogs_for_everyone/features/blog/data/datasources/blog_remote_data_source.dart';
import 'package:blogs_for_everyone/features/blog/data/models/blog_model.dart';
import 'package:blogs_for_everyone/features/blog/domain/entities/blog.dart';
import 'package:blogs_for_everyone/features/blog/domain/repositories/blog_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

class BlogRepositoryImplementation implements BlogRepository {
  final BlogRemoteDataSource blogRemoteDataSource;
  final BlogLocalDatasource blogLocalDatasource;
  final ConnectionChecker connectionChecker;

  BlogRepositoryImplementation(
    this.blogRemoteDataSource,
    this.blogLocalDatasource,
    this.connectionChecker,
  );

  @override
  Future<Either<Failure, Blog>> uploadBlog({
    required File image,
    required String title,
    required String content,
    required String posterId,
    required List<String> topics,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("No internet connection"));
      }

      BlogModel blogModel = BlogModel(
        id: const Uuid().v1(),
        posterId: posterId,
        title: title,
        content: content,
        imageUrl: 'imageUrl',
        topics: topics,
        updatedAt: DateTime.now(),
      );

      //upload image to supabase storage
      final imageUrl = await blogRemoteDataSource.uploadBlogImage(
        image: image,
        blog: blogModel,
      );

      //assign the imageUrl to the blogModel
      blogModel = blogModel.copyWith(imageUrl: imageUrl);

      //save blogModel in the supabase. It is the most up to date blog
      final uploadedBlog = await blogRemoteDataSource.uploadBlog(blogModel);
      return right(uploadedBlog);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Blog>>> getAllBlogs() async {
    try {
      if (!await (connectionChecker.isConnected)) {
        final blogs = blogLocalDatasource.loadBlogs();
        return right(blogs);
      }

      final blogs = await blogRemoteDataSource.getAllBlogs();
      blogLocalDatasource.uploadLocalBlogs(blogs: blogs);

      return right(blogs);
    } on ServerException catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
