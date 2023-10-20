import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'detail.dart';

void main() => runApp(MyApp());

Future<List<Post>> fetchPosts() async {
  final response = await http
      .get(Uri.parse('https://calm-plum-jaguar-tutu.cyclic.app/todos'));
  if (response.statusCode == 200) {
    Map<String, dynamic> jsonData = json.decode(response.body);
    if (jsonData.containsKey("data")) {
      List<dynamic> data = jsonData["data"];
      List<Post> posts =
          data.map((dynamic item) => Post.fromJson(item)).toList();
      return posts;
    } else {
      throw Exception('JSON data does not contain a "data" field');
    }
  } else {
    throw Exception('Failed to load posts');
  }
}

class Post {
  final String todoName;
  final String isComplete; // Change type from bool to String

  Post({required this.todoName, required this.isComplete});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      todoName: json['todoName'] ?? '',
      isComplete:
          json['isComplete'].toString() ?? '', // Convert bool value to String
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final Future<List<Post>> posts = fetchPosts();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Posts from API'),
      ),
      body: Center(
        child: FutureBuilder<List<Post>>(
          future: posts,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 5, // Tambahkan elevasi untuk efek bayangan
                    margin: EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5), // Tambahkan margin
                    child: ListTile(
                      title: Text(snapshot.data![index].todoName),
                      subtitle: Text(snapshot.data![index].isComplete),
                      // Tambahkan animasi ketika item di-tap
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DetailScreen(post: snapshot.data![index]),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
