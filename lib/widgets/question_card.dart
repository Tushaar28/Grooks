import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:grooks_dev/models/question.dart';

class QuestionCard extends StatefulWidget {
  final Question question;
  const QuestionCard({
    Key? key,
    required this.question,
  }) : super(key: key);

  @override
  _QuestionCardState createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  Future<int> getYesTradePercentage(Question question) async {
    int openTrades = question.openTradesCount ?? 0;
    int pairedTrades = question.pairedTradesCount ?? 0;
    if (openTrades + pairedTrades == 0) return 50;
    int percentage =
        ((question.yesTrades!.length / (openTrades + pairedTrades * 2)) * 100)
            .round();
    return percentage;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.215,
      width: double.infinity,
      color: Colors.transparent,
      child: Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        color: const Color(0xFFFFFFFF),
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            10,
            10,
            10,
            10,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.035,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: AutoSizeText(
                    widget.question.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const Divider(
                color: Colors.grey,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.08,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.08,
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: widget.question.image != null
                          ? FadeInImage.assetNetwork(
                              placeholder: "assets/images/fallback.png",
                              image: widget.question.image!,
                            )
                          : Image.asset("assets/images/fallback.png"),
                    ),
                    FutureBuilder<int>(
                      initialData: 50,
                      future: getYesTradePercentage(widget.question),
                      builder: (context, snapshot) => SizedBox(
                        height: MediaQuery.of(context).size.height * 0.08,
                        width: MediaQuery.of(context).size.width * 0.38,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: max(
                                  MediaQuery.of(context).size.width * 0.15,
                                  MediaQuery.of(context).size.width *
                                      0.38 *
                                      snapshot.data!.toInt() /
                                      100),
                              decoration: BoxDecoration(
                                color: const Color(0x402DEB51),
                                borderRadius: BorderRadius.circular(
                                  0,
                                ),
                                border: Border.all(
                                  color: const Color(0x602DEB51),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  snapshot.data == 0 ? "" : "${snapshot.data}%",
                                  style: TextStyle(
                                    color: Colors.green[600],
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: max(
                                  MediaQuery.of(context).size.width * 0.15,
                                  MediaQuery.of(context).size.width *
                                      0.38 *
                                      (1 - snapshot.data!.toInt() / 100)),
                              decoration: BoxDecoration(
                                color: const Color(0x40EB6821),
                                borderRadius: BorderRadius.circular(
                                  0,
                                ),
                                border: Border.all(
                                  color: const Color(0x60EB6821),
                                ),
                              ),
                              child: Center(
                                child: AutoSizeText(
                                  snapshot.data == 100
                                      ? "0%"
                                      : "${100 - snapshot.data!.toInt()}%",
                                  style: const TextStyle(
                                    color: Colors.deepOrange,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (widget.question.answer != null) ...[
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.08,
                        width: MediaQuery.of(context).size.width * 0.1,
                        child: Center(
                          child: RotationTransition(
                            turns: const AlwaysStoppedAnimation(335 / 360),
                            child: Text(
                              widget.question.answer! ? "YES" : "NO",
                              style: TextStyle(
                                fontSize: 16,
                                color: widget.question.answer!
                                    ? const Color(0xFF269E3D)
                                    : const Color(0xFFEB6821),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (widget.question.answer == null) ...[
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.08,
                        width: MediaQuery.of(context).size.width * 0.1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.1,
                              child: Center(
                                child: Text(
                                  "Yes",
                                  style: TextStyle(
                                    color: Colors.green[600],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.1,
                              child: const Center(
                                child: Text(
                                  "No",
                                  style: TextStyle(
                                    color: Colors.deepOrange,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Divider(
                color: Colors.grey,
              ),
              if (widget.question.openTradesCount! +
                      widget.question.pairedTradesCount! >
                  0) ...[
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.people,
                        color: Colors.grey,
                        size: 20,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.02,
                      ),
                      Text(
                        "${widget.question.openTradesCount! + widget.question.pairedTradesCount! * 2}+  people trading",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.question.openTradesCount! +
                        widget.question.pairedTradesCount! ==
                    0) ...[
                  const Expanded(
                    child: Text(
                      "Be the first to trade",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ]
              ],
            ],
          ),
        ),
      ),
    );
  }
}
