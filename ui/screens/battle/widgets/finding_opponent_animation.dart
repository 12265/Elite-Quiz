import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

class FindingOpponentAnimation extends StatefulWidget {
  final AnimationController animationController;

  const FindingOpponentAnimation({
    super.key,
    required this.animationController,
  });

  @override
  State<FindingOpponentAnimation> createState() =>
      _FindingOpponentAnimationState();
}

class _FindingOpponentAnimationState extends State<FindingOpponentAnimation>
    with SingleTickerProviderStateMixin {
  late final _avatars = context.read<SystemConfigCubit>().defaultAvatarImages;

  late final _animation = IntTween(begin: 0, end: _avatars.length - 1).animate(
    widget.animationController,
  );

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final boxDecoration = BoxDecoration(
      shape: BoxShape.circle,
      color: Theme.of(context).primaryColor,
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        /// Circle Background
        Container(
          decoration: boxDecoration,
          height: height * .15,
        ),

        /// Default Avatars
        Container(
          decoration: boxDecoration,
          height: height * .14,
          alignment: Alignment.center,
          child: AnimatedBuilder(
            animation: widget.animationController,
            builder: (_, __) => Image.asset(
              UiUtils.getprofileImagePath(_avatars[_animation.value]),
            ),
          ),
        )
      ],
    );
  }
}
