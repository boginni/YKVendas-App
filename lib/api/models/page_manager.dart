import 'package:flutter/cupertino.dart';

import 'interface/queue_action.dart';

class PageManager {
  PageManager({required this.pageController});

  final PageController pageController;

  int page = 0;

  List<int> previousPages = [0];

  void setPage(int newPage) {
    if (newPage != page) {
      QueueAction.clearListeners();
      pageController.jumpToPage(newPage);
      previousPages.add(page);
      page = newPage;
    }
  }

  int getPreviousPage() {
    int size = previousPages.length;
    int x = previousPages[size - 1];
    if (size > 1) {
      previousPages.removeLast();
    }

    return x;
  }

  bool previousPage() {
    int lastPage = getPreviousPage();

    if (lastPage != page) {
      pageController.jumpToPage(lastPage);
      page = lastPage;
      return true;
    }
    return false;
  }
}
