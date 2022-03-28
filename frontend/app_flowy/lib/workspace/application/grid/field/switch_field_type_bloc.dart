import 'dart:typed_data';
import 'package:flowy_sdk/log.dart';
import 'package:flowy_sdk/protobuf/flowy-grid-data-model/grid.pb.dart';
import 'package:flowy_sdk/protobuf/flowy-grid-data-model/meta.pb.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:async';
import 'field_service.dart';

part 'switch_field_type_bloc.freezed.dart';

class FieldTypeSwitchBloc extends Bloc<FieldTypeSwitchEvent, FieldTypeSwitchState> {
  FieldTypeSwitchBloc(SwitchFieldContext editContext) : super(FieldTypeSwitchState.initial(editContext)) {
    on<FieldTypeSwitchEvent>(
      (event, emit) async {
        await event.map(
          toFieldType: (_ToFieldType value) async {
            final fieldService = FieldService(gridId: state.gridId);
            final result = await fieldService.getEditFieldContext(value.fieldType);
            result.fold(
              (newEditContext) {
                emit(
                  state.copyWith(
                    field: newEditContext.gridField,
                    typeOptionData: Uint8List.fromList(newEditContext.typeOptionData),
                  ),
                );
              },
              (err) => Log.error(err),
            );
          },
          didUpdateTypeOptionData: (_DidUpdateTypeOptionData value) {
            emit(state.copyWith(typeOptionData: value.typeOptionData));
          },
        );
      },
    );
  }

  @override
  Future<void> close() async {
    return super.close();
  }
}

@freezed
class FieldTypeSwitchEvent with _$FieldTypeSwitchEvent {
  const factory FieldTypeSwitchEvent.toFieldType(FieldType fieldType) = _ToFieldType;
  const factory FieldTypeSwitchEvent.didUpdateTypeOptionData(Uint8List typeOptionData) = _DidUpdateTypeOptionData;
}

@freezed
class FieldTypeSwitchState with _$FieldTypeSwitchState {
  const factory FieldTypeSwitchState({
    required String gridId,
    required Field field,
    required Uint8List typeOptionData,
  }) = _FieldTypeSwitchState;

  factory FieldTypeSwitchState.initial(SwitchFieldContext switchContext) => FieldTypeSwitchState(
        gridId: switchContext.gridId,
        field: switchContext.field,
        typeOptionData: Uint8List.fromList(switchContext.typeOptionData),
      );
}

class SwitchFieldContext {
  final String gridId;
  final Field field;
  final List<int> typeOptionData;

  SwitchFieldContext(this.gridId, this.field, this.typeOptionData);
}
