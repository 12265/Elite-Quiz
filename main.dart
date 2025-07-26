import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/app.dart';

import 'features/profileManagement/cubits/updateScoreAndCoinsCubit.dart';
import 'features/profileManagement/profileManagementRepository.dart';

void main() async {runApp(MultiBlocProvider(
    providers: [BlocProvider<UpdateScoreAndCoinsCubit>(
      create: (_) =>
          UpdateScoreAndCoinsCubit(ProfileManagementRepository()),
    )
    ],child: await initializeApp()));
}
