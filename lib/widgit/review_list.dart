import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/review_provider.dart';
import 'package:readmore/readmore.dart';

class ReviewList extends StatefulWidget {
  const ReviewList({Key? key}) : super(key: key);

  @override
  State<ReviewList> createState() => _ReviewListState();
}

class _ReviewListState extends State<ReviewList> {
  late String x;
  @override
  void initState() {
    super.initState();
    x = Provider.of<ReviewProvider>(context, listen: false)
        .initialList
        .toString();
  }

  changeX(String s) {
    if (x == s) {
      return;
    }
    setState(() {
      x = s;
    });
    print('set called');
    Provider.of<ReviewProvider>(context, listen: false)
        .changeInitialList(int.parse(s));
    //}
  }

  List<Widget> build5Star(int limit) {
    return List.generate(
      5,
      (i) => i + 1 <= limit
          ? const Icon(
              Icons.star,
              color: Colors.yellowAccent,
            )
          : const Icon(
              Icons.star_border_outlined,
              color: Colors.grey,
            ),
    );
  }

  buildStar(int limit, DateTime date, String name) {
    List<Widget> lst = build5Star(limit);
    lst.add(
      Text(
        date.toIso8601String().substring(0, 10),
        style: const TextStyle(color: Colors.grey),
      ),
    );
    lst.add(
      Text(
        "( $name )",
        style: const TextStyle(color: Colors.grey),
      ),
    );
    Widget x = Row(
      children: lst,
    );
    return x;
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<ReviewProvider>(context);
    String filter;
    filter = provider.initialList.toString();
    print(filter);

    int i = 5;
    List<int> star = provider.totalStars();
    int totStar=0;
    for(int i=0;i<5;i++){
      totStar+=star[i];
    }
    Widget a = SizedBox(
      height: 200,
      child: Column(
        children: List.generate(5, (index) {
          List<Widget> ans = build5Star(i);
          String percent=((star[i-1]*100)/totStar).toStringAsFixed(3);
          ans.add(Text('${star[i - 1]} Review $percent%'));
          i--;
          return Row(
            children: ans,
          );
        }),
      ),
    );
    provider.sortReviews(filter);
    List<ReviewItem> lst = provider.lst;
    if (lst == []) {
      return Container();
    }
    var b = SizedBox(
        child: Column(
      children: List.generate(lst.length, (index) {
        return SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$index .'),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  buildStar(
                      lst[index].star, lst[index].date, lst[index].userName),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: lst[index].desc != 'null'
                        ? ReadMoreText(
                            lst[index].desc,
                            style: const TextStyle(fontSize: 16),
                            trimLines: 1,
                            colorClickableText: Colors.pink,
                            trimMode: TrimMode.Line,
                            trimCollapsedText: 'Show more',
                            trimExpandedText: 'Show less',
                            lessStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                            moreStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                          )
                        : null,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    ));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButton(
          items: const [
            DropdownMenuItem(
              value: '0',
              child: Text('Newest First'),
            ),
            DropdownMenuItem(
              value: '1',
              child: Text('Oldest First'),
            ),
            DropdownMenuItem(
              value: '2',
              child: Text('All Reviews Stars'),
            ),
          ],
          onChanged: (_) => changeX(_.toString()),
          value: x,
        ),
        filter == '2' ? a : b
      ],
    );
  }
}
