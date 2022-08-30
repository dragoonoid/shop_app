import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/card_item.dart';
import 'package:shop/providers/review_provider.dart';

class RatingDialog extends StatefulWidget {
  final int pos;
  final List<CardItem> mp;
  const RatingDialog({Key? key, required this.pos, required this.mp})
      : super(key: key);

  @override
  _RatingDialogState createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int _stars = 0;
  TextEditingController cont = TextEditingController();
  TextEditingController nameCont = TextEditingController();
  final key = GlobalKey<FormState>();
  @override
  void initState() {
    // TODO: implement initState
    print(widget.mp.length);
    super.initState();
  }

  Widget _buildStar(int starCount) {
    return InkWell(
      child: Icon(
        _stars >= starCount ? Icons.star : Icons.star_border,
        color: _stars >= starCount ? Colors.yellowAccent : Colors.grey,
      ),
      onTap: () {
        setState(() {
          _stars = starCount;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          'Would you like to Rate our Product & Services?: ${widget.mp[widget.pos].title}'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStar(1),
              _buildStar(2),
              _buildStar(3),
              _buildStar(4),
              _buildStar(5),
            ],
          ),
          Form(
            key: key,
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(hintText: 'Review'),
                  controller: cont,
                  validator: (_) {
                    if (_ == null || _.isEmpty) {
                      cont.text = 'null';
                    } else {
                      cont.text = _;
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(hintText: 'Your Name'),
                  controller: nameCont,
                  validator: (_) {
                    if (_ == null || _.isEmpty) {
                      nameCont.text = 'Anonymous';
                    } else {
                      nameCont.text = _;
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () {
              print(_stars);
              key.currentState!.validate();
              Provider.of<ReviewProvider>(context, listen: false).setReview(
                widget.mp[widget.pos].id,
                cont.text,
                _stars,
                nameCont.text,
              );
              if (widget.mp.length == widget.pos + 1) {
                Navigator.pop(context);
                return;
              }
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (_) => RatingDialog(
                  pos: widget.pos + 1,
                  mp: widget.mp,
                ),
              );
            },
            child: const Text('Submit')),
        TextButton(
            onPressed: () {
              if (widget.mp.length == widget.pos + 1) {
                Navigator.pop(context);
                return;
              }
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (_) => RatingDialog(
                  pos: widget.pos + 1,
                  mp: widget.mp,
                ),
              );
            },
            child: const Text('Cancel')),
      ],
    );
  }
}
