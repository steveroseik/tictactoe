import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:tictactoe/spritesConfigurations.dart';

class CharactersPage extends StatefulWidget {
  const CharactersPage({super.key});

  @override
  State<CharactersPage> createState() => _CharactersPageState();
}

class _CharactersPageState extends State<CharactersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Free Animated Characters', style: TextStyle(fontWeight: FontWeight.w800,
              fontSize: 20.sp),),
              GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
                itemCount: characters.values.length - 18,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index){
                  return Center(
                    child: SizedBox(
                      width: 7.h,
                      child: ShaderMask(
                          blendMode: BlendMode.srcATop,
                          shaderCallback: (Rect bounds) => LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.1)],
                          ).createShader(bounds),
                          child: Stack(
                              children: [
                                AspectRatio(
                                    aspectRatio: 1,
                                    child: Sprites.characterOf[characters.values[index]])
                              ])),
                    ),
                  );
                }),
              Text('Premium Animated Characters', style: TextStyle(fontWeight: FontWeight.w800,
                  fontSize: 20.sp), textAlign: TextAlign.center,),
              GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3),
                  itemCount: 18,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index){
                    final diff = characters.values.length - 18;
                    return Center(
                      child: SizedBox(
                        width: 7.h,
                        child: ShaderMask(
                            blendMode: BlendMode.srcATop,
                            shaderCallback: (Rect bounds) => LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.1)],
                            ).createShader(bounds),
                            child: Stack(
                                children: [
                                  AspectRatio(
                                      aspectRatio: 1,
                                      child: Sprites.characterOf[characters.values[index+diff]])
                                ])),
                      ),
                    );
                  }),
              Text('EXPLOSIONS', style: TextStyle(fontWeight: FontWeight.w800,
                  fontSize: 20.sp), textAlign: TextAlign.center,),
              GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3),
                  itemCount: 6,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index){
                    return Center(
                      child: SizedBox(
                        width: 10.h,
                        child: ShaderMask(
                            blendMode: BlendMode.srcATop,
                            shaderCallback: (Rect bounds) => LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.1)],
                            ).createShader(bounds),
                            child: Stack(
                                children: [
                                  AspectRatio(
                                      aspectRatio: 1,
                                      child: Sprites().explosionOf[explosions.values[index]])
                                ])),
                      ),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
