import 'package:flutter/material.dart';

class Followers extends StatelessWidget {
  const Followers({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Followers")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            followerTile("John Doe"),
            followerTile("Emily Smith"),
            followerTile("Michael Lee"),
            followerTile("Sophia Brown"),
            followerTile("Ethan Clark"),
            followerTile("Olivia White"),
            followerTile("Daniel Martin"),
            followerTile("Charlotte Adams"),
            followerTile("James Carter"),
            followerTile("Mia Wilson"),
          ],
        ),
      ),
    );
  }

  Widget followerTile(String name) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22, // Profile icon size
                backgroundColor: Colors.grey[300], // Plain grey color
              ),
              SizedBox(width: 10),
              Text(name, style: TextStyle(fontSize: 16)),
            ],
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 255, 214, 52),// Button color
              foregroundColor: Colors.white, // Text color
            ),
            child: Row(
              children: [
                Text("Remove",
                style: TextStyle(color: Colors.black)
                ),
                SizedBox(width: 5),
                Icon(Icons.close), // "X" icon after text
              ],
            ),
          ),
        ],
      ),
    );
  }
}