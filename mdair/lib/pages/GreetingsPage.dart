import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class GreetingsPage extends StatelessWidget {
  final List<Map<String, String>> faq = [
    {
      'question': 'How i can register an account?',
      'answer': 'You can sign up to a system via registration form.\nTo access it, you should navigate to access it navigate, please, to \"Profile\" tab using navigation panel at the bottom of the screen.',
    },
    {
      'question': 'Carriage rules',
      'answer': 'You’re allowed one carry-on bag, which must fit in the overhead bin or under the seat in front of you. If it doesn’t fit, it will need to be checked. The total size of your carry-on, including handles and wheels, cannot exceed 22 x 14 x 9 inches (56 x 36 x 23 cm). Musical instruments also count as a carry-on and must fit safely in the bin, under the seat, or in a closet (unless you paid for an extra seat).',
    },
    {
      'question': 'Additional services',
      'answer': 'You can pay for additional services such as upgrades or excess baggage directly at the airport. Please note that we offer separate payment options there.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to MDAir'),
        backgroundColor: Colors.yellow.shade400,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: 100),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Explore the World with Us',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 20),
              CarouselSlider(
                options: CarouselOptions(
                  height: 250.0,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 4),
                  enlargeCenterPage: true,
                ),
                items: [
                  {
                    'imageUrl': 'https://th.bing.com/th/id/OIP.tOkSpz8t8dtq_XsM7W9aXQHaFj?w=255&h=191&c=7&r=0&o=5&dpr=1.3&pid=1.7',
                    'countryName': 'Spain',
                  },
                  {
                    'imageUrl': 'https://th.bing.com/th/id/R.2108ec78db9c9634b5755cc4601aa811?rik=RJ5ZvQodeWifYQ&pid=ImgRaw&r=0',
                    'countryName': 'France',
                  },
                  {
                    'imageUrl': 'https://i1.wp.com/blog.tripfez.com/wp-content/uploads/2020/03/shutterstock_788252074-scaled.jpg?fit=1920%2C1281&ssl=1',
                    'countryName': 'Thailand',
                  },
                ].map((item) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          border: Border.all(color: Colors.yellow, width: 3),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: <Widget>[
                            Opacity(
                              opacity: 0.9,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: Image.network(
                                  item['imageUrl']!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              left: 10,
                              bottom: 10,
                              child: Text(
                                item['countryName']!,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              Text(
                'Your Comfort is Our Priority',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
              SizedBox(height: 40),
              Text(
                'FAQ & Rules',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              ),
              ...faq.map((item) {
                return ListTile(
                  title: Text(item['question']!, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),),
                  trailing: Icon(Icons.keyboard_arrow_down),
                  onTap: () => _showBottomSheet(context, item['question']!, item['answer']!),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context, String title, String content) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(8.0),
          height: 350,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    margin: EdgeInsets.only(bottom: 12.0),
                    width: 120,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                ),
                Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                const SizedBox(height: 10),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(content, style: TextStyle(color: Colors.black, fontSize: 16), textAlign: TextAlign.justify),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
