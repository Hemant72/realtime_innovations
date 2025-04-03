import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:realtime_innovations/datasource/data_source.dart';
import 'package:realtime_innovations/model/employe_model.dart';

part 'employee_state.dart';

class EmployeeCubit extends Cubit<EmployeeState> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  EmployeeCubit() : super(EmployeeInitial()) {
    loadEmployees();
  }

  Future<void> loadEmployees() async {
    emit(EmployeeLoading());
    try {
      final employees = await _databaseHelper.getEmployees();

      final now = DateTime.now();
      final currentEmployees =
          employees
              .where((e) => e.endDate == null || e.endDate!.isAfter(now))
              .toList();
      final previousEmployees =
          employees
              .where((e) => e.endDate != null && !e.endDate!.isAfter(now))
              .toList();

      emit(
        EmployeeLoaded(
          currentEmployees: currentEmployees,
          previousEmployees: previousEmployees,
        ),
      );
    } catch (e) {
      emit(EmployeeError('Failed to load employees: $e'));
    }
  }

  Future<void> addEmployee(Employee employee) async {
    try {
      await _databaseHelper.insertEmployee(employee);
      loadEmployees();
    } catch (e) {
      emit(EmployeeError('Failed to add employee: $e'));
    }
  }

  Future<void> updateEmployee(Employee employee) async {
    try {
      await _databaseHelper.updateEmployee(employee);
      loadEmployees();
    } catch (e) {
      emit(EmployeeError('Failed to update employee: $e'));
    }
  }

  Future<void> deleteEmployee(int id) async {
    try {
      await _databaseHelper.deleteEmployee(id);
      loadEmployees();
    } catch (e) {
      emit(EmployeeError('Failed to delete employee: $e'));
    }
  }
}
