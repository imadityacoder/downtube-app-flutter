import 'package:downtube/views/widgets/searchbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DowntubeAppbar extends StatelessWidget {
  const DowntubeAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 10,
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 220,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 22, 105, 59),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),

        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 12, right: 12, bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.cover,
                      width: 55,
                      height: 55,
                    ),
                    Text(
                      "Downtube",
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 204, 255, 236),
                        fontFamily: "Poppins",
                      ),
                    ),
                  ],
                ),
              ),
              SearchBarWidget(
                controller: TextEditingController(),
                readOnly: true,
                onTap: () => context.push('/search'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
