import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
part 'home_state.dart';

class HomeCubit extends Cubit<HomeState>{
  HomeCubit(super.initialState);

  int changeRoute (int i)
  {

    switch (i)
    {
      case 0:
        emit(HomeLandingState());
        break;

      case 1:
        emit(HomeSearchState());
        break;

      case 2:
        emit(HomeAdsState());
        break;

      case 3:
        emit(HomeProfileState());
        break;

      case 4:
        emit(HomeAdminState());
        break;

      case 5:
        emit(HomeAdRequestState());
        break;

      case 6:
        emit(HomeMoneyRequestState());
        break;

      default:
        emit(HomeLandingState());
    }


    return i;
  }
}