import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Design System Icon Set
///
/// Centralized icon set using Phosphor Icons
/// Provides consistent, semantic icon names across the application
class AppIcons {
  AppIcons._();

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // NAVIGATION
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static final home = PhosphorIcons.house();
  static final homeFilled = PhosphorIcons.house(PhosphorIconsStyle.fill);
  static final back = PhosphorIcons.arrowLeft();
  static final forward = PhosphorIcons.arrowRight();
  static final menu = PhosphorIcons.list();
  static final close = PhosphorIcons.x();
  static final chevronDown = PhosphorIcons.caretDown();
  static final chevronUp = PhosphorIcons.caretUp();
  static final chevronLeft = PhosphorIcons.caretLeft();
  static final chevronRight = PhosphorIcons.caretRight();

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // ACTIONS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static final add = PhosphorIcons.plus();
  static final addCircle = PhosphorIcons.plusCircle();
  static final edit = PhosphorIcons.pencilSimple();
  static final delete = PhosphorIcons.trash();
  static final save = PhosphorIcons.floppyDisk();
  static final share = PhosphorIcons.shareNetwork();
  static final copy = PhosphorIcons.copy();
  static final download = PhosphorIcons.download();
  static final upload = PhosphorIcons.upload();
  static final refresh = PhosphorIcons.arrowClockwise();
  static final more = PhosphorIcons.dotsThreeVertical();

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // CONTENT
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static final search = PhosphorIcons.magnifyingGlass();
  static final filter = PhosphorIcons.funnel();
  static final sort = PhosphorIcons.sortAscending();
  static final list = PhosphorIcons.listBullets();
  static final grid = PhosphorIcons.gridFour();
  static final calendar = PhosphorIcons.calendar();
  static final clock = PhosphorIcons.clock();
  static final image = PhosphorIcons.image();
  static final camera = PhosphorIcons.camera();
  static final file = PhosphorIcons.file();
  static final folder = PhosphorIcons.folder();

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // USER & PEOPLE
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static final user = PhosphorIcons.user();
  static final userFilled = PhosphorIcons.user(PhosphorIconsStyle.fill);
  static final users = PhosphorIcons.users();
  static final userCircle = PhosphorIcons.userCircle();
  static final profile = PhosphorIcons.userCircle();

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // COMMUNICATION
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static final notification = PhosphorIcons.bell();
  static final notificationFilled = PhosphorIcons.bell(PhosphorIconsStyle.fill);
  static final message = PhosphorIcons.chatCircle();
  static final mail = PhosphorIcons.envelope();
  static final phone = PhosphorIcons.phone();
  static final send = PhosphorIcons.paperPlaneTilt();

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // MEDIA
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static final play = PhosphorIcons.play();
  static final pause = PhosphorIcons.pause();
  static final stop = PhosphorIcons.stop();
  static final video = PhosphorIcons.video();
  static final microphone = PhosphorIcons.microphone();

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // STATUS & FEEDBACK
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static final success = PhosphorIcons.checkCircle();
  static final successFilled =
      PhosphorIcons.checkCircle(PhosphorIconsStyle.fill);
  static final error = PhosphorIcons.xCircle();
  static final errorFilled = PhosphorIcons.xCircle(PhosphorIconsStyle.fill);
  static final warning = PhosphorIcons.warningCircle();
  static final warningFilled =
      PhosphorIcons.warningCircle(PhosphorIconsStyle.fill);
  static final info = PhosphorIcons.info();
  static final infoFilled = PhosphorIcons.info(PhosphorIconsStyle.fill);
  static final check = PhosphorIcons.check();

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SETTINGS & SYSTEM
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static final settings = PhosphorIcons.gear();
  static final lock = PhosphorIcons.lock();
  static final unlock = PhosphorIcons.lockOpen();
  static final eye = PhosphorIcons.eye();
  static final eyeSlash = PhosphorIcons.eyeSlash();
  static final language = PhosphorIcons.translate();
  static final theme = PhosphorIcons.palette();
  static final logout = PhosphorIcons.signOut();

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // AGRICULTURE / BUSINESS (Domain-specific)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static final farm = PhosphorIcons.farm();
  static final plant = PhosphorIcons.plant();
  static final tree = PhosphorIcons.tree();
  static final leaf = PhosphorIcons.leaf();
  static final map = PhosphorIcons.mapTrifold();
  static final mapPin = PhosphorIcons.mapPin();
  static final location = PhosphorIcons.mapPinLine();
  static final compass = PhosphorIcons.compass();
  static final chart = PhosphorIcons.chartLine();
  static final chartBar = PhosphorIcons.chartBar();
  static final trendUp = PhosphorIcons.trendUp();
  static final trendDown = PhosphorIcons.trendDown();
  static final clipboard = PhosphorIcons.clipboard();
  static final document = PhosphorIcons.fileText();

  // Statistics
  static final analytics = PhosphorIcons.chartLineUp();
  static final analyticsFilled =
      PhosphorIcons.chartLineUp(PhosphorIconsStyle.fill);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // MISC
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static final star = PhosphorIcons.star();
  static final starFilled = PhosphorIcons.star(PhosphorIconsStyle.fill);
  static final heart = PhosphorIcons.heart();
  static final heartFilled = PhosphorIcons.heart(PhosphorIconsStyle.fill);
  static final bookmark = PhosphorIcons.bookmark();
  static final bookmarkFilled = PhosphorIcons.bookmark(PhosphorIconsStyle.fill);
  static final flag = PhosphorIcons.flag();
  static final tag = PhosphorIcons.tag();
  static final link = PhosphorIcons.link();
  static final export = PhosphorIcons.export();
  static final question = PhosphorIcons.question();
  static final help = PhosphorIcons.questionMark();
  static final globe = PhosphorIcons.globe();
}
