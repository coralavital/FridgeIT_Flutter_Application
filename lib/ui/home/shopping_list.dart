import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fridge_it/theme/theme_colors.dart';
import '../../services/firestore_service.dart';
import '../../utils/dimensions.dart';
import '../../widgets/big_text.dart';
import '../../widgets/custom_toast.dart';
import '../../widgets/small_text.dart';

class ShoppingList extends StatefulWidget {
  const ShoppingList({super.key});

  @override
  State<ShoppingList> createState() => _ShoppingList();
}

class _ShoppingList extends State<ShoppingList>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFirestoreService fbS = FirebaseFirestoreService();

  CustomToast? toast;

  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )
      ..forward()
      ..repeat(reverse: true);
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(controller);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Dimensions.size15),
      child: Column(
        children: [
          //Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BigText(
                  text: 'Shopping List',
                  size: Dimensions.size30,
                  fontWeight: FontWeight.bold,
                  color: ThemeColors().main),
            ],
          ),
          SizedBox(
            height: Dimensions.size25,
          ),
          //Body
          Expanded(
            child: SizedBox(
              height: Dimensions.size200,
              child: StreamBuilder(
                stream: _firestore
                    .collection(_auth.currentUser!.uid)
                    .doc('user_data')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  } else {
                    if (snapshot.data!['shopping_list'].length == 0) {
                      return Center(
                          child: Column(children: [
                        SizedBox(
                          height: Dimensions.size150,
                        ),
                        AnimatedIcon(
                          icon: AnimatedIcons.list_view,
                          color: ThemeColors().light1,
                          progress: animation,
                          size: Dimensions.size30,
                          semanticLabel: 'Show menu',
                        ),
                        SizedBox(
                          height: Dimensions.size15,
                        ),
                        SmallText(
                          text: 'There is no products yet',
                          size: Dimensions.size15,
                          fontWeight: FontWeight.w500,
                          color: ThemeColors().main,
                        ),
                      ]));
                    } else {
                      return ListView.builder(
                        itemCount: snapshot.data!['shopping_list'].length,
                        itemBuilder: (_, index) {
                          return SizedBox(
                            height: Dimensions.size20 * 5,
                            width: double.maxFinite,
                            child: Row(
                              children: [
                                GestureDetector(
                                  child: Container(
                                    width: Dimensions.size20 * 4,
                                    height: Dimensions.size100,
                                    margin: EdgeInsets.only(
                                      bottom: Dimensions.size10,
                                      right: Dimensions.size30,
                                    ),
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: NetworkImage(
                                              snapshot.data!['shopping_list']
                                                  [index]['image'])),
                                      borderRadius: BorderRadius.circular(
                                        Dimensions.size20,
                                      ),
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Expanded(
                                    child: SizedBox(
                                  height: Dimensions.size100,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          BigText(
                                            text:
                                                snapshot.data!['shopping_list']
                                                    [index]['name'],
                                            color: ThemeColors().main,
                                            size: Dimensions.size20,
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(
                                              Dimensions.size10,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                Dimensions.size20,
                                              ),
                                              color: ThemeColors().light1,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    fbS.removeItemToProduct(
                                                        snapshot.data![
                                                            'shopping_list'],
                                                        index);
                                                    toast = CustomToast(
                                                        message:
                                                            "The product has been removed\nfrom the shopping cart",
                                                        context: context);
                                                    toast?.showCustomToast();
                                                  },
                                                  child: Icon(
                                                    Icons.remove,
                                                    color: ThemeColors().main,
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 5.0,
                                                  ),
                                                  child: BigText(
                                                    text: snapshot
                                                        .data!['shopping_list']
                                                            [index]['quantity']
                                                        .toString(),
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    fbS.addItemToProduct(
                                                        snapshot.data![
                                                            'shopping_list'],
                                                        index);
                                                  },
                                                  child: Icon(
                                                    Icons.add,
                                                    color: ThemeColors().main,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ))
                              ],
                            ),
                          );
                        },
                      );
                    }
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
