import 'package:flame/components.dart';
import 'package:flame/widgets.dart';


enum characters
{
  angryPig,
  angryShark,
  angrySkull,
  skull,
  bee,
  blueBird,
  bunny,
  chameleon,
  chicken,
  crabby,
  duck,
  fatBird,
  ghost,
  mushroom,
  maskDude,
  ninjaFrog,
  pinkMan,
  pinkStar,
  pirate,
  pirateSword,
  plant,
  radish,
  rhino,
  rock,
  slime,
  snail,
  spike,
  spikePro,
  trunk,
  virtualGuy,
  minotaur1,
  minotaur2,
  minotaur3,
  goblin,
  ogre,
  orc,
  golem1,
  golem2,
  golem3,
  wraith1,
  wraith2,
  wraith3,
  reaper1,
  reaper2,
  reaper3,
  fallenAngel1,
  fallenAngel2,
  fallenAngel3,
}

enum explosions {
  circle,
  explosion,
  blueCircle,
  blueOval,
  gas,
  gasCircle,
  twoColors,
  fire,
  lightning,
  nuclear,
  smoke
}

enum spellEffects {
  gaurdianPower1,
  gaurdianPower2,
  gaurdianPower3
}

enum Badges{
  rookie,
  novice,
  apprentice,
  ascendant,
  expert,
  elite,
  master,
  grandmaster,
  legend,
  champion,
}

enum Coins{
  bronze,
  silver,
  gold
}

class Sprites{
  static Map<characters, SpriteAnimationWidget> characterOf = {
    characters.angryPig : SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'pixels/angryPig.png', data: SpriteAnimationData.sequenced(
      amount: 9,
      textureSize: Vector2(36,30),
      stepTime: 0.1,
    )),
    characters.angryShark : SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'pixels/angryShark.png', data: SpriteAnimationData.sequenced(
      amount: 8,
      textureSize: Vector2(34,32),
      stepTime: 0.1,
    )),
    characters.skull : SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'pixels/skull.png', data: SpriteAnimationData.sequenced(
      amount: 8,
      textureSize: Vector2(52,54),
      stepTime: 0.1,
    )),
    characters.angrySkull : SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'pixels/angrySkull.png', data: SpriteAnimationData.sequenced(
      amount: 8,
      textureSize: Vector2(52,52),
      stepTime: 0.1,
    )),
    characters.bee : SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'pixels/bee.png', data: SpriteAnimationData.sequenced(
      amount: 6,
      textureSize: Vector2(36,34),
      stepTime: 0.1,
    )),
    characters.blueBird : SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'pixels/blueBird.png', data: SpriteAnimationData.sequenced(
      amount: 9,
      textureSize: Vector2(32,32),
      stepTime: 0.1,
    )),
    characters.bunny : SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'pixels/bunny.png', data: SpriteAnimationData.sequenced(
      amount: 8,
      textureSize: Vector2(34,44),
      stepTime: 0.1,
    )),
    characters.chameleon : SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'pixels/chameleon.png', data: SpriteAnimationData.sequenced(
      amount: 13,
      textureSize: Vector2(42,38),
      stepTime: 0.1,
    )),
    characters.chicken : SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'pixels/chicken.png', data: SpriteAnimationData.sequenced(
      amount: 13,
      textureSize: Vector2(32,33),
      stepTime: 0.1,
    )),
    characters.crabby : SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'pixels/crabby.png', data: SpriteAnimationData.sequenced(
      amount: 9,
      textureSize: Vector2(42,30),
      stepTime: 0.1,
    )),
    characters.duck : SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'pixels/duck.png', data: SpriteAnimationData.sequenced(
      amount: 10,
      textureSize: Vector2(36,36),
      stepTime: 0.1,
    )),
    characters.fatBird : SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'pixels/fatBird.png', data: SpriteAnimationData.sequenced(
      amount: 8,
      textureSize: Vector2(40,48),
      stepTime: 0.1,
    )),
    characters.ghost : SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'pixels/ghost.png', data: SpriteAnimationData.sequenced(
      amount: 10,
      textureSize: Vector2(44,30),
      stepTime: 0.1,
    )),
    characters.mushroom: SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'pixels/mushroom.png', data: SpriteAnimationData.sequenced(
      amount: 16,
      textureSize: Vector2(32,32),
      stepTime: 0.1,
    )),
    characters.maskDude : SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'pixels/maskDude.png', data: SpriteAnimationData.sequenced(
      amount: 11,
      textureSize: Vector2(32,32),
      stepTime: 0.1,
    )),
    characters.ninjaFrog : SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'pixels/ninjaFrog.png', data: SpriteAnimationData.sequenced(
      amount: 11,
      textureSize: Vector2(32,32),
      stepTime: 0.1,
    )),
    characters.pinkMan : SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'pixels/pinkMan.png', data: SpriteAnimationData.sequenced(
      amount: 11,
      textureSize: Vector2(32,32),
      stepTime: 0.1,
    )),
    characters.pinkStar : SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'pixels/pinkStar.png', data: SpriteAnimationData.sequenced(
      amount: 8,
      textureSize: Vector2(34,32),
      stepTime: 0.1,
    )),
    characters.pirate : SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'pixels/pirate.png', data: SpriteAnimationData.sequenced(
      amount: 5,
      textureSize: Vector2(28,36),
      stepTime: 0.1,
    )),
    characters.pirateSword : SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'pixels/pirateSword.png', data: SpriteAnimationData.sequenced(
      amount: 5,
      textureSize: Vector2(41,36),
      stepTime: 0.1,
    )),
    characters.plant : SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'pixels/plant.png', data: SpriteAnimationData.sequenced(
      amount: 11,
      textureSize: Vector2(44,42),
      stepTime: 0.1,
    )),
    characters.radish : SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'pixels/radish.png', data: SpriteAnimationData.sequenced(
      amount: 9,
      textureSize: Vector2(30,38),
      stepTime: 0.1,
    )),
    characters.rhino : SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'pixels/rino.png', data: SpriteAnimationData.sequenced(
      amount: 11,
      textureSize: Vector2(52,34),
      stepTime: 0.1,
    )),
    characters.rock  : SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'pixels/rock.png', data: SpriteAnimationData.sequenced(
      amount: 14,
      textureSize: Vector2(38,34),
      stepTime: 0.1,
    )),
    characters.slime : SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'pixels/slime.png', data: SpriteAnimationData.sequenced(
      amount: 10,
      textureSize: Vector2(44,30),
      stepTime: 0.1,
    )),
    characters.snail : SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'pixels/snail.png', data: SpriteAnimationData.sequenced(
      amount: 6,
      textureSize: Vector2(38,24),
      stepTime: 0.1,
    )),
    characters.spike : SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'pixels/spike.png', data: SpriteAnimationData.sequenced(
      amount: 14,
      textureSize: Vector2(44,26),
      stepTime: 0.1,
    )),
    characters.spikePro : SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'pixels/spikePro.png', data: SpriteAnimationData.sequenced(
      amount: 14,
      textureSize: Vector2(44,26),
      stepTime: 0.1,
    )),
    characters.trunk : SpriteAnimationWidget.asset(
      anchor: Anchor.center,
        path: 'pixels/trunk.png', data: SpriteAnimationData.sequenced(
      amount: 18,
      textureSize: Vector2(64,33),
      stepTime: 0.1,
    )),
    characters.virtualGuy : SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'pixels/virtualGuy.png', data: SpriteAnimationData.sequenced(
      amount: 11,
      textureSize: Vector2(32,33),
      stepTime: 0.1,
    )),
    characters.minotaur1 : SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'pixels/minotaur1.png', data: SpriteAnimationData.sequenced(
      amount: 18,
      amountPerRow: 9,
      textureSize: Vector2(210,256),
      stepTime: 0.08,
    )),
    characters.minotaur2 : SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'pixels/minotaur2.png', data: SpriteAnimationData.sequenced(
      amount: 18,
      amountPerRow: 9,
      textureSize: Vector2(224,280),
      stepTime: 0.08,
    )),
    characters.minotaur3 : SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'pixels/minotaur3.png', data: SpriteAnimationData.sequenced(
      amount: 18,
      amountPerRow: 9,
      textureSize: Vector2(210,261),
      stepTime: 0.08,
    )),
    characters.goblin : SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'pixels/goblin.png', data: SpriteAnimationData.sequenced(
      amount: 18,
      amountPerRow: 9,
      textureSize: Vector2(196,270),
      stepTime: 0.08,
    )),
    characters.ogre : SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'pixels/ogre.png', data: SpriteAnimationData.sequenced(
      amount: 18,
      amountPerRow: 9,
      textureSize: Vector2(195,279),
      stepTime: 0.08,
    )),
    characters.orc : SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'pixels/orc.png', data: SpriteAnimationData.sequenced(
      amount: 18,
      amountPerRow: 9,
      textureSize: Vector2(196,306),
      stepTime: 0.08,
    )),
    characters.golem1 : SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'pixels/golem1.png', data: SpriteAnimationData.sequenced(
      amount: 18,
      amountPerRow: 9,
      textureSize: Vector2(204,280),
      stepTime: 0.08,
    )),
    characters.golem2 : SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'pixels/golem2.png', data: SpriteAnimationData.sequenced(
      amount: 18,
      amountPerRow: 9,
      textureSize: Vector2(210,294),
      stepTime: 0.08,
    )),
    characters.golem3 : SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'pixels/golem3.png', data: SpriteAnimationData.sequenced(
      amount: 18,
      amountPerRow: 9,
      textureSize: Vector2(200,266),
      stepTime: 0.08,
    )),
    characters.wraith1 : SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'pixels/wraith1.png', data: SpriteAnimationData.sequenced(
      amount: 12,
      textureSize: Vector2(99,152),
      stepTime: 0.1,
    )),
    characters.wraith2 : SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'pixels/wraith2.png', data: SpriteAnimationData.sequenced(
      amount: 12,
      textureSize: Vector2(107,152),
      stepTime: 0.1,
    )),
    characters.wraith3 : SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'pixels/wraith3.png', data: SpriteAnimationData.sequenced(
      amount: 12,
      textureSize: Vector2(109,160),
      stepTime: 0.1,
    )),
    characters.reaper1 : SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'pixels/reaper1.png', data: SpriteAnimationData.sequenced(
      amount: 18,
      amountPerRow: 6,
      textureSize: Vector2(240,300),
      stepTime: 0.1,
    )),
    characters.reaper2 : SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'pixels/reaper2.png', data: SpriteAnimationData.sequenced(
      amount: 18,
      amountPerRow: 6,
      textureSize: Vector2(240,300),
      stepTime: 0.1,
    )),
    characters.reaper3 : SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'pixels/reaper3.png', data: SpriteAnimationData.sequenced(
      amount: 18,
      amountPerRow: 6,
      textureSize: Vector2(240,297),
      stepTime: 0.1,
    )),
    characters.fallenAngel1 : SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'pixels/fallenAngel1.png', data: SpriteAnimationData.sequenced(
      amount: 18,
      amountPerRow: 9,
      textureSize: Vector2(220,297),
      stepTime: 0.1,
    )),
    characters.fallenAngel2 : SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'pixels/fallenAngel2.png', data: SpriteAnimationData.sequenced(
      amount: 18,
      amountPerRow: 6,
      textureSize: Vector2(238,294),
      stepTime: 0.1,
    )),
    characters.fallenAngel3 : SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'pixels/fallenAngel3.png', data: SpriteAnimationData.sequenced(
      amount: 18,
      amountPerRow: 9,
      textureSize: Vector2(225,312),
      stepTime: 0.1,
    )),
  };
  
  static Map<explosions, SpriteAnimationWidget> explosionOf = {
    explosions.circle :  SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'hdExplosions1.png', data: SpriteAnimationData.range(
      start: 0,
      end: 9,
      amount: 60,
      amountPerRow: 8,
      textureSize: Vector2(256,256),
      stepTimes: List<double>.generate(10, (index) => 0.07),
    )),
    explosions.explosion :  SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'hdExplosions1.png', data: SpriteAnimationData.range(
      start: 10,
      end: 19,
      amount: 60,
      amountPerRow: 8,
      textureSize: Vector2(256,256),
      stepTimes: List<double>.generate(10, (index) => 0.1),
    )),
    explosions.blueCircle :  SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'hdExplosions1.png', data: SpriteAnimationData.range(
      start: 20,
      end: 29,
      amount: 60,
      amountPerRow: 8,
      textureSize: Vector2(256,256),
      stepTimes: List<double>.generate(10, (index) => 0.1),
    )),
    explosions.blueOval :  SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'hdExplosions1.png', data: SpriteAnimationData.range(
      start: 30,
      end: 39,
      amount: 60,
      amountPerRow: 8,
      textureSize: Vector2(256,256),
      stepTimes: List<double>.generate(10, (index) => 0.1),
    )),
    explosions.gas :  SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'hdExplosions1.png', data: SpriteAnimationData.range(
      start: 40,
      end: 49,
      amount: 60,
      amountPerRow: 8,
      textureSize: Vector2(256,256),
      stepTimes: List<double>.generate(10, (index) => 0.1),
    )),
    explosions.gasCircle :  SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'hdExplosions1.png', data: SpriteAnimationData.range(
      start: 50,
      end: 59,
      amount: 60,
      amountPerRow: 8,
      textureSize: Vector2(256,256),
      stepTimes: List<double>.generate(10, (index) => 0.1),
    )),
    explosions.twoColors :  SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'hdExplosions2.png', data: SpriteAnimationData.range(
      start: 0,
      end: 9,
      amount: 32,
      amountPerRow: 8,
      textureSize: Vector2(256,256),
      stepTimes: List<double>.generate(10, (index) => 0.2),
    )),
    explosions.fire :  SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'hdExplosions1.png', data: SpriteAnimationData.range(
      start: 10,
      end: 15,
      amount: 60,
      amountPerRow: 8,
      textureSize: Vector2(256,256),
      stepTimes: List<double>.generate(6, (index) => 0.1),
    )),
  };

  static Map<spellEffects, SpriteAnimationWidget> spellOf = {
    spellEffects.gaurdianPower1 : SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'gaurdPower1.png', data: SpriteAnimationData.range(
      start: 0,
      end: 29,
      amount: 30,
      amountPerRow: 5,
      textureSize: Vector2(480,480),
      stepTimes: List<double>.generate(30, (index) => 0.07),
    )),
    spellEffects.gaurdianPower2 : SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'gaurdPower2.png', data: SpriteAnimationData.range(
      start: 0,
      end: 29,
      amount: 30,
      amountPerRow: 5,
      textureSize: Vector2(480,480),
      stepTimes: List<double>.generate(30, (index) => 0.07),
    )),
    spellEffects.gaurdianPower3 : SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'gaurdPower3.png', data: SpriteAnimationData.range(
      start: 0,
      end: 29,
      amount: 30,
      amountPerRow: 5,
      textureSize: Vector2(480,480),
      stepTimes: List<double>.generate(30, (index) => 0.07),
    ))
  };

  static Map<Badges, SpriteWidget> badgeOf = {
    Badges.rookie: SpriteWidget.asset(
      path: 'tier_badges.png',
      srcPosition: Vector2(0, 0),
      srcSize: Vector2(128, 128),
    ),

    Badges.novice: SpriteWidget.asset(
      path: 'tier_badges.png',
      srcPosition: Vector2(128, 0),
      srcSize: Vector2(128, 128),
    ),

    Badges.apprentice: SpriteWidget.asset(
      path: 'tier_badges.png',
      srcPosition: Vector2(128 * 2, 0),
      srcSize: Vector2(128, 128),
    ),

    Badges.ascendant: SpriteWidget.asset(
      path: 'tier_badges.png',
      srcPosition: Vector2(128 * 3, 0),
      srcSize: Vector2(128, 128),
    ),

    Badges.expert: SpriteWidget.asset(
      path: 'tier_badges.png',
      srcPosition: Vector2(128 * 4, 0),
      srcSize: Vector2(128, 128),
    ),

    Badges.elite: SpriteWidget.asset(
      path: 'tier_badges.png',
      srcPosition: Vector2(128 * 5, 0),
      srcSize: Vector2(128, 128),
    ),

    Badges.master: SpriteWidget.asset(
      path: 'tier_badges.png',
      srcPosition: Vector2(128 * 6, 0),
      srcSize: Vector2(128, 128),
    ),

    Badges.grandmaster: SpriteWidget.asset(
      path: 'tier_badges.png',
      srcPosition: Vector2(128 * 7, 0),
      srcSize: Vector2(128, 128),
    ),

    Badges.legend: SpriteWidget.asset(
      path: 'tier_badges.png',
      srcPosition: Vector2(128 * 8, 0),
      srcSize: Vector2(128, 128),
    ),

    Badges.champion: SpriteWidget.asset(
      path: 'tier_badges.png',
      srcPosition: Vector2(128 * 9, 0),
      srcSize: Vector2(128, 128),
    ),

  };

  static Map<Coins, SpriteAnimationWidget> coinOf = {
    Coins.bronze : SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'sprite_bronze.png', data: SpriteAnimationData.sequenced(
      amount: 10,
      textureSize: Vector2(120,120),
      stepTime: 0.1,
    )),
    Coins.silver : SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'sprite_silver.png', data: SpriteAnimationData.sequenced(
      amount: 10,
      textureSize: Vector2(120,120),
      stepTime: 0.1,
    )),
    Coins.gold : SpriteAnimationWidget.asset(
        anchor: Anchor.center,
        path: 'sprite_gold.png', data: SpriteAnimationData.sequenced(
      amount: 10,
      textureSize: Vector2(120,120),
      stepTime: 0.1,
    )),
  };
}

